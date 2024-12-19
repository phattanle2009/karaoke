//
//  SBUIntParameter.h
//  SwitchboardSDK
//
//  Created by Iván Nádor on 2023. 07. 11..
//

#import <Foundation/Foundation.h>
#import "SBParameter.h"

NS_ASSUME_NONNULL_BEGIN

@interface SBUIntParameter : SBParameter

@property (nonatomic, assign) unsigned int value;
@property (nonatomic, assign, readonly) unsigned int minimumValue;
@property (nonatomic, assign, readonly) unsigned int maximumValue;

- (instancetype)initWithParameter:(void*)parameter;

@end

NS_ASSUME_NONNULL_END
