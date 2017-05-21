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
#include <fstream>
#include <time.h>
#include <cstdlib>
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

void TrainNet(string const& fileName, size_t const maxRuns) {
	PrintHeader(fileName);
	NeuralNet net({ 2, 5, 1 }, PrepareResults);
	ofstream fileStream(fileName);

	// Test data ----------------------------
	vector<TestData> testVector;
	TestData data1 = { { 0,0 },{ 0 } };
	TestData data2 = { { 1,0 },{ 1 } };
	TestData data3 = { { 0,1 },{ 1 } };
	TestData data4 = { { 1,1 },{ 0 } };
	testVector.push_back(data1);
	testVector.push_back(data2);
	testVector.push_back(data3);
	testVector.push_back(data4);

	// Print test data
	PrintSubHeader("Test data and expected results");
	PrintTestContainer(testVector);

	// Train --------------------------------
	for (size_t i = 0; i < maxRuns; ++i) {
		auto& testData = testVector[i%testVector.size()];
		net.Train(testData.input, testData.target);

		// Write to csv file to be able to show an error diagram
		if (fileStream.is_open() && i % testVector.size() == 0) {
			fileStream << to_string(i + 1) << "," << net.getRecentError() << endl;
		}

		// Print some iterations out in console
		if (i % (maxRuns / 10) == 0) {
			PrintSubHeader("Run number " + to_string(i + 1));
			PrintContainer("Input    ", testData.input);
			PrintContainer("Expected ", testData.target);
			PrintContainer("Result   ", net.getResults());
			cout << "Recent average error: " << net.getRecentError() << endl;
		}
	}

	fileStream.close();
	cout << endl;
}

int main(){
	// initialize random generator
	srand(time(NULL));

	TrainNet("tanh_etaback1.csv", 800);
	TrainNet("tanh_etaback2.csv", 800);
	TrainNet("tanh_etaback3.csv", 800);

	return 0;
}