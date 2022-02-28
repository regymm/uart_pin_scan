## UART Pin Scan

Semi-automatic scripts to output pin number on each pin, for FPGA board reverse engineering. 

You need to give clock pin location and a list of pins(usually all pins on chip) you want to check. Change clock frequency and baud rate in top of top.v. 

#### Warning

The bitstream literally drives every pin high on the chip, so some delicate peripheral connected to the FPGA may get damaged -- use as your own risk! 

#### Example

xc7k325t on mysterious board with HSTL_II_18 constraint. 

```
./gen.py pins_k7.txt pins.xdc top.v output.xdc output.v D27
```

lfe5u-12f 6bg256c on mysterious board with 50 MHz clock on pin K1. Pin list(pins.txt) derived from https://www.latticesemi.com/-/media/LatticeSemi/Documents/PinPackage/ECP5/FPGA-SC-02032-2-0-ECP5U-12-Pinout.ashx?document_id=51576

```
$ ./gen.py pins.txt pins.lpf top.v output.lpf output.v K1
196 pins
Memory file pins.dat writen
Constrain file output.lpf writen
Verilog file output.v writen
Ready to compile
$ ./trellis.sh
$ ecpprog -S output.bit
```

Probe every GPIO on board: 

```
F2  
F2  
R7  
R7  
R7  
���ܰ�\�@
       ��D�� ��t�
                 �������
                        Rw�
                           R7  
R7  
R7  
�<* 
   T7  
```

#### Other Tips

Usually the BGA FPGA chip is removed and multimeter beep-beep mode is used to do this job, but if most GPIO have series resistors, multimeter won't beep and things will be annoying. 

About JTAG, BGA fanout patterns are quite fixed, so you can looking at the (flipped) chip footprint and vias under the BGA, find which vias are JTAG's, scratch off solder mask if tented, then beep-beep or fly wires. 

About clock input pin, usual FPGAs only have several global clock-capable pins, so trying them one by one or XOR them together then binary search can help you quick find the clock, in case you don't want to remove the BGA for whatever reason. 

If the board immediately resets itself after downloading the bitstream, probably some peripherals are not happy about eating a UART output. 

#### License

GPL-v3