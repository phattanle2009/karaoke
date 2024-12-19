//
//  SBSwitchboardSDK.h
//  SwitchboardSDK
//
//  Created by Balazs Kiss on 2023. 01. 06..
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SBSwitchboardSDK : NSObject

+ (void)initializeWithAppID:(NSString*)appID appSecret:(NSString*)appSecret;

+ (NSString*)appID;

+ (NSString*)appSecret;

+ (NSString*)apiUrl;

+ (NSString*)temporaryDirectoryPath;

+ (NSString*)versionName;

+ (int)buildNumber;

+ (void)setTemporaryDirectoryPath:(NSString*)path;

@end

NS_ASSUME_NONNULL_END
