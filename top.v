/**
 * File              : top.v
 * License           : GPL-3.0-or-later
 * Author            : Peter Gu <github.com/regymm>
 * Date              : 2022.02.23
 * Last Modified Date: 2022.02.23
 */
`timescale 1ns / 1ps
module top
#(
	parameter CLOCK_FREQ = 50000000, // PIN_SCAN CLOCK
	parameter COUNT = 1, // PIN_SCAN COUNT
	parameter DEPTH = 10, // PIN_SCAN DEPTH
	parameter BAUD_RATE = 115200
)
(
	// PIN_SCAN PINS
	// e.g. output AA28,
	input clk
);

	wire [9:0]a;
	reg [31:0]d;
	reg [31:0]mem[2**DEPTH-1:0];
	initial $readmemh("pins.dat", mem);
	always @ (posedge clk) begin
		d <= mem[a];
	end

	reg [7:0]data;
	reg we;
	wire ready;
	reg tx = 1;
    parameter TX_ACC_MAX = CLOCK_FREQ / BAUD_RATE;
    reg [19:0] tx_acc = 0;
    wire txclk_en = (tx_acc == 0);
    always @(posedge clk) begin
		tx_acc <= tx_acc == TX_ACC_MAX[19:0] ? 0 : tx_acc + 1;
    end

    localparam IDLE = 2'b00;
    localparam START = 2'b01;
    localparam DATA = 2'b10;
    localparam STOP = 2'b11;
    reg [1:0]state_tx = IDLE;
    reg [7:0]data_tx = 8'h00;
    reg [2:0]bitpos_tx = 3'b0;
	assign ready = state_tx == IDLE;

    always @ (posedge clk) begin
		case (state_tx)
			IDLE: if (we) begin
				data_tx <= data;
				state_tx <= START;
				bitpos_tx <= 3'b0;
			end
			START: if (txclk_en) begin
				tx <= 1'b0;
				state_tx <= DATA;
			end
			DATA: if (txclk_en) begin
				if (bitpos_tx == 3'h7) state_tx <= STOP;
				else bitpos_tx <= bitpos_tx + 1;
				tx <= data_tx[bitpos_tx];
			end
			STOP: if (txclk_en) begin
				tx <= 1'b1;
				state_tx <= IDLE;
			end
		endcase
    end

	reg [2:0]chrcnt = 0;
	always @ (*) begin
		case (chrcnt)
			0: data = d[31:24];
			1: data = d[23:16];
			2: data = d[15:8];
			3: data = d[7:0];
			4: data = 8'd13;
			5: data = 8'd10;
			default: data = 0;
		endcase
	end

	reg [DEPTH-1:0]pincnt = 0;
	assign a = pincnt;

	reg [2:0]state = 0;
	always @ (posedge clk) begin
		case (state)
			3'b00: begin state <= 3'b01; end
			3'b01: begin
				if (ready) begin
					we <= 1;
					state <= 3'b10;
				end
			end
			3'b10: begin
				we <= 0;
				if (chrcnt == 5) state <= 3'b11;
				else begin
					chrcnt <= chrcnt + 1;
					state <= 3'b01;
				end
			end
			3'b11: begin
				pincnt <= pincnt == (COUNT-1) ? 0 : pincnt + 1;
				state <= 3'b000;
				chrcnt <= 0;
			end
			default: begin state <= 3'b000; end
		endcase
	end

	// PIN_SCAN ASSIGN
	// e.g. assign AA28 = pincnt == 123 ? tx : 1'b1;
endmodule
