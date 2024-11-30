//
// Created on 2024/8/14.
//
// Node APIs are not fully supported. To solve the compilation error of the interface cannot be found,
// please include "napi/native_api.h".

#ifndef NATIVEAUDIODEMO_NAPIUTIL_H
#define NATIVEAUDIODEMO_NAPIUTIL_H
#include <string>
#include <napi/native_api.h>
class NapiUtil {
public:
    static void JsValueToString(const napi_env &env, const napi_value &value, const int32_t bufLen,
        std::string &target);
    static napi_value SetNapiCallInt32(const napi_env & env,  const int32_t intValue);
    static napi_value SetNapiCallBool(const napi_env env, bool value);
    static int StringToInt(std::string value);
    static int StringToLong(std::string value);
    static float StringToFloat(std::string value);
    static bool StringToBool(std::string value);
};

#endif //NATIVEAUDIODEMO_NAPIUTIL_H
