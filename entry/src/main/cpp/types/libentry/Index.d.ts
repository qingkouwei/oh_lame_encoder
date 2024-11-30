export const createLameEncoder:(inSamplerate: number, inChannel: number, outBitrate: number, quality: number, outFilePath:string) => void;
export function encodePcmDataForLame(intputBuffer: ArrayBuffer, callback:() => void): void;
export function encodePcmDataForLame(intputBuffer: ArrayBuffer): Promise<void>;
export const closeOpusLameEncoder:() => void;