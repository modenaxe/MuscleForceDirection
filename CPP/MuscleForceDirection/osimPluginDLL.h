#ifndef _osimPluginDLL_h_
#define _osimPluginDLL_h_

#ifdef WIN32
#    ifdef OSIMPLUGIN_EXPORTS
#        define OSIMPLUGIN_API __declspec(dllexport)
#    else
#        define OSIMPLUGIN_API __declspec(dllimport)
#    endif
#else
#    define OSIMPLUGIN_API
#endif // WIN32

#endif // __osimPluginDLL_h__
