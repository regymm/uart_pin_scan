#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# File              : gen.py
# License           : GPL-3.0-or-later
# Author            : Peter Gu <github.com/regymm>
# Date              : 2022.02.23
# Last Modified Date: 2022.02.23
import sys
import os

if len(sys.argv) < 7:
    print("Usage: ./gen.py pins.txt pins.lpf|xdc top.v output.lpf|xdc output.v CLK_PIN")
    sys.exit(1)

lpf_entry = "LOCATE COMP \"%s\" SITE \"%s\";\n"

xdc_33 = "LVCMOS33"
xdc_hs_18 = "HSTL_II_18"
xdc_entry = "set_property -dict {PACKAGE_PIN %s IOSTANDARD %s} [get_ports {%s}]\n"

v_count_entry = "\tparameter COUNT = %d,\n"
v_def_entry = "\toutput %s,\n" 
v_assign_entry = "assign %s = pincnt == %d ? tx : 1\'b1;\n" 

f_pins, f_lpf, f_v, f_lpf_out, f_v_out, clk_pin = sys.argv[1:]
f_mem_out = "pins.dat"
with open(f_pins, "r") as f:
    pins = [i.strip() for i in f.readlines() if i[0] != '#']
    pincnt = len(pins)
    print("%d pins" % pincnt)

with open(f_mem_out, "w") as f:
    for i in pins:
        s = i + ' ' * (4-len(i))
        f.write("%02x%02x%02x%02x\n" % (ord(s[0]), ord(s[1]), ord(s[2]), ord(s[3])))
    print("Memory file %s writen" % f_mem_out)

if '.lpf' in f_lpf: 
    print("Constrain file type is lpf")
    with open(f_lpf, "r") as f2:
        lpf_lines = f2.readlines()
        with open(f_lpf_out, "w") as f3:
            for i in lpf_lines:
                if "PIN_SCAN LPF_CLK" in i:
                    f3.write(lpf_entry % ("clk", clk_pin))
                elif "PIN_SCAN LPF_PINS" in i:
                    for j in pins:
                        f3.write(lpf_entry % (j, j))
                else:
                    f3.write(i)
            print("Constrain file %s writen" % f_lpf_out)
elif '.xdc' in f_lpf: 
    print("Constrain file type is xdc")
    with open(f_lpf, "r") as f2:
        lpf_lines = f2.readlines()
        with open(f_lpf_out, "w") as f3:
            for i in lpf_lines:
                if "PIN_SCAN XDC_CLK" in i:
                    f3.write(xdc_entry % (clk_pin, xdc_hs_18, "clk"))
                elif "PIN_SCAN XDC_PINS" in i:
                    for j in pins:
                        f3.write(xdc_entry % (j, xdc_33, j))
                else:
                    f3.write(i)
            print("Constrain file %s writen" % f_lpf_out)
else:
    print("Unsupported constraint file type!")
    exit(-2)


with open(f_v, "r") as f2:
    v_lines = f2.readlines()
    with open(f_v_out, "w") as f3:
        for i in v_lines:
            if "PIN_SCAN COUNT" in i:
                f3.write(v_count_entry % pincnt)
            elif "PIN_SCAN PINS" in i:
                for j in pins:
                    f3.write(v_def_entry % j)
            elif "PIN_SCAN ASSIGN" in i:
                for j in range(len(pins)):
                    f3.write(v_assign_entry % (pins[j], j))
            else:
                f3.write(i)
        print("Verilog file %s writen" % f_v_out)

print("Ready to compile")
