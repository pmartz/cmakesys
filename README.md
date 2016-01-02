# CMakeSys

CMakeSys is a skeleton CMake project template. When you are sterting a new CMake-based project, use the "cmsproject" directory as a starting point.

The skeleton project contains the following features:

1. The project builds and runs cross platform (Linux, MS Visual Studio 2010).
2. Built-in support for optionally generated Doxygen documentation.
3. Project version numbering controlled by top-level CMakeLists.txt. A project version.h file is automatically generated by CMake.
4. Generation of CMake auto-find tools so that downstream projects can easily find this project. Support for flagpoll.
5. Stub code for a library, an executable, and a CTest regression test.
6. Support for static or dynamic (shared lib) linking.
