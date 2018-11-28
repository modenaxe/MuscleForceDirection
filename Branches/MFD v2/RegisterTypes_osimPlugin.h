#ifndef _RegisterTypes_OsimPlugin_h_

	#define _RegisterTypes_OsimPlugin_h_

	#include "osimPluginDLL.h"

	//COMPATIBILE CON C:  #ifndef: http://forum.html.it/forum/showthread/t-1335669.html
	extern "C" 
	
	{
		OSIMPLUGIN_API void RegisterTypes_osimPlugin(); 
	}

	class dllObjectInstantiator 
	{ 
		public: 
			dllObjectInstantiator(); 
		private: 
			void registerDllClasses(); 
	}; 
    
#endif // _RegisterTypes_OsimPlugin_h_


