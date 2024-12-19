//
//  SBSubgraphProcessorNode.h
//  SwitchboardSDK
//
//  Created by Balazs Kiss on 2023. 05. 30..
//

#import <Foundation/Foundation.h>
#import "SBAudioProcessorNode.h"

@class SBAudioGraph;

NS_ASSUME_NONNULL_BEGIN

@interface SBSubgraphProcessorNode : SBAudioProcessorNode

@property (nonatomic, strong) SBAudioGraph* audioGraph;

@end

NS_ASSUME_NONNULL_END
