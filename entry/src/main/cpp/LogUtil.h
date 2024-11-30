//
// Created on 2024/8/20.
//
// Node APIs are not fully supported. To solve the compilation error of the interface cannot be found,
// please include "napi/native_api.h".

#ifndef BEIKE_BASE_AUDIO_LOGUTIL_H
#define BEIKE_BASE_AUDIO_LOGUTIL_H
#define LOG_DOMAIN 0x0201
#define LOG_TAG "QingAudioEncoder"
#include "hilog/log.h"
#define ENABLELOG true

static void printLog(const char* log){
    if(ENABLELOG){
        OH_LOG_Print(LOG_APP,LOG_DEBUG, LOG_DOMAIN, LOG_TAG, "%{public}s", log);
    }
}

#define LOG_MAX_SIZE 200
#define DEMO_CHECK_AND_RETURN_RET_LOG(cond, ret, fmt, ...)                                                             \
    do {                                                                                                               \
        if (!(cond)) {                                                                                                 \
            char ch[LOG_MAX_SIZE];                                                                                     \
            (void)snprintf(ch, LOG_MAX_SIZE, fmt, ##__VA_ARGS__);                                                     \
            (void)printLog(ch);                                                                                  \
            return ret;                                                                                                \
        }                                                                                                              \
    } while (0)

#define DEMO_CHECK_AND_RETURN_LOG(cond, fmt, ...)                                                                      \
    do {                                                                                                               \
        if (!(cond)) {                                                                                                 \
            char ch[LOG_MAX_SIZE];                                                                                     \
            (void)snprintf(ch, LOG_MAX_SIZE, fmt, ##__VA_ARGS__);                                                     \
            (void)printLog(ch);                                                                                        \
            return;                                                                                                    \
        }                                                                                                              \
    } while (0)

#define DEMO_CHECK_AND_BREAK_LOG(cond, fmt, ...)                                                                       \
    if (!(cond)) {                                                                                                     \
        char ch[LOG_MAX_SIZE];                                                                                         \
        (void)snprintf(ch, LOG_MAX_SIZE, fmt, ##__VA_ARGS__);                                                         \
        (void)printLog(ch);                                                                                            \
        break;                                                                                                         \
    }

#define DEMO_CHECK_AND_CONTINUE_LOG(cond, fmt, ...)                                                                    \
    if (!(cond)) {                                                                                                     \
        char ch[LOG_MAX_SIZE];                                                                                         \
        (void)snprintf(ch, LOG_MAX_SIZE, fmt, ##__VA_ARGS__);                                                         \
        (void)printLog(ch);                                                                                            \
        continue;                                                                                                      \
    }
#endif //BEIKE_BASE_AUDIO_LOGUTIL_H
