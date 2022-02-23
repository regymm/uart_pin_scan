## UART Pin Scan

Semi-automatic scripts to output pin number on each pin, for FPGA board reverse engineering. 

You need to give clock pin location and a list of pins(usually all pins on chip) you want to check. Change clock frequency and baud rate in top of top.v. 

#### Example:

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
R7  
R7  
R7  
R7  
R7  
R7  
R7  
R7  
R7  
R7  
R7  
�<* 
   T7  
T7  
T7  
T7  
T7  
T7  
T7  
```

#### License

GPL-v3