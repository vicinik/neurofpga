/////////////////////////////////////////////////////////////////////////////////////////////
// Workfile:    main.cpp
// Date:        2017/1/3
// Description: Testdriver for the implementation of a neural net
// Author:      Nik Haminger
/////////////////////////////////////////////////////////////////////////////////////////////
#include <iostream>
#include <iomanip>
#include <string>
#include <vector>
#include "NeuralNet.h"
#include "Manipulators.h"

using namespace std;
using namespace ownmanips;

double PrepareResults(double const x) {
	return (x >= 0.5) ? 1 : 0;
}

double RealVal(double const x) {
	return x;
}

struct TestData {
	Data input;
	Data target;
};

void PrintContainer(string const& msg, Data const& cont) {
	cout << msg << ": [ ";
	for (auto& elem : cont) {
		cout << elem << " ";
	}
	cout << "]" << endl;
}

void PrintTestContainer(vector<TestData> const& testVector) {
	cout << "a b | y" << endl;
	cout << "-------" << endl;
	for (auto& elem : testVector) {
		cout << elem.input[0] << " " << elem.input[1] << " | " << elem.target[0] << endl;
	}
}

int main(){
	PrintHeader("Training Neural Network");
	NeuralNet net({ 2, 5, 1 }, PrepareResults);
	size_t numberRuns = 10000;
	string input;

	// Test data ----------------------------
	vector<TestData> testVector;
	TestData data1 = { { 0,0 },{ 0 } };
	TestData data2 = { { 1,0 },{ 0 } };
	TestData data3 = { { 0,1 },{ 0 } };
	TestData data4 = { { 1,1 },{ 1 } };
	testVector.push_back(data1);
	testVector.push_back(data2);
	testVector.push_back(data3);
	testVector.push_back(data4);

	cout << "Press [ENTER] to begin training..." << endl;
	getc(stdin);

	// Print test data
	PrintSubHeader("Test data and expected results");
	PrintTestContainer(testVector);

	// Train --------------------------------
	for (size_t i = 0; i < numberRuns; ++i) {
		auto& testData = testVector[i%testVector.size()];
		net.Train(testData.input, testData.target);
		if (i < testVector.size() || i % (numberRuns/4) == 0 || i >= numberRuns - testVector.size()) {
			PrintSubHeader("Run number " + to_string(i + 1));
			PrintContainer("Input    ", testData.input);
			PrintContainer("Expected ", testData.target);
			PrintContainer("Result   ", net.getResults());
			cout << "Recent average error: " << net.getRecentError() << endl;
		}
	}

	cout << endl << "Press [ENTER] to exit..." << endl;
	getc(stdin);

	return 0;
}