//
//  SBAudioGraphFactory.h
//  SwitchboardSDK
//
//  Created by Balazs Kiss on 17/10/2023.
//

#import <Foundation/Foundation.h>

@class SBAudioGraph;

NS_ASSUME_NONNULL_BEGIN

@interface SBAudioGraphFactory : NSObject

+ (SBAudioGraph* _Nullable)parseJSON:(NSString*)config;

@end

NS_ASSUME_NONNULL_END
