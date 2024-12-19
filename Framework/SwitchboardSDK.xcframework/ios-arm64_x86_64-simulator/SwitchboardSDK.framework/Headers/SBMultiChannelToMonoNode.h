//
//  SBMultichannelToMonoNode.h
//  SwitchboardSDK
//
//  Created by Balazs Kiss on 2023. 03. 27..
//

#import <Foundation/Foundation.h>
#import "SBAudioProcessorNode.h"

NS_ASSUME_NONNULL_BEGIN

@interface SBMultiChannelToMonoNode : SBAudioProcessorNode

@property (nonatomic, assign) BOOL normalize;

@end

NS_ASSUME_NONNULL_END
