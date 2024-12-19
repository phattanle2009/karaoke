//
//  SBAudioNode.h
//  SwitchboardSDK
//
//  Created by Balázs Kiss on 2022. 07. 26..
//

#import <Foundation/Foundation.h>
#import "SBParameter.h"

NS_ASSUME_NONNULL_BEGIN

@interface SBAudioNode : NSObject

@property (nonatomic, assign) void* audioNode;
@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong, readonly) NSString* type;
@property (nonatomic, strong, readonly) NSString* displayName;
@property (nonatomic, strong, readonly) NSArray<SBParameter*>* parameters;

- (instancetype)initWithAudioNode:(void*)audioNode;

- (SBParameter*)parameterWithID:(NSString*)parameterID;

@end

NS_ASSUME_NONNULL_END
