//
//  SBIntParameter.h
//  SwitchboardSDK
//
//  Created by Iván Nádor on 2023. 07. 11..
//

#import <Foundation/Foundation.h>
#import "SBParameter.h"

NS_ASSUME_NONNULL_BEGIN

@interface SBIntParameter : SBParameter

@property (nonatomic, assign) int value;
@property (nonatomic, assign, readonly) int minimumValue;
@property (nonatomic, assign, readonly) int maximumValue;

- (instancetype)initWithParameter:(void*)parameter;

@end

NS_ASSUME_NONNULL_END
