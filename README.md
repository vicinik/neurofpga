# NeuroFPGA

## Description
This project is based on my bachelor's thesis and consists of a basic Multi-Layer-Perceptron (MLP) implementation with backpropagation in VHDL. The goal was to create a simple and straight forward implementation. The planning was done by programming a neural net in C++, which can also be observed in this repository.

## Structure
### cpp
Contains the source files of the C++ implementation.

### src
Contains the source files of the VHDL implementation.

### sim
Contains the testbench and simulation scripts for the VHDL implementation. It can be simulated with any Modelsim version younger than 2015 and maybe older versions too, who knows :)

### syn
Contains the testbeds of MLPs with and without backpropagation and also Quartus project files. Should be able to be compiled with all Quartus versions >= 16.0.

## Bachelor's thesis
The thesis is also present in the repository ([link](Bachelorarbeit.pdf)).
