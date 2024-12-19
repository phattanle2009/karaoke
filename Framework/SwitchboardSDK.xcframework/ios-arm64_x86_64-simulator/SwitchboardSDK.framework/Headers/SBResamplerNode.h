//
//  SBResamplerNode.h
//  SwitchboardSDK
//
//  Created by Balazs Kiss on 2023. 03. 16..
//

#import <Foundation/Foundation.h>
#import "SBAudioProcessorNode.h"

NS_ASSUME_NONNULL_BEGIN

@interface SBResamplerNode : SBAudioProcessorNode

@property (nonatomic, assign) unsigned int inputSampleRate;
@property (nonatomic, assign) unsigned int outputSampleRate;

@end

NS_ASSUME_NONNULL_END
