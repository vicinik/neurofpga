vlib work
vcom -2008 -work work {../src/global-p.vhd}
vcom -2008 -work work {../src/neurofpga-p.vhd}
vcom -2008 -work work {../src/neuron.vhd}
vcom -2008 -work work {../src/connection.vhd}
vcom -2008 -work work {../src/inputlayer.vhd}
vcom -2008 -work work {../src/hiddenlayer.vhd}
vcom -2008 -work work {../src/outputlayer.vhd}
vcom -2008 -work work {../src/net.vhd}
vcom -2008 -work work {../src/tbneuralnet.vhd}

vsim TbNeuralNet
do wave.do

run 10 ms;
