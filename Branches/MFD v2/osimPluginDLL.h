// SUPPORT MATERIAL

// #ifndef: http://forum.html.it/forum/showthread/t-1335669.html
// #DEFINE: http://msdn.microsoft.com/en-us/library/teas0593%28v=vs.80%29.aspx

#ifndef _osimPluginDLL_h_
	#define _osimPluginDLL_h_ 

	// UNIX PLATFORM
	#ifndef WIN32

		#define OSIMPLUGIN_API

	// WINDOWS PLATFORM
	#else
		// removes some headers from <windows.h>
		#define WIN32_LEAN_AND_MEAN //http://blogs.msdn.com/b/oldnewthing/archive/2009/11/30/9929944.aspx
		#define NOMINMAX //http://stackoverflow.com/questions/4913922/possible-problems-with-nominmax-on-visual-c
		#include <windows.h>
		
		#ifdef OSIMPLUGIN_EXPORTS
			#define OSIMPLUGIN_API __declspec(dllexport)
		#else
			#define OSIMPLUGIN_API __declspec(dllimport)
		#endif

	#endif // PLATFORM
#endif // __osimPluginDLL_h__
