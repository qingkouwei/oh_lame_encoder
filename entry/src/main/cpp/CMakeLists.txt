# the minimum version of CMake.
cmake_minimum_required(VERSION 3.5.0)
project(encoder)

set(NATIVERENDER_ROOT_PATH ${CMAKE_CURRENT_SOURCE_DIR})

if(DEFINED PACKAGE_FIND_FILE)
    include(${PACKAGE_FIND_FILE})
endif()

set(distribution_DIR ${CMAKE_CURRENT_SOURCE_DIR}/../../../libs)
add_library(lib-lame SHARED IMPORTED)
set_target_properties(lib-lame PROPERTIES IMPORTED_LOCATION
        ${distribution_DIR}/${OHOS_ARCH}/libmp3lame.so.0)

set(libs_include_lame_include_DIR ../../../libs/include)

include_directories(
        ${libs_include_lame_include_DIR}
        ${NATIVERENDER_ROOT_PATH}
        )

add_library(entry SHARED
                napi_init.cpp
                NapiUtil.cpp)
target_link_libraries(entry PUBLIC
                    libace_napi.z.so
                    lib-lame
                     )
target_link_libraries(entry PUBLIC libhilog_ndk.z.so)
add_definitions(-DOUTSIDE_SPEEX -DOPUS_BUILD -DSTDC_HEADERS -DVAR_ARRAYS)