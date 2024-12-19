//
//  SBIOSAudioIO.h
//  SwitchboardSDKIOS
//
//  Created by Iván Nádor on 11/01/2024.
//

#import <AVFoundation/AVFoundation.h>

@protocol AudioProcessorDelegate;

NS_ASSUME_NONNULL_BEGIN

@class SBIOSAudioIO;

@protocol SBIOSAudioIODelegate
- (void)outputSampleRateChanged:(SBIOSAudioIO*)audioUnit sampleRate:(int)sampleRate;
@end

@interface SBIOSAudioIO : NSObject

@property (nonatomic, readonly) BOOL isRunning;
@property (nonatomic, assign) int sampleRate;
@property (nonatomic, assign) BOOL isVoiceProcessingEnabled;
@property (nonatomic, nullable) id<AudioProcessorDelegate> audioDelegate;
@property (nonatomic, weak) id<SBIOSAudioIODelegate> delegate;

- (BOOL)configureWithVoiceProcessingEnabled:(BOOL)voiceProcessingEnabled
                    microphoneAccessEnabled:(BOOL)microphoneAccessEnabled
                                 sampleRate:(float)sampleRate
                           numberOfChannels:(int)numberOfChannels;
- (BOOL)start;
- (BOOL)stop;

@end

NS_ASSUME_NONNULL_END
