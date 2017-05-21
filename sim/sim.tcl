vlib work
vcom -2008 -work work {../src/global-p.vhd}
vcom -2008 -work work {../src/neurofpga-p.vhd}
vcom -2008 -work work {../src/Backpropagation/neuron.vhd}
vcom -2008 -work work {../src/Backpropagation/connection.vhd}
vcom -2008 -work work {../src/Backpropagation/inputlayer.vhd}
vcom -2008 -work work {../src/Backpropagation/hiddenlayer.vhd}
vcom -2008 -work work {../src/Backpropagation/outputlayer.vhd}
vcom -2008 -work work {../src/Backpropagation/net.vhd}
vcom -2008 -work work {tbneuralnet.vhd}

vsim TbNeuralNet
do wave.do

run 8.9 ms;