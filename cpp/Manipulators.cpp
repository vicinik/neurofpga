/////////////////////////////////////////////////////////////////////////////////////////////
// Workfile:    Manipulators.h
// Date:        2016/4/3
// Description: This module contains several functions for console output as well as debug
//              macros and manipulators. All print functions are threadsafe on Windows!
// Author:      Nik Haminger
/////////////////////////////////////////////////////////////////////////////////////////////
#include <iomanip>
#include <fstream>
#include "Manipulators.h"

using namespace std;

//###########################################################################################
// Windows only: Threadsafe printing
#ifdef WIN32
#include <Windows.h>

#ifndef _CRITSEC
class CritSec
{
public:
	//-------------------------------------------------------------------------------------
	///Description: Declare CSLock as friend of this class
	friend class CSLock;

	//-------------------------------------------------------------------------------------
	///Description: Default constructor
	CritSec() {
		InitializeCriticalSection(&mCS);
	}

	~CritSec() {
		DeleteCriticalSection(&mCS);
	}
private:
	///acquire and release lock
	void Acquire() {
		EnterCriticalSection(&mCS);
	}
	void Release() {
		LeaveCriticalSection(&mCS);
	}
	///delete copy-ctor and assignment-op
	CritSec(CritSec const&) = delete;
	CritSec & operator=(CritSec const&) = delete;
	///Critical Section
	CRITICAL_SECTION mCS;
};

class CSLock
{
public:
	//-------------------------------------------------------------------------------------
	///Description: Constructor
	///Params: [CSObj] The lock object
	CSLock(CritSec& CSObj) : mCSAccess(CSObj) {
		mCSAccess.Acquire();
	}

	//-------------------------------------------------------------------------------------
	///Description: Destructor, releases lock
	virtual ~CSLock() {
		mCSAccess.Release();
	}
private:
	///delete copy-ctor and assignment-op
	CSLock(CSLock const&) = delete;
	CSLock& operator=(CSLock const&) = delete;
	///the lock object
	CritSec& mCSAccess;
};
#endif //_CRITSEC

// CritSec-variable
static CritSec printCS;

//print a header
void ownmanips::PrintHeader(std::string const& title, std::ostream& os) {
	CSLock lock(printCS);
	os << titleLine << endl << title << endl2 << titleLine;
}

//print a subheader
void ownmanips::PrintSubHeader(std::string const& title, std::ostream& os) {
	CSLock lock(printCS);
	os << std::endl << line << title << std::endl << line;
}

//print an error
void ownmanips::PrintError(std::string const & errSource, std::string const & errMsg) {
	CSLock lock(printCS);
	std::cout << "|Error in [" << errSource << "]: " << errMsg << "|" << std::endl;
}

//print info
void ownmanips::PrintInfo(std::string const& msg, std::ostream& os) {
	CSLock lock(printCS);
	os << shortline;
	os << "|Info: " << msg << "|" << std::endl;
	os << shortline;
}

//print debug info
void ownmanips::DebugInfo(std::string const& msg, std::ostream& os) {
	CSLock lock(printCS);
	os << "|Debug-Info: " << msg << "|" << std::endl;
}

//print content of file to console
void ownmanips::PrintFileOnCmd(string const& fileName) {
	CSLock lock(printCS);
	ifstream inFile(fileName);
	if (!inFile) { PrintError("Main::PrintFileOnCmd", "Could not access file."); return; }

	char ch = 0;
	int cnt = 0;
	while (!inFile.eof()) {
		ch = inFile.get();
		if (inFile.eof()) break;
		cout << ch;
		cnt++;
	}
	if (cnt == 0) cout << "File is empty...";
	cout << endl;

	inFile.close();
}


//###########################################################################################
// Else: non-threadsafe printing!
#else
//print a header
void ownmanips::PrintHeader(std::string const& title, std::ostream& os) {
	os << titleLine << endl << title << endl2 << titleLine;
}

//print a subheader
void ownmanips::PrintSubHeader(std::string const& title, std::ostream& os) {
	os << std::endl << line << title << std::endl << line;
}

//print an error
void ownmanips::PrintError(std::string const & errSource, std::string const & errMsg) {
	std::cout << "|Error in [" << errSource << "]: " << errMsg << "|" << std::endl;
}

//print info
void ownmanips::PrintInfo(std::string const& msg, std::ostream& os) {
	os << "|Info: " << msg << "|" << std::endl;
}

//print debug info
void ownmanips::DebugInfo(std::string const& msg, std::ostream& os) {
	os << "|Debug-Info: " << msg << "|" << std::endl;
}

//print content of file to console
void ownmanips::PrintFileOnCmd(string const& fileName) {
	ifstream inFile(fileName);
	if (!inFile) { PrintError("Main::PrintFileOnCmd", "Could not access file."); return; }

	char ch = 0;
	int cnt = 0;
	while (!inFile.eof()) {
		ch = inFile.get();
		if (inFile.eof()) break;
		cout << ch;
		cnt++;
	}
	if (cnt == 0) cout << "File is empty...";
	cout << endl;

	inFile.close();
}
#endif //WIN32


//double endline
std::ostream& ownmanips::endl2(std::ostream& out) {
	out << std::endl << std::endl;
	return out;
}

//draw a line
std::ostream& ownmanips::line(std::ostream& out) {
	out << "-------------------------------------------------------------------------------" << std::endl;
	return out;
}

//draw a short line
std::ostream& ownmanips::shortline(std::ostream& out) {
	out << "------------------------" << std::endl;
	return out;
}

//draw a titleline
std::ostream& ownmanips::titleLine(std::ostream& out) {
	out << "###############################################################################" 
		<< std::endl;
	return out;
}

//make a tabspace
std::ostream& ownmanips::tab(std::ostream& out) {
	out << "   ";
	return out;
}

//clear file
void ownmanips::ClearFile(string const& fileName) {
	ofstream outFile(fileName);
	if (!outFile) { PrintError("Main::ClearFile", "Could not access file."); return; }
	outFile.close();
}