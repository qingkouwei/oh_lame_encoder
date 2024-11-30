import { abilityAccessCtrl, common, Permissions } from '@kit.AbilityKit';
import { audio } from '@kit.AudioKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { fileIo } from '@kit.CoreFileKit';
import hilog from '@ohos.hilog';
import keencoder from 'libentry.so';
import { Player } from '../audio/Player';

const TAG = 'AudioCapturerDemo';

class Options {
  offset?: number;
  length?: number;
}

let context = getContext(this);
let bufferSize: number = 0;
let isRecording: boolean = false;
let audioCapturer: audio.AudioCapturer | undefined = undefined;
let audioStreamInfo: audio.AudioStreamInfo = {
  samplingRate: audio.AudioSamplingRate.SAMPLE_RATE_16000, // 采样率
  channels: audio.AudioChannel.CHANNEL_1, // 通道
  sampleFormat: audio.AudioSampleFormat.SAMPLE_FORMAT_S16LE, // 采样格式
  encodingType: audio.AudioEncodingType.ENCODING_TYPE_RAW // 编码格式
}
let audioCapturerInfo: audio.AudioCapturerInfo = {
  source: audio.SourceType.SOURCE_TYPE_MIC, // 音源类型
  capturerFlags: 0 // 音频采集器标志
}
let audioCapturerOptions: audio.AudioCapturerOptions = {
  streamInfo: audioStreamInfo,
  capturerInfo: audioCapturerInfo
}

let path = getContext().cacheDir;
let filePath = path + '/StarWars10s-2C-48000-4SW.wav';
let file: fileIo.File = fileIo.openSync(filePath, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);

// 将 leftData 和 rightData 转换为 ArrayBuffer
function convertToBuffer(data: number[]): Uint16Array {
  const buffer = new Uint16Array(data.length);
  // const buffer = new ArrayBuffer(data.length * 2); // 每个 short 占用 2 个字节
  // const view = new DataView(buffer);

  for (let i = 0; i < data.length; i++) {
    buffer[i] = data[i];// true 表示使用小端字节序
  }

  return buffer;
}

let readDataCallback = (buffer: ArrayBuffer) => {


  const readSize = buffer.byteLength;
  hilog.info(0, TAG,"readDataCallback：" + readSize);
  keencoder.encodePcmDataForLame(buffer);
  /*const mPCMBuffer = new Int16Array(buffer);

  const leftData: number[] = new Array(readSize / 2).fill(0);
  const rightData: number[] = new Array(readSize / 2).fill(0);

  for (let i = 0; i < readSize / 2; i += 2) {
    leftData[i] = mPCMBuffer[2 * i];

    if (2 * i + 1 < readSize) {
      leftData[i + 1] = mPCMBuffer[2 * i + 1];
    }

    if (2 * i + 2 < readSize) {
      rightData[i] = mPCMBuffer[2 * i + 2];
    }

    if (2 * i + 3 < readSize) {
      rightData[i + 1] = mPCMBuffer[2 * i + 3];
    }
  }
  const mp3Buffer = new Uint8Array(readSize);
  // const resultSize = LameUtils.encodePCMData(convertToBuffer(leftData), convertToBuffer(rightData), readSize/2/2, mp3Buffer)
  hilog.info(0, TAG,"mp3buffersize：" + resultSize);
  let options: Options = {
    offset: bufferSize,
    length: resultSize
  }
  // fileIo.writeSync(file.fd, mp3Buffer, options);
  bufferSize += resultSize;*/
}

// 初始化，创建实例，设置监听事件
function init() {
  audio.createAudioCapturer(audioCapturerOptions, (err, capturer) => { // 创建AudioCapturer实例
    if (err) {
      hilog.info(0, TAG, `Invoke createAudioCapturer failed, code is ${err.code}, message is ${err.message}`);
      return;
    }
    hilog.info(0, TAG,`${TAG}: create AudioCapturer success`);
    audioCapturer = capturer;
    if (audioCapturer !== undefined) {
      (audioCapturer as audio.AudioCapturer).on('readData', readDataCallback);
    }
    if (audioCapturer !== undefined) {
      hilog.info(0, TAG,`${TAG}: create capture`);
      let stateGroup = [audio.AudioState.STATE_PREPARED, audio.AudioState.STATE_PAUSED, audio.AudioState.STATE_STOPPED];
      if (stateGroup.indexOf((audioCapturer as audio.AudioCapturer).state.valueOf()) === -1) { // 当且仅当状态为STATE_PREPARED、STATE_PAUSED和STATE_STOPPED之一时才能启动采集
        hilog.info(0, TAG,`${TAG}: start failed`);
        return;
      }

      hilog.info(0, TAG,`${TAG}: start capture`);
      // 启动采集
      (audioCapturer as audio.AudioCapturer).start((err: BusinessError) => {
        if (err) {
          hilog.info(0, TAG,'Capturer start failed.');
        } else {
          hilog.info(0, TAG,'Capturer start success.');
        }
      });
    }


  });
}

// 开始一次音频采集
function start() {
  filePath = `${getContext().cacheDir}/${new Date().getTime()}.mp3`;
  keencoder.createLameEncoder(16000,1, 128000, 0, filePath);
  init();

}

// 停止采集
function stop() {
  if (audioCapturer !== undefined) {
    // 只有采集器状态为STATE_RUNNING或STATE_PAUSED的时候才可以停止
    if ((audioCapturer as audio.AudioCapturer).state.valueOf() !== audio.AudioState.STATE_RUNNING && (audioCapturer as audio.AudioCapturer).state.valueOf() !== audio.AudioState.STATE_PAUSED) {
      console.info('Capturer is not running or paused');
      return;
    }

    //停止采集
    (audioCapturer as audio.AudioCapturer).stop((err: BusinessError) => {
      if (err) {
        console.error('Capturer stop failed.');
      } else {
        fileIo.close(file);
        console.info('Capturer stop success.');
      }
    });
  }
  keencoder.closeOpusLameEncoder();
}

// 销毁实例，释放资源
function release() {
  if (audioCapturer !== undefined) {
    // 采集器状态不是STATE_RELEASED或STATE_NEW状态，才能release
    if ((audioCapturer as audio.AudioCapturer).state.valueOf() === audio.AudioState.STATE_RELEASED || (audioCapturer as audio.AudioCapturer).state.valueOf() === audio.AudioState.STATE_NEW) {
      console.info('Capturer already released');
      return;
    }

    //释放资源
    (audioCapturer as audio.AudioCapturer).release((err: BusinessError) => {
      if (err) {
        console.error('Capturer release failed.');
      } else {
        console.info('Capturer release success.');
      }
    });
  }
}


const permissions: Array<Permissions> = ['ohos.permission.MICROPHONE'];
// 使用UIExtensionAbility：将common.UIAbilityContext 替换为common.UIExtensionContext
function reqPermissionsFromUser(permissions: Array<Permissions>, context: common.UIAbilityContext): void {
  let atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
  // requestPermissionsFromUser会判断权限的授权状态来决定是否唤起弹窗
  atManager.requestPermissionsFromUser(context, permissions).then((data) => {
    hilog.info(0, TAG ,"requestPermissionsFromUser result");
    let grantStatus: Array<number> = data.authResults;
    let length: number = grantStatus.length;
    for (let i = 0; i < length; i++) {
      if (grantStatus[i] === 0) {
        // 用户授权，可以继续访问目标操作
      } else {
        // 用户拒绝授权，提示用户必须授权才能访问当前页面的功能，并引导用户到系统设置中打开相应的权限
        return;
      }
    }
    // 授权成功
  }).catch((err: BusinessError) => {
    hilog.info(0, TAG ,`Failed to request permissions from user. Code is ${err.code}, message is ${err.message}`);
    console.error(`Failed to request permissions from user. Code is ${err.code}, message is ${err.message}`);
  })
}

@Entry
@Component
struct Index {
  @State message: string = 'Lame录音编码测试';

  build() {
    Column() {
      Text(this.message)
        .fontSize(30)
        .fontWeight(FontWeight.Bold)
      Button("开始录制")
        .fontSize(25)
        .fontWeight(FontWeight.Bold)
        .onClick(()=>{
          start();
        })
      Button("结束录制")
        .fontSize(25)
        .fontWeight(FontWeight.Bold)
        .onClick(()=>{
          stop();
        })
        .margin({top:20})
      Button("播放音频")
        .fontSize(25)
        .fontWeight(FontWeight.Bold)
        .onClick(()=>{
          this.play();
        })
        .margin({top:20})
    }
    .height('100%')
    .width('100%')
  }
  aboutToAppear() {
    hilog.info(0, TAG ,"aboutToAppear");
    // 使用UIExtensionAbility：将common.UIAbilityContext 替换为common.UIExtensionContext
    const context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
    reqPermissionsFromUser(permissions, context);
  }
  aboutToDisappear(): void {
    release();
  }

  private play() {
      new Player().avPlayerUrlDemo(filePath);
  }
}