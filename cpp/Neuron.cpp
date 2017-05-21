/////////////////////////////////////////////////////////////////////////////////////////////
// Workfile:    Neuron.cpp
// Date:        2017/1/3
// Description: -
// Author:      Nik Haminger
/////////////////////////////////////////////////////////////////////////////////////////////
#include <cstdlib>
#include <cmath>
#include "Neuron.h"

using namespace std;

Neuron::Neuron(size_t const numCon, size_t const myIndex): mMyIndex(myIndex)
{
	// add forward connections for each neuron in the next layer
	for (size_t i = 0; i < numCon; ++i) {
		mConnections.push_back({ getRandomWeight(), 0.0 } );
	}
}

void Neuron::UpdateInputWeights(LayerNeurons& prevLayer)
{
	// the weights to be updated are in the back connection container
	for (size_t i = 0; i < prevLayer.size(); ++i) {
		auto& prevNeuron = prevLayer[i];
		auto& con = prevNeuron.mConnections[mMyIndex];
		double oldDeltaWeight = con.deltaWeight;

		double newDeltaWeight =
			// individual input, magnified by the gradient and train rate (eta)
			mEta
			* prevNeuron.getOutputVal()
			* mGradient
			// also add momentum = a fraction of the previous delta weight
			+ alpha
			* oldDeltaWeight;

		con.deltaWeight = newDeltaWeight;
		con.weight += newDeltaWeight;
	}
}

void Neuron::CalcHiddenGradients(LayerNeurons& nextLayer)
{
	double dow = sumDow(nextLayer);
	mGradient = dow * activationFuncDeriv(mOutputVal);
}

void Neuron::CalcOutputGradients(double const targetVal)
{
	double delta = targetVal - mOutputVal;
	mGradient = delta * activationFuncDeriv(mOutputVal);
}

void Neuron::ForwardPropagate(LayerNeurons& prevLayer)
{
	double sum = 0.0;

	// sum up values of previous layer's neurons x the weight of the connections
	for (size_t i = 0; i < prevLayer.size(); ++i) {
		auto& neuron = prevLayer[i];
		sum += neuron.getOutputVal() * neuron.getConnections()[mMyIndex].weight;
	}

	setOutputVal(activationFunc(sum));
}

double Neuron::getOutputVal() const
{
	return mOutputVal;
}

void Neuron::setOutputVal(double const x)
{
	mOutputVal = x;
}

std::vector<Connection>& Neuron::getConnections()
{
	return mConnections;
}

double Neuron::getGradient() const
{
	return mGradient;
}

void Neuron::setEta(double const& eta)
{
	if (eta > 0.0) {
		mEta = eta;
	}
}

double Neuron::sumDow(LayerNeurons const& nextLayer) const
{
	double sum = 0.0;

	// sum our contributions of the errors at the nodes we feed
	for (size_t i = 0; i < nextLayer.size() - 1; ++i) {
		sum += mConnections[i].weight * nextLayer[i].getGradient();
	}

	return sum;
}

double Neuron::getRandomWeight()
{
	return rand() / double(RAND_MAX);
}

double Neuron::activationFunc(double const x)
{
	//return tanh(x);
	if (x > 1.0) return 1.0;
	else if (x < -1.0) return -1.0;
	else return x;
}

double Neuron::activationFuncDeriv(double const x)
{
	return 1 / (1 + x*x);
	//return 1 - x*x;
	/*if (x > 1.0) return 0.0;
	else if (x < -1.0) return 0.0;
	else return 1.0;*/
}
