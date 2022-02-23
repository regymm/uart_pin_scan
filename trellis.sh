#!/bin/bash -e
yosys -p "synth_ecp5 -json output.json" output.v
nextpnr-ecp5 --json output.json --lpf output.lpf --textcfg output.config --12k --package CABGA256 --speed 6
ecppack --compress --svf-rowsize 100000 --svf output.svf --input output.config --bit output.bit
