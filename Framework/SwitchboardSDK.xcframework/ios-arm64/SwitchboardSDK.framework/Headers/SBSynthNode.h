//
//  SBSynthNode.h
//  SwitchboardSDK
//
//  Created by Iván Nádor on 2023. 09. 20..
//

#import <Foundation/Foundation.h>
#import "SBAudioSourceNode.h"

NS_ASSUME_NONNULL_BEGIN

@interface SBSynthNode : SBAudioSourceNode

@property (nonatomic, assign) float frequency;
@property (nonatomic, assign) float attackSeconds;
@property (nonatomic, assign) float decaySeconds;
@property (nonatomic, assign) float releaseSeconds;
@property (nonatomic, assign) float peakLevel;
@property (nonatomic, assign) float sustainLevel;

- (void)triggerSynth;
- (void)releaseSynth;

@end

NS_ASSUME_NONNULL_END
