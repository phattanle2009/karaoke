//
//  SBVoiceActivityDetectorNode.h
//  SwitchboardSDK
//
//  Created by Gergye Mihály on 2023. 06. 05..
//

#import <Foundation/Foundation.h>
#import "SBAudioSinkNode.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, SBVADStatus) { VoiceDetected = 0, Hangover = 1, Idle = 2 };

@interface SBVoiceActivityDetectorNode : SBAudioSinkNode

@property (nonatomic, assign) float hangoverDuration;
@property (nonatomic, assign) float gainTriggerThreshold;
@property (nonatomic, assign) float triggerDuration;
@property (nonatomic, assign, readonly) SBVADStatus status;

- (instancetype)init;

@end

NS_ASSUME_NONNULL_END
