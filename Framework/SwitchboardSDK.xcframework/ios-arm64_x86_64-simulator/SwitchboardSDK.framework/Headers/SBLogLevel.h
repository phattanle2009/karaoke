//
//  SBLogLevel.h
//  SwitchboardSDK
//
//  Created by Pesti József on 2022. 12. 21..
//

#pragma once

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, SBLogLevel) {
    SBLogLevelNone = 0,
    SBLogLevelError,
    SBLogLevelWarning,
    SBLogLevelInfo,
    SBLogLevelDebug,
    SBLogLevelTrace
};

#ifdef __cplusplus
extern "C" {
#endif

NSString* _Nonnull SBLogLevelToString(SBLogLevel logLevel);

#ifdef __cplusplus
}
#endif
