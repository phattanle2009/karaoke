//
//  SBMuteNode.h
//  SwitchboardSDK
//
//  Created by Balazs Kiss on 2023. 03. 23..
//

#import <Foundation/Foundation.h>
#import "SBAudioProcessorNode.h"

NS_ASSUME_NONNULL_BEGIN

@interface SBMuteNode : SBAudioProcessorNode

@property (nonatomic, assign, getter=isMuted) BOOL muted;

@end

NS_ASSUME_NONNULL_END
