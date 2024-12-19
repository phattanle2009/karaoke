//
//  SBBusSelectNode.h
//  SwitchboardSDK
//
//  Created by Iván Nádor on 2023. 06. 16..
//

#import <Foundation/Foundation.h>
#import "SBAudioProcessorNode.h"

NS_ASSUME_NONNULL_BEGIN

@interface SBBusSelectNode : SBAudioProcessorNode

@property (nonatomic, assign) unsigned int selectedBus;

@end

NS_ASSUME_NONNULL_END
