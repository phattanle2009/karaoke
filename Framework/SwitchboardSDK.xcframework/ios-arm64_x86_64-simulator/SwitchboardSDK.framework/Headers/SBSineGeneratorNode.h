//
//  SBSineGeneratorNode.h
//  SwitchboardSDK
//
//  Created by Balázs Kiss on 2022. 07. 27..
//

#import <Foundation/Foundation.h>
#import "SBAudioSourceNode.h"

NS_ASSUME_NONNULL_BEGIN

@interface SBSineGeneratorNode : SBAudioSourceNode

@property (nonatomic, assign) float frequency;
@property (nonatomic, assign) float amplitude;

@end

NS_ASSUME_NONNULL_END
