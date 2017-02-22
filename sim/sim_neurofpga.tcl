vlib work
vcom -2008 -work work {../src/global-p.vhd}
vcom -2008 -work work {../src/neurofpga-p.vhd}
vcom -2008 -work work {../src/neuron.vhd}
vcom -2008 -work work {../src/connection.vhd}
vcom -2008 -work work {../src/inputlayer.vhd}
vcom -2008 -work work {../src/hiddenlayer.vhd}

#vsim cpu_tb
#do wave_ue7.do

#run 55 us;
