//
//  SBResampledSinkNode.h
//  SwitchboardSDK
//
//  Created by Gergye Mihály on 2023. 07. 04..
//

#import <Foundation/Foundation.h>
#import "SBAudioSinkNode.h"

NS_ASSUME_NONNULL_BEGIN

@interface SBResampledSinkNode : SBAudioSinkNode

@property (nonatomic, strong) SBAudioSinkNode* sinkNode;
@property (nonatomic, assign) unsigned int internalSampleRate;

@end

NS_ASSUME_NONNULL_END
