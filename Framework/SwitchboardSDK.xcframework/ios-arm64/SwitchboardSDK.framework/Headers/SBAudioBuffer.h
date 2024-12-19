//
//  SBAudioBuffer.h
//  SwitchboardSDK
//
//  Created by Balazs Kiss on 08/03/2024.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SBAudioBuffer : NSObject

@property (nonatomic, assign, readonly) void* audioBuffer;

@property (nonatomic, assign, readonly) uint numberOfChannels;

@property (nonatomic, assign) uint numberOfFrames;

@property (nonatomic, assign) BOOL isInterleaved;

@property (nonatomic, assign) uint sampleRate;

- (instancetype)initWithNumberOfChannels:(uint)numberOfChannels
                          numberOfFrames:(uint)numberOfFrames
                             interleaved:(BOOL)isInterleaved
                              sampleRate:(uint)sampleRate
                                    data:(float**)data;

- (float)getSampleForChannel:(uint)channel sample:(uint)sample;

- (void)setSampleForChannel:(uint)channel sample:(uint)sample value:(float)value;

@end

NS_ASSUME_NONNULL_END
