// FFmpeg compatibility fix for Visual Studio 2015+
// This file provides missing symbols that older FFmpeg builds expect

#include <stdio.h>
#include <stdarg.h>

#ifdef _MSC_VER
#if _MSC_VER >= 1900 // Visual Studio 2015 and later

// FFmpeg compiled with older MSVC expects __ms_vsnprintf
// but VS2015+ renamed it to _vsnprintf
extern "C" int __ms_vsnprintf(char* buffer, size_t count, const char* format, va_list argptr)
{
    return _vsnprintf(buffer, count, format, argptr);
}

// Also provide __ms_vsnwprintf if needed
extern "C" int __ms_vsnwprintf(wchar_t* buffer, size_t count, const wchar_t* format, va_list argptr)
{
    return _vsnwprintf(buffer, count, format, argptr);
}

#endif
#endif
