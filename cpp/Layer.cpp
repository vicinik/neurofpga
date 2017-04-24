/////////////////////////////////////////////////////////////////////////////////////////////
// Workfile:    Layer.cpp
// Date:        2017/1/3
// Description: -
// Author:      Nik Haminger
/////////////////////////////////////////////////////////////////////////////////////////////
#include <string>
#include "Layer.h"

using namespace std;

Layer::Layer(size_t const numberNeurons, size_t const numCon)
{
	if (numberNeurons == 0) throw string("A layer must have at least 1 neuron");

	// create [numberNeurons] neurons with the specified activationFunction and number of connections
	// to the next layer
	for (size_t i = 0; i <= numberNeurons; ++i) {
		mNeurons.push_back(Neuron(numCon, i));
	}

	// bias neuron -> force output val to 1.0
	mNeurons.back().setOutputVal(1.0);
}

size_t Layer::getSize() const
{
	return mNeurons.size() - 1;
}

std::vector<Neuron>& Layer::getNeurons()
{
	return mNeurons;
}

Neuron & Layer::getNeuronAt(size_t const index)
{
	if (index >= mNeurons.size()) throw string("Layer doesn't have that many neurons");
	return mNeurons[index];
}
