/////////////////////////////////////////////////////////////////////////////////////////////
// Workfile:    NeuralNet.h
// Date:        2017/1/3
// Description: -
// Author:      Nik Haminger
/////////////////////////////////////////////////////////////////////////////////////////////
#ifndef _NET
#define _NET

#include <vector>
#include "Object.h"
#include "Layer.h"

typedef std::vector<double> Data;
typedef std::vector<size_t> LayerSizes;
typedef double(*ActivationFunc)(double const x);

//###########################################################################################
///This class represents an adaptive neural network. It consists of several layers of neurons,
///which dimensions can be stated as a parameter in the constructor.
class NeuralNet: public Object
{
public:
	//-------------------------------------------------------------------------------------
	///Description: Constructor, which takes the nets layerSizes as parameter
	NeuralNet(LayerSizes const& layerSizes, ActivationFunc outputActivation);

	//-------------------------------------------------------------------------------------
	///Description: A forward propagation cycle
	///Params: [input] Input data
	void ForwardPropagate(Data const& input);
	//-------------------------------------------------------------------------------------
	///Description: Backpropagation - adjust the weights of the neurons according to the RMS
	///Params: [target] Target vector
	void BackPropagate(Data const& target);
	//-------------------------------------------------------------------------------------
	///Description: Training cycle - forward- and backpropagation batch
	///Params: [input] Input data, [target] Target vector
	void Train(Data const& input, Data const& target);
	//-------------------------------------------------------------------------------------
	///Description: Get the results of a forwardpropagation
	///Return: Data vector
	Data getResults();
	//-------------------------------------------------------------------------------------
	///Description: Get the recent average error
	double getRecentError() const;

private:
	std::vector<Layer> mLayers;
	double mError = 0.0;
	double mRecentError = 0.0;
	const double mBeta = 0.5;
	const ActivationFunc mOutputActivationFunc;
};
#endif //_NET