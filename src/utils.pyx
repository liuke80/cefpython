# Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

TID_UI = cef_types.TID_UI
TID_DB = cef_types.TID_DB
TID_FILE = cef_types.TID_FILE
TID_FILE_USER_BLOCKING = cef_types.TID_FILE_USER_BLOCKING
TID_PROCESS_LAUNCHER = cef_types.TID_PROCESS_LAUNCHER
TID_CACHE = cef_types.TID_CACHE
TID_IO = cef_types.TID_IO
TID_RENDERER = cef_types.TID_RENDERER

g_browserProcessThreads = [
    TID_UI,
    TID_DB,
    TID_FILE,
    TID_FILE_USER_BLOCKING,
    TID_CACHE,
    TID_IO,
]

cpdef py_bool IsString(object maybeString):
    # In Python 2.7 string types are: 1) str/bytes 2) unicode.
    # In Python 3 string types are: 1) bytes 2) str
    if type(maybeString) == bytes or type(maybeString) == str \
            or (PY_MAJOR_VERSION < 3 and type(maybeString) == unicode):
        return True
    return False

cpdef py_bool IsThread(int threadID):
    return bool(CefCurrentlyOn(<CefThreadId>threadID))

# TODO: this function needs to accept unicode strings, use the
#       logic from wxpython.py/ExceptHook to handle printing
#       unicode strings and writing them to file (codecs.open).
#       This change is required to work with Cython 0.20.

cpdef object Debug(str msg):
    if not g_debug:
        return
    msg = "[CEF Python] "+str(msg)
    print(msg)
    if g_debugFile:
        try:
            with open(g_debugFile, "a") as file:
                file.write(msg+"\n")
        except:
            print("[CEF Python] WARNING: failed writing to debug file: %s" % (
                    g_debugFile))


cpdef str GetSystemError():
    IF UNAME_SYSNAME == "Windows":
        cdef DWORD errorCode = GetLastError()
        return "Error Code = %d" % (errorCode)
    ELSE:
        return ""

cpdef str GetNavigateUrl(py_string url):
    # Encode local file paths so that CEF can load them correctly:
    # | some.html, some/some.html, D:\, /var, file://
    if re.search(r"^file:", url, re.I) or \
            re.search(r"^[a-zA-Z]:", url) or \
            not re.search(r"^[\w-]+:", url):

        # Function pathname2url will complain if url starts with "file://".
        # CEF may also change local urls to "file:///C:/" - three slashes.
        is_file_protocol = False
        file_prefix = ""
        file_prefixes = ["file:///", "file://"]
        for file_prefix in file_prefixes:
            if url.startswith(file_prefix):
                is_file_protocol = True
                # Remove the file:// prefix
                url = url[len(file_prefix):]
                break

        # Need to encode chinese characters in local file paths,
        # otherwise CEF will try to encode them by itself. But it
        # will fail in doing so. CEF will return the following string:
        # >> %EF%BF%97%EF%BF%80%EF%BF%83%EF%BF%A6
        # But it should be:
        # >> %E6%A1%8C%E9%9D%A2
        url = urllib_pathname2url(url)

        if is_file_protocol:
            url = "%s%s" % (file_prefix, url)

        # If it is C:\ then colon was encoded. Decode it back.
        url = re.sub(r"^([a-zA-Z])%3A", r"\1:", url)

        # Allow hash when loading urls. The pathname2url function
        # replaced hashes with "%23" (Issue 114).
        url = url.replace("%23", "#")

    return str(url)

cpdef str GetModuleDirectory():
    import re, os, platform
    if platform.system() == "Linux" and os.getenv("CEFPYTHON3_PATH"):
        # cefpython3 package __init__.py sets CEFPYTHON3_PATH.
        # When cefpython3 is installed as debian package, this
        # env variable is the only way of getting valid path.
        return os.getenv("CEFPYTHON3_PATH")
    if hasattr(sys, "frozen"):
        path = os.path.dirname(sys.executable)
    elif "__file__" in globals():
        path = os.path.dirname(os.path.realpath(__file__))
    else:
        path = os.getcwd()
    if platform.system() == "Windows":
        # On linux this regexp would give:
        # "\/home\/czarek\/cefpython\/cefpython\/cef1\/linux\/binaries"
        path = re.sub(r"[/\\]+", re.escape(os.sep), path)
    path = re.sub(r"[/\\]+$", "", path)
    return str(path)

cpdef py_bool IsFunctionOrMethod(object valueType):
    if (valueType == types.FunctionType \
            or valueType == types.MethodType \
            or valueType == types.BuiltinFunctionType \
            or valueType == types.BuiltinMethodType):
        return True
    return False
