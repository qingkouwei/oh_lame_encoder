import opusOggEnc from 'libentry.so';

export class OpusOggEnc{
  static createLameEncoder(inSamplerate: number, inChannel: number, outBitrate: number, quality: number, outFilePath: string){
    opusOggEnc.createLameEncoder(inSamplerate, inChannel, outBitrate, quality,outFilePath);
  }
  static encodePcmDataForLame(inputBuffer: ArrayBuffer):void {
    opusOggEnc.encodePcmDataForLame(inputBuffer, ()=>{

    });
  }
  static closeLameEncoder(){
    opusOggEnc.closeOpusLameEncoder();
  }

}