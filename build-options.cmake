#-------------------------------------------------------------------------------------
# This is part of CMake configuration file for building makefiles and installfiles
# for the Lomse library
#-------------------------------------------------------------------------------------
# This module is for defining build options and creating the
# include file "lomse_config.h"
#
# Various options that the user can select (var, msg, default value).
# Values can be changed directly in the CMake GUI or through
# the command line by prefixing a variable's name with '-D':
# i.e.:    cmake -DLOMSE_DEBUG=ON
#
#-------------------------------------------------------------------------------------

# command line build options
if(DEFINED LOMSE_ENABLE_DEBUG_LOGS)
  option( LOMSE_ENABLE_DEBUG_LOGS  "Enable debug logs. Doesn't require debug build" ${LOMSE_ENABLE_DEBUG_LOGS})
else()
  option( LOMSE_ENABLE_DEBUG_LOGS  "Enable debug logs. Doesn't require debug build" OFF)
endif()

if(DEFINED LOMSE_DEBUG)
    option( LOMSE_DEBUG  "Debug build, with debug symbols" ${LOMSE_DEBUG})
else()
    option( LOMSE_DEBUG  "Debug build, with debug symbols" OFF)
endif()

if(DEFINED LOMSE_COMPATIBILITY_LDP_1_5)
    option( LOMSE_COMPATIBILITY_LDP_1_5  "Enable compatibility for LDP v1.5" ${LOMSE_COMPATIBILITY_LDP_1_5})
else()
    option( LOMSE_COMPATIBILITY_LDP_1_5  "Enable compatibility for LDP v1.5" ON)
endif()


#libraries to build
option(LOMSE_BUILD_STATIC_LIB "Build the static library" OFF)
option(LOMSE_BUILD_SHARED_LIB "Build the shared library" ON)

#Build the test units runner program 'testlib'
option(LOMSE_BUILD_TESTS "Build testlib program" ON)

#run unit tests after building the library
option(LOMSE_RUN_TESTS "Run tests after building" OFF)
if (LOMSE_RUN_TESTS)
    set(LOMSE_BUILD_TESTS ON)
endif()      

#Build the example-1 program that uses the library
option(LOMSE_BUILD_EXAMPLE "Build the example-1 program" OFF)


message("Build the static library = ${LOMSE_BUILD_STATIC_LIB}")
message("Build the shared library = ${LOMSE_BUILD_SHARED_LIB}")
message("Build testlib program = ${LOMSE_BUILD_TESTS}")
message("Run tests after building = ${LOMSE_RUN_TESTS}")
message("Create Debug build = ${LOMSE_DEBUG}")
message("Enable debug logs = ${LOMSE_ENABLE_DEBUG_LOGS}")
message("Compatibility for LDP v1.5 = ${LOMSE_COMPATIBILITY_LDP_1_5}")



# set up configuration variables for lomse_config.h
#------------------------------------------------------

# build type (this variables affects lomse_config.h and are used
# in lomse_build_options.h. But there is are two problems:
# 1. Both builds (static and shared) can be built in the same cmake command.
#    And in this case there is (currently) a single lomse_config.h file
#    common to both build.
# 2. When defining USED_DLL=1 there are compilation errors.
# So, until further investigation, I have commented out this.
#if (LOMSE_BUILD_STATIC_LIB)
    set( LOMSE_USE_DLL "0")
    set( LOMSE_CREATE_DLL "0")
#else()
#    set( LOMSE_USE_DLL "1")
#    set( LOMSE_CREATE_DLL "1")
#endif()

# version. Extract values from lomse_version.h header file
file(STRINGS ${LOMSE_ROOT_DIR}/include/lomse_version.h LOMSE_VERSION_LIST)
list (GET LOMSE_VERSION_LIST 5 MAJOR_LINE)
list (GET LOMSE_VERSION_LIST 6 MINOR_LINE)
list (GET LOMSE_VERSION_LIST 7 PATCH_LINE)
list (GET LOMSE_VERSION_LIST 8 SHA1_LINE)
string(REGEX REPLACE "\#define LOMSE_VERSION_MAJOR    " "" LOMSE_VERSION_MAJOR "${MAJOR_LINE}")
string(REGEX REPLACE "\#define LOMSE_VERSION_MINOR    " "" LOMSE_VERSION_MINOR "${MINOR_LINE}")
string(REGEX REPLACE "\#define LOMSE_VERSION_PATCH    " "" LOMSE_VERSION_PATCH "${PATCH_LINE}")
string(REGEX REPLACE "\#define LOMSE_VERSION_SHA1     " "" LOMSE_VERSION_SHA1  "${SHA1_LINE}")

message ("major = '${LOMSE_VERSION_MAJOR}'") 
message ("minor = '${LOMSE_VERSION_MINOR}'") 
message ("patch = '${LOMSE_VERSION_PATCH}'") 
message ("sha1  = '${LOMSE_VERSION_SHA1}'") 


#build version string for installer name
set(LOMSE_PACKAGE_VERSION "${LOMSE_VERSION_MAJOR}.${LOMSE_VERSION_MINOR}.${LOMSE_VERSION_PATCH}" )

set(LOMSE_VERSION "${LOMSE_PACKAGE_VERSION}" )
message ("version = '${LOMSE_VERSION}'") 
message ("version string = '${LOMSE_PACKAGE_VERSION}'") 


# platform
if(WIN32)
    set( LOMSE_PLATFORM_WIN32  "1")
    set( LOMSE_PLATFORM_UNIX   "0")
elseif(UNIX)
    set( LOMSE_PLATFORM_WIN32  "0")
    set( LOMSE_PLATFORM_UNIX   "1")
endif()

# compiler
if(MSVC)
    set( LOMSE_COMPILER_MSVC  "1")
    set( LOMSE_COMPILER_GCC   "0")
elseif(CMAKE_COMPILER_IS_GNUCC)
    set( LOMSE_COMPILER_MSVC  "0")
    set( LOMSE_COMPILER_GCC   "1")
endif()


# paths for tests
set( TESTLIB_SCORES_PATH     "\"${LOMSE_ROOT_DIR}/test-scores/\"" )
set( TESTLIB_FONTS_PATH      "\"${LOMSE_ROOT_DIR}/fonts/\"" )

# path to fonts (will be hardcoded in lomse library, so *MUST* be the
# path in which Lomse standard fonts will be installed)
set( LOMSE_FONTS_PATH   "\"${FONTS_PATH}/\"" )



# names for libraries and execs.
#-------------------------------------------------------------------------------------
if( WIN32 )
    set( CMAKE_STATIC_LIBRARY_PREFIX "" )
    set( CMAKE_STATIC_LIBRARY_SUFFIX ".lib" )
    set( CMAKE_SHARED_LIBRARY_PREFIX "" )
    set( CMAKE_SHARED_LIBRARY_SUFFIX ".dll" )
    set( CMAKE_EXECUTABLE_SUFFIX ".exe" )
    set( LOMSE_LIBNAME lomse.lib )
elseif( UNIX )
    set( CMAKE_STATIC_LIBRARY_PREFIX "lib" )
    set( CMAKE_STATIC_LIBRARY_SUFFIX ".a" )
    set( CMAKE_SHARED_LIBRARY_PREFIX "lib" )
    set( CMAKE_SHARED_LIBRARY_SUFFIX ".so" )
    set( CMAKE_EXECUTABLE_SUFFIX "" )
    set( LOMSE_LIBNAME liblomse.so )
endif()


#define a header file to pass CMake settings to source code
configure_file(
    "${LOMSE_ROOT_DIR}/lomse_config.h.cmake"
    "${CMAKE_CURRENT_BINARY_DIR}/lomse_config.h"
)


