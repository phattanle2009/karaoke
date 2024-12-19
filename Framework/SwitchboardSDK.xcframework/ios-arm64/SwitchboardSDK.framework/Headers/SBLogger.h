//
//  SBLogger.h
//  SwitchboardAudio
//
//  Created by Balázs Kiss on 2017. 10. 05..
//  Copyright © 2017. Synervoz Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBLogDestination.h"
#import "SBLogLevel.h"

@interface SBLogger : NSObject

+ (void)trace:(NSString*)logMessage;
+ (void)debug:(NSString*)logMessage;
+ (void)info:(NSString*)logMessage;
+ (void)warning:(NSString*)logMessage;
+ (void)error:(NSString*)logMessage;

+ (void)setLogLevel:(SBLogLevel)logLevel;
+ (void)setLogDestination:(id<SBLogDestination>)logDestination;

@end

// MARK: - Convenience methods

void SBLogTrace(NSString* format, ...) NS_FORMAT_FUNCTION(1, 2) NS_NO_TAIL_CALL;
void SBLogDebug(NSString* format, ...) NS_FORMAT_FUNCTION(1, 2) NS_NO_TAIL_CALL;
void SBLogInfo(NSString* format, ...) NS_FORMAT_FUNCTION(1, 2) NS_NO_TAIL_CALL;
void SBLogWarning(NSString* format, ...) NS_FORMAT_FUNCTION(1, 2) NS_NO_TAIL_CALL;
void SBLogError(NSString* format, ...) NS_FORMAT_FUNCTION(1, 2) NS_NO_TAIL_CALL;
