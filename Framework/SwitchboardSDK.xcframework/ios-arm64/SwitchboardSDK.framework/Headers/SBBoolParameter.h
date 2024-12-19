//
//  SBBoolParameter.h
//  SwitchboardSDK
//
//  Created by Balazs Kiss on 2023. 05. 26..
//

#import <Foundation/Foundation.h>
#import "SBParameter.h"

NS_ASSUME_NONNULL_BEGIN

@interface SBBoolParameter : SBParameter

@property (nonatomic, assign) BOOL value;

- (instancetype)initWithParameter:(void*)parameter;

@end

NS_ASSUME_NONNULL_END
