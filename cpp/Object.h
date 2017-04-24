///////////////////////////////////////////////////////////////////////////
// Workfile : Object.h
// Author : Nik Haminger
///////////////////////////////////////////////////////////////////////////
#ifndef _OBJECT_
#define _OBJECT_

//##########################################################################################
///This is the base class of all classes.
class Object
{
public:
	//--------------------------------------------------------------------------------------
	///Description: Virtual destructor, that means it will be called only at the end when all derived
	///classes are destroyed.
	virtual ~Object() = default;
protected:
	//--------------------------------------------------------------------------------------
	///Description: Protected ctor, so only subclasses can create an object of this class.
	Object() = default;
private:

};

#endif //_OBJECT_