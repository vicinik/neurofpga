@echo off

echo Deleting generated files...
del transcript
del vsim.wlf
del /s /q work

echo ---
echo Starting simulation...
vsim -do sim.tcl