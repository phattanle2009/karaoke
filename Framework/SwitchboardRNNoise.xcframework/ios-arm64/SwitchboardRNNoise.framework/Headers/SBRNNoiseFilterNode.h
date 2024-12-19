//
//  SBRNNoiseFilterNode.h
//  SwitchboardRNNoise
//
//  Created by Balázs Kiss on 2022. 10. 31..
//

#import <Foundation/Foundation.h>
#import <SwitchboardSDK/SBAudioProcessorNode.h>

NS_ASSUME_NONNULL_BEGIN

@interface SBRNNoiseFilterNode : SBAudioProcessorNode

@property (nonatomic, assign) BOOL isEnabled;

@end

NS_ASSUME_NONNULL_END
