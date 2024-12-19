//
//  SBFloatParameter.h
//  SwitchboardSDK
//
//  Created by Balazs Kiss on 2023. 05. 26..
//

#import <Foundation/Foundation.h>
#import "SBParameter.h"

NS_ASSUME_NONNULL_BEGIN

@interface SBFloatParameter : SBParameter

@property (nonatomic, assign) float value;
@property (nonatomic, assign, readonly) float minimumValue;
@property (nonatomic, assign, readonly) float maximumValue;

- (instancetype)initWithParameter:(void*)parameter;

@end

NS_ASSUME_NONNULL_END
