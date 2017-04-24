/////////////////////////////////////////////////////////////////////////////////////////////
// Workfile:    NeuralNet.cpp
// Date:        2017/1/3
// Description: -
// Author:      Nik Haminger
/////////////////////////////////////////////////////////////////////////////////////////////
#include <string>
#include <cmath>
#include "NeuralNet.h"
#include "Manipulators.h"

using namespace std;
using namespace ownmanips;

NeuralNet::NeuralNet(LayerSizes const & layerSize, ActivationFunc outputActivation) : mOutputActivationFunc(outputActivation)
{
	if (layerSize.size() < 2) throw string("A neural net must have at least an input and an output layer...");

	// input layer
	mLayers.push_back(Layer(layerSize[0], layerSize[1]));

	// hidden layers
	for (size_t i = 1; i < layerSize.size() - 1; ++i) {
		mLayers.push_back(Layer(layerSize[i], layerSize[i+1]));
	}

	// output layer
	mLayers.push_back(Layer(layerSize.back(), 0));
}

void NeuralNet::ForwardPropagate(Data const & input)
{
	if (input.size() != mLayers[0].getSize()) throw string("Input vector size does not match number of input neurons");

	// pass values to input neurons
	for (size_t i = 0; i < input.size(); ++i) {
		mLayers[0].getNeuronAt(i).setOutputVal(input[i]);
	}

	// forward propagation for all layers except input layer
	// and for all neurons inside a layer except the bias neuron
	for (size_t i = 1; i < mLayers.size(); ++i) {
		for (size_t j = 0; j < mLayers[i].getSize(); ++j) {
			auto& curLayer = mLayers[i];
			auto& prevLayer = mLayers[i - 1];
			curLayer.getNeuronAt(j).ForwardPropagate(prevLayer.getNeurons());
		}
	}
}

void NeuralNet::BackPropagate(Data const & target)
{
	// calculate overall net error (RMS of output neuron errors)
	Layer& outputLayer = mLayers.back();
	mError = 0.0;

	if (target.size() != outputLayer.getSize()) throw string("Number of target values does not match number of output neurons");

	for (size_t i = 0; i < outputLayer.getSize(); ++i) {
		double delta = target[i] - outputLayer.getNeuronAt(i).getOutputVal();
		mError += delta*delta;
	}
	mError /= outputLayer.getSize();
	mError = sqrt(mError);

	// recent average measurement
	mRecentError = (mRecentError * mBeta + mError) / (mBeta + 1.0);

	// calculate output layer gradients
	for (size_t i = 0; i < outputLayer.getSize(); ++i) {
		outputLayer.getNeuronAt(i).CalcOutputGradients(target[i]);
	}

	// calculate hidden layers gradients
	for (size_t i = mLayers.size() - 2; i > 0; --i) {
		Layer& hiddenLayer = mLayers[i];
		Layer& nextLayer = mLayers[i + 1];

		for (size_t j = 0; j < hiddenLayer.getNeurons().size(); ++j) {
			hiddenLayer.getNeuronAt(j).CalcHiddenGradients(nextLayer.getNeurons());
		}
	}

	// update connection weights
	for (size_t i = mLayers.size() - 1; i > 0; --i) {
		Layer& layer = mLayers[i];
		Layer& prevLayer = mLayers[i - 1];

		for (size_t j = 0; j < layer.getSize(); ++j) {
			layer.getNeuronAt(j).UpdateInputWeights(prevLayer.getNeurons());
		}
	}
}

void NeuralNet::Train(Data const & input, Data const & target)
{
	ForwardPropagate(input);
	BackPropagate(target);
}

Data NeuralNet::getResults()
{
	Data res;
	for (size_t i = 0; i < mLayers.back().getSize(); ++i) {
		res.push_back(mOutputActivationFunc(mLayers.back().getNeuronAt(i).getOutputVal()));
	}
	return res;
}

double NeuralNet::getRecentError() const
{
	return mRecentError;
}
