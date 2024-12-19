//
//  SBResampledSourceNode.h
//  SwitchboardSDK
//
//  Created by Gergye Mihály on 2023. 07. 04..
//

#import <Foundation/Foundation.h>
#import "SBAudioSourceNode.h"

NS_ASSUME_NONNULL_BEGIN

@interface SBResampledSourceNode : SBAudioSourceNode

@property (nonatomic, strong) SBAudioSourceNode* sourceNode;
@property (nonatomic, assign) unsigned int internalSampleRate;

@end

NS_ASSUME_NONNULL_END
