//
//  SBStreamPlayerNode.h
//  SwitchboardSDK
//
//  Created by Gergye Mihály on 2023. 05. 24..
//

#import <Foundation/Foundation.h>
#import "SBAudioSourceNode.h"

NS_ASSUME_NONNULL_BEGIN

@interface SBStreamPlayerNode : SBAudioSourceNode

@property (nonatomic, assign, readonly) BOOL isPlaying;

- (void)play:(NSString*)url;
- (void)stop;

@end

NS_ASSUME_NONNULL_END
