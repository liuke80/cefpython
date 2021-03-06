# Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

include "compile_time_constants.pxi"

from cef_types_mac cimport _cef_key_info_t
from cef_types_wrappers cimport CefStructBase
from libcpp cimport bool as cpp_bool

cdef extern from "include/internal/cef_linux.h":
    ctypedef _cef_key_info_t CefKeyInfo
    ctypedef void* CefWindowHandle
    ctypedef void* CefCursorHandle

    cdef cppclass CefWindowInfo:
        void SetAsChild(CefWindowHandle ParentView, int x, int y, int width,
                  int height)
        void SetTransparentPainting(cpp_bool)
        void SetAsOffScreen(CefWindowHandle)

    cdef cppclass CefMainArgs(CefStructBase):
        CefMainArgs()
        CefMainArgs(int argc_arg, char** argv_arg)
