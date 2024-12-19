//
//  SBGainNode.h
//  SwitchboardSDK
//
//  Created by Balazs Kiss on 2023. 03. 23..
//

#import <Foundation/Foundation.h>
#import "SBAudioProcessorNode.h"

NS_ASSUME_NONNULL_BEGIN

@interface SBGainNode : SBAudioProcessorNode

@property (nonatomic, assign) float gain;

@end

NS_ASSUME_NONNULL_END
