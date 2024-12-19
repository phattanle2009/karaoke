//
//  SBStereoPannerNode.h
//  SwitchboardSDK
//
//  Created by Balazs Kiss on 2023. 03. 24..
//

#import <Foundation/Foundation.h>
#import "SBAudioProcessorNode.h"

NS_ASSUME_NONNULL_BEGIN

@interface SBStereoPannerNode : SBAudioProcessorNode

@property (nonatomic, assign) float pan;

@end

NS_ASSUME_NONNULL_END
