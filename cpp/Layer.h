/////////////////////////////////////////////////////////////////////////////////////////////
// Workfile:    Layer.h
// Date:        2017/1/3
// Description: -
// Author:      Nik Haminger
/////////////////////////////////////////////////////////////////////////////////////////////
#ifndef _LAYER
#define _LAYER

#include <vector>
#include "Object.h"
#include "Neuron.h"

//###########################################################################################
///This class represents a layer in a neural network. It can be either an input, output or
///hidden layer. Basically, it consists of a vector of neurons. When constructed, you have
///to specify the number of neurons and the activation function for all the neurons in the
///layer.
class Layer: public Object
{
public:
	//-------------------------------------------------------------------------------------
	///Description: Constructor
	///Params: [numberNeurons] Number of neurons [activationFunc] Activation function for neurons
	Layer(size_t const numberNeurons, size_t const numCon);
	//-------------------------------------------------------------------------------------
	///Description: Get the size of the neuron vector WITHOUT bias neuron
	size_t getSize() const;
	//-------------------------------------------------------------------------------------
	///Description: Get all neurons of this layer
	///Return: Reference to the neurons
	std::vector<Neuron>& getNeurons();
	//-------------------------------------------------------------------------------------
	///Description: Get neuron at a specified index
	///Params: [index] Index of neuron
	///Return: Reference to the neuron
	Neuron& getNeuronAt(size_t const index);
	//-------------------------------------------------------------------------------------
	///Description: Set the eta of all neurons
	///Params: [eta] Learning rate
	void setEta(double const& eta);
private:
	std::vector<Neuron> mNeurons;
};
#endif //_LAYER