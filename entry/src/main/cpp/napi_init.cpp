#include "napi/native_api.h"
#include "NapiUtil.h"
#include "LogUtil.h"
#include <lame/lame.h>
#include <sstream>
#include <string>
#define LOG_DOMAIN 0x0201
#define LOG_TAG "QingAudioEncoder"

const int32_t STR_DEFAULT_SIZE = 2048;
FILE *fout;
static lame_global_flags *lame = NULL;
static napi_value createLameEncoderNative(napi_env env, napi_callback_info info)
{
    
    size_t argc = 5;
    napi_value args[5] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int inSamplerate;
    napi_get_value_int32(env, args[0], &inSamplerate);
    
    int inChannel;
    napi_get_value_int32(env, args[1], &inChannel);
    
    int outBitrate;
    napi_get_value_int32(env, args[2], &outBitrate);
    
    int quality;
    napi_get_value_int32(env, args[3], &quality);
    
    std::string outputFilePath;
    NapiUtil::JsValueToString(env, args[4], STR_DEFAULT_SIZE, outputFilePath);
    const char* outputFilePath_ = outputFilePath.c_str();
    if (lame != NULL) {
		lame_close(lame);
		lame = NULL;
	}
	lame = lame_init();
	lame_set_in_samplerate(lame, inSamplerate);
	lame_set_num_channels(lame, inChannel);//输入流的声道
	lame_set_out_samplerate(lame, inSamplerate);
	lame_set_brate(lame, outBitrate);
	lame_set_quality(lame, quality);
	lame_init_params(lame);
    fout = fopen(outputFilePath_, "wb");
    return nullptr;
}

static napi_value encodePCMToLameNative(napi_env env, napi_callback_info info)
{
   
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    
	void* inputBuffer; 
	size_t inputLength; 
	napi_get_arraybuffer_info(env, args[0], &inputBuffer, &inputLength); 
    std::stringstream logsstr;
    logsstr << "encodeData length:" << inputLength;
    printLog(logsstr.str().c_str());
    unsigned char *outBuf = (unsigned char *)malloc(sizeof(unsigned char) * inputLength * 2);
    int result = lame_encode_buffer(lame, (const short int *)inputBuffer, (const short int*)inputBuffer,
			inputLength/2, outBuf, inputLength * 2);
    std::stringstream outlogsstr;
    outlogsstr << "out length:" << result;
    printLog(outlogsstr.str().c_str());
    if(result >0){
        fwrite(outBuf, 1, result, fout);
        free(outBuf);
    }
    
    napi_value callback = args[1];
    napi_value undefined = nullptr;
    napi_get_undefined(env, &undefined);
    napi_value callbackResult;
    napi_call_function(env, undefined, callback, 0, nullptr, &callbackResult);
    return nullptr;
}

static napi_value closeLameEncoderNative(napi_env env, napi_callback_info info)
{
    lame_close(lame);
	lame = NULL;
    fclose(fout);
    return nullptr;
}

EXTERN_C_START
static napi_value Init(napi_env env, napi_value exports)
{
    napi_property_descriptor desc[] = {
         { "createLameEncoder", nullptr, createLameEncoderNative, nullptr, nullptr, nullptr, napi_default, nullptr },
        { "encodePcmDataForLame", nullptr, encodePCMToLameNative, nullptr, nullptr, nullptr, napi_default, nullptr },
        { "closeOpusLameEncoder", nullptr, closeLameEncoderNative, nullptr, nullptr, nullptr, napi_default, nullptr },
    };
    napi_define_properties(env, exports, sizeof(desc) / sizeof(desc[0]), desc);
    return exports;
}
EXTERN_C_END

static napi_module demoModule = {
    .nm_version = 1,
    .nm_flags = 0,
    .nm_filename = nullptr,
    .nm_register_func = Init,
    .nm_modname = "entry",
    .nm_priv = ((void*)0),
    .reserved = { 0 },
};

extern "C" __attribute__((constructor)) void RegisterEntryModule(void)
{
    napi_module_register(&demoModule);
}
