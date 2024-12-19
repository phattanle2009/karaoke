//
//  SBMusicDuckingNode.h
//  SwitchboardSDK
//
//  Created by Balazs Kiss on 2023. 05. 03..
//

#import <Foundation/Foundation.h>
#import "SBAudioProcessorNode.h"
#import "SBDuckingCompressor.h"

NS_ASSUME_NONNULL_BEGIN

@interface SBMusicDuckingNode : SBAudioProcessorNode

@property (nonatomic, assign) float duckReleaseAmount;
@property (nonatomic, assign) float numSecondsToHoldDucking;
@property (nonatomic, assign) bool mixDuckingSignal;

- (float)duckingAmount:(uint)duckingSignalIndex;
- (void)setDuckingAmount:(float)duckingAmount forDuckingSignal:(uint)duckingSignalIndex;
- (void)setCompressor:(SBDuckingCompressor*)compressor;

@end

NS_ASSUME_NONNULL_END
