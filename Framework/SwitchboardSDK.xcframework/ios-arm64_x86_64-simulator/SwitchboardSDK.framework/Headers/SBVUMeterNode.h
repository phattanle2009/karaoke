//
//  SBVUMeterNode.h
//  SwitchboardSDK
//
//  Created by Nádor Iván on 2022. 08. 08..
//

#import <Foundation/Foundation.h>
#import "SBAudioSinkNode.h"

NS_ASSUME_NONNULL_BEGIN

@interface SBVUMeterNode : SBAudioSinkNode

@property (nonatomic, assign) float smoothingDurationMs;
@property (nonatomic, assign, readonly) float level;
@property (nonatomic, assign, readonly) float levelDBFS;
@property (nonatomic, assign, readonly) float peak;
@property (nonatomic, assign, readonly) float peakDBFS;

- (instancetype)init;

@end

NS_ASSUME_NONNULL_END
