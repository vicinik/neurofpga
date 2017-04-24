/////////////////////////////////////////////////////////////////////////////////////////////
// Workfile:    Manipulators.h
// Date:        2016/4/3
// Description: This module contains several functions for console output as well as debug
//              macros and manipulators. All print functions are threadsafe on Windows!
// Author:      Nik Haminger
/////////////////////////////////////////////////////////////////////////////////////////////
#ifndef _OWNMANIPS
#define _OWNMANIPS
#include <iostream>
#include <string>

//some manipulators and print functions
namespace ownmanips {
	//-----------------------------------------------------------
	//Manipulators

	//double endline
	std::ostream& endl2(std::ostream& out);
	//draw a line
	std::ostream& line(std::ostream& out);
	//draw a short line
	std::ostream& shortline(std::ostream& out);
	//draw a title line
	std::ostream& titleLine(std::ostream& out);
	//make a tabspace
	std::ostream& tab(std::ostream& out);

	//-----------------------------------------------------------
	//Functions

	//print a header
	void PrintHeader(std::string const& title, std::ostream& os = std::cout);
	//print a subheader
	void PrintSubHeader(std::string const& title, std::ostream& os = std::cout);
	//print an error
	void PrintError(std::string const& errSource, std::string const& errMsg);
	//print info
	void PrintInfo(std::string const& msg, std::ostream& os = std::cout);
	//print debug info
	void DebugInfo(std::string const& msg, std::ostream& os = std::cout);
	//print content of file on console
	void PrintFileOnCmd(std::string const& fileName);
	//clear file
	void ClearFile(std::string const& fileName);
}

//print debug messages
#ifdef _DEBUG
#define __FILENAME__ (strrchr(__FILE__, '\\') ? strrchr(__FILE__, '\\') + 1 : __FILE__)
#define DBG_INFO(msg) { ownmanips::DebugInfo(msg); }
#define DBG_ERR(msg) { ownmanips::PrintError(std::string(__FILENAME__) + "::" + std::to_string(__LINE__), msg); throw string(msg); }
#else
#define DBG_INFO(msg) (void)0
#define DBG_ERR(msg) { throw string(msg); }
#endif

#endif //_OWNMANIPS