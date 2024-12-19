//
//  SBParameter.h
//  SwitchboardSDK
//
//  Created by Balazs Kiss on 2023. 05. 26..
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, SBParameterType) { SBParameterTypeFloat, SBParameterTypeBool, SBParameterTypeString };

@interface SBParameter : NSObject

@property (nonatomic, assign, readonly) void* parameter;
@property (nonatomic, strong, readonly) NSString* ID;
@property (nonatomic, strong, readonly) NSString* name;
@property (nonatomic, strong, readonly) NSString* description;
@property (nonatomic, assign, readonly) SBParameterType type;

- (instancetype)initWithParameter:(void*)parameter;

@end

NS_ASSUME_NONNULL_END
