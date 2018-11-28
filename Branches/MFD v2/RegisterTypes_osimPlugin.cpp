// RegisterTypes_osimPlugin.cpp

#include <string>
#include <iostream>
#include <OpenSim/Common/Object.h>
#include "RegisterTypes_osimPlugin.h"
//#include "MyAnalysis.h"
#include "MuscleForceDirection.h"

using namespace OpenSim;
using namespace std;

static dllObjectInstantiator instantiator; 
     
//_____________________________________________________________________________
/**
 * The purpose of this routine is to register all class types exported by
 * the Plugin library.
 */
OSIMPLUGIN_API void RegisterTypes_osimPlugin()
{
	//Object::RegisterType( MyAnalysis() );
	Object::RegisterType( MuscleForceDirection() );
}

dllObjectInstantiator::dllObjectInstantiator() 
{ 
        registerDllClasses(); 
} 
    
void dllObjectInstantiator::registerDllClasses() 
{ 
        RegisterTypes_osimPlugin(); 
} 
