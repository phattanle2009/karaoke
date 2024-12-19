//
//  SBMusicDuckingV2Node.h
//  SwitchboardSDK
//
//  Created by Iván Nádor on 2023. 09. 21..
//

#import "SBAudioProcessorNode.h"

NS_ASSUME_NONNULL_BEGIN

@interface SBMusicDuckingV2Node : SBAudioProcessorNode

@property (nonatomic, assign) float duckingAmount;
@property (nonatomic, assign) float activationThreshold;
@property (nonatomic, assign) float attackSeconds;
@property (nonatomic, assign) float releaseSeconds;
@property (nonatomic, assign) float holdSeconds;
@property (nonatomic, assign) BOOL forcedDuckingEnabled;
@property (nonatomic, assign) bool mixDuckingSignal;

@end

NS_ASSUME_NONNULL_END
