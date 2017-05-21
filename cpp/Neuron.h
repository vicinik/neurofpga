/////////////////////////////////////////////////////////////////////////////////////////////
// Workfile:    Neuron.h
// Date:        2017/1/3
// Description: -
// Author:      Nik Haminger
/////////////////////////////////////////////////////////////////////////////////////////////
#ifndef _NEURON
#define _NEURON

#include <vector>
#include <memory>
#include "Object.h"

class Neuron;

typedef std::vector<Neuron> LayerNeurons;
struct Connection {
	double weight;
	double deltaWeight;
};

//###########################################################################################
///This is the representation of a neuron. The neuron itself contains the connections with
///the weights to the neurons in the previous layer and an activation function as well as
///an output value. When constructed, it needs to know the previous layer and the activation
///function.
class Neuron: public Object
{
public:
	//-------------------------------------------------------------------------------------
	///Description: Constructor
	///Params: [numCom] Number of connections [myIndex] Index of the neuron in its layer
	Neuron(size_t const numCon, size_t const myIndex);

	//-------------------------------------------------------------------------------------
	///Description: Update the weights of the inputs to 'learn'
	///Params: [prevLayer] Vector of neurons of the previous layer
	void UpdateInputWeights(LayerNeurons& prevLayer);
	//-------------------------------------------------------------------------------------
	///Description: Calculate hidden layers gradients
	///Params: [nextLayer] Vector of neurons of the next layer
	void CalcHiddenGradients(LayerNeurons& nextLayer);
	//-------------------------------------------------------------------------------------
	///Description: Calculate output gradients
	///Params: [targetVal] The target value
	void CalcOutputGradients(double const targetVal);
	//-------------------------------------------------------------------------------------
	///Description: Process input values by calculating new output value
	///Params: [prevLayer] Vector of neurons of the previous layer
	void ForwardPropagate(LayerNeurons& prevLayer);
	//-------------------------------------------------------------------------------------
	///Description: Returns the output value of the neuron
	double getOutputVal() const;
	//-------------------------------------------------------------------------------------
	///Description: Set the output value of the neuron manually (needed for input neurons)
	void setOutputVal(double const x);
	//-------------------------------------------------------------------------------------
	///Description: Get the connection vector
	std::vector<Connection>& getConnections();
	//-------------------------------------------------------------------------------------
	///Description: Get the current gradient
	double getGradient() const;
	//-------------------------------------------------------------------------------------
	///Description: Set the learning rate (eta)
	void setEta(double const& eta);

private:
	double mOutputVal = 0.0;
	double mGradient = 0.0;
	size_t mMyIndex = 0;
	std::vector<Connection> mConnections;
	double mEta = 0.15;

	double sumDow(LayerNeurons const& nextLayer) const;
	static double getRandomWeight();
	static double activationFunc(double const x);
	static double activationFuncDeriv(double const x);
	const double alpha = 0.0;
};
#endif //_NEURON