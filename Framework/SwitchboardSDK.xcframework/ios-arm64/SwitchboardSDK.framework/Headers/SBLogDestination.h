//
//  SBLogDestination.h
//  SwitchboardSDK
//
//  Created by Pesti József on 2022. 12. 21..
//

#import "SBLogLevel.h"

@protocol SBLogDestination

- (void)log:(SBLogLevel)logLevel message:(NSString*)logMessage;

@end
