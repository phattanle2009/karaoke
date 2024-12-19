//
//  SBSubgraphSinkNode.h
//  SwitchboardSDK
//
//  Created by Balazs Kiss on 2023. 05. 30..
//

#import <Foundation/Foundation.h>
#import "SBAudioSinkNode.h"

NS_ASSUME_NONNULL_BEGIN

@interface SBSubgraphSinkNode : SBAudioSinkNode

@property (nonatomic, strong) SBAudioGraph* audioGraph;

@end

NS_ASSUME_NONNULL_END
