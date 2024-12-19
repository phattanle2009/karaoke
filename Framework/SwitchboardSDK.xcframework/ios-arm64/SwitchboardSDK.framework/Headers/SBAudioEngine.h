//
//  SBAudioEngine.h
//  SwitchboardAudioIOS
//
//  Created by Balázs Kiss on 2022. 07. 26..
//  Copyright © 2022. Synervoz Inc. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>
#import "AudioProcessorDelegate.h"
#import "SBAudioProcessor.h"

@class SBAudioGraph;
@class SBAudioEngine;
@class AudioSessionState;

NS_ASSUME_NONNULL_BEGIN

@protocol SBAudioEngineDelegate

- (void)audioEngine:(SBAudioEngine*)audioEngine inputRouteChanged:(AVAudioSessionPort)currentInputRoute;
- (void)audioEngine:(SBAudioEngine*)audioEngine outputRouteChanged:(AVAudioSessionPort)currentOutputRoute;

@end

@interface SBAudioEngine : NSObject <AudioProcessorDelegate>

@property (nonatomic, assign) BOOL microphoneEnabled;
@property (nonatomic, assign, readonly) BOOL isRunning;
@property (nonatomic, assign) BOOL voiceProcessingEnabled;
@property (nonatomic, assign) BOOL allowBluetoothA2DP;
@property (nonatomic, assign) BOOL mixWithOthersEnabled;
@property (nonatomic, strong, readonly) AVAudioSessionPort currentInputRoute;
@property (nonatomic, strong, readonly) AVAudioSessionPort currentOutputRoute;
@property (nonatomic, readonly) AudioSessionState* _Nullable lastAudioSessionState;
@property (nonatomic, weak) id<SBAudioEngineDelegate> delegate;

- (void)startAudioGraph:(SBAudioGraph*)audioGraph;
- (void)stop;

- (instancetype)initWithAudioUnitV2:(BOOL)isV2;

@end

NS_ASSUME_NONNULL_END
