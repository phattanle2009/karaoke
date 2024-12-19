//
//  SBUsageTrackerNode.h
//  SwitchboardSDK
//
//  Created by Gergye Mihály on 09/01/2024.
//

#import <Foundation/Foundation.h>
#import "SBAudioProcessorNode.h"

NS_ASSUME_NONNULL_BEGIN

@interface SBUsageTrackerNode : SBAudioProcessorNode

- (instancetype)init:(NSString*)productID;

@end

NS_ASSUME_NONNULL_END
