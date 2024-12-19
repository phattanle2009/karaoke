//
//  AudioProcessorDelegate.h
//  SwitchboardSDKIOS
//
//  Created by Iván Nádor on 15/01/2024.
//

NS_ASSUME_NONNULL_BEGIN

@protocol AudioProcessorDelegate

- (bool)audioProcessingCallback:(float* _Nonnull* _Nonnull)buffers
                  inputChannels:(unsigned int)inputChannels
                 outputChannels:(unsigned int)outputChannels
                numberOfSamples:(unsigned int)numberOfSamples
                     samplerate:(unsigned int)samplerate
                       hostTime:(UInt64)hostTime;

@end

NS_ASSUME_NONNULL_END
