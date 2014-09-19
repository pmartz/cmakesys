.. _examples: http://pmartz.github.io/cmakesys/examples

Components
==========
This section provides brief overviews of the main components of CMakeSys.
You can browse the examples_ for more in-depth demonstations.

.. note::

   This is a note section! You can use these sections to write interesting
   bits of information that Sphinx will put into its own section.

Project Name
------------
- Invoke cmake project() macro.
- Define upper-case project name variable.

Project Config
--------------
- Make custom project setting available in a Config.h file.E.g.: Add a cpp
  define to indicate the project was built with certain optional dependencies, or
  for certain architectures, or other custom settings.
- Add a cpp define to indicate the project was built with certain optional
  dependencies, or for certain architectures, or other custom settings.

Version Vumber
--------------
- Single point control of project version number.
- Maintains project Version.h file.
- Supports maj.min.sub format (eg 2.3.1).
- Define CMake and CPP macros for version# based on project name
   * E.g.: OAGWORKS_VERSION_MAJOR, OAGWORKS_VERSION_MINOR

Doxygen/Sphinx
--------------
- If Doxygen is found, sets up Documentation build target.
- Maintains project-specific Doxyfile.

Platform-specific Controls
--------------------------
- Windows:
  - Puts .exes and .dlls in the same output directory.
  - Allows enumeration of warnings to disable.
  - Adds the /MP compiler option with a cmake variable to control it.
  - VS folder support.
  - Debug postfix support (and other build config postfix).
- Linux
- OSX
- Android is a v2.0 feature.
- iOS is a v2.0 feature.

Dependencies
------------
- The goal is to make it easy to enumerate the required and optional dependencies.
- Convenience macro to specify deps.
- Additional support for our commonly used dependencies (Boost, GDAL, etc.) as needed.
  - E.g.: DirectX requires a cmake variable to specify x64 builds.
  - E.g.: If boost is found, we'll set a BOOST_FOUND variable.
- New Find<dep>.cmake files, as needed.

Libraries
---------
- Shared library builds will be supported.
- Static should be supported but this could be bumped back to v2.0 if it's too difficult.
  - The goal: For static builds, .exe link needs everything.

Executables
-----------
- Support to build different exe types.
  - E.g.: test, example, app (Windows: include in project label)

Plugins
-------
- Support for building OSG-style plugins.

ctest
-----
- Adds a cmake variable so that building of regression test is optional.

Installation
------------
- Installing the data directory is optional.
- Windows: Installing pdb files is optional.
- Downstream project support (creates "Find<project>.cmake" file).

