//
//  SBRecorderNode.h
//  SwitchboardSDK
//
//  Created by Nádor Iván on 2022. 09. 08..
//

#import <Foundation/Foundation.h>
#import "SBAudioSinkNode.h"
#import "SBCodec.h"

NS_ASSUME_NONNULL_BEGIN

@interface SBRecorderNode : SBAudioSinkNode

@property (nonatomic, assign) BOOL isRecording;

- (instancetype)init;
- (instancetype)initWithSampleRate:(uint)sampleRate numberOfChannels:(uint)numberOfChannels;

- (void)start;
- (BOOL)stop:(NSString*)recordingFilePath withFormat:(SBCodec)format;

@end

NS_ASSUME_NONNULL_END
