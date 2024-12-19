//
//  NSString+AudioSessionRouteChangeReason.h
//  SwitchboardAudioIOS
//
//  Created by Balázs Kiss on 2020. 06. 10..
//  Copyright © 2020. Synervoz Inc. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (AudioSessionRouteChangeReason)

+ (NSString*)stringWithAudioSessionRouteChangeReason:(AVAudioSessionRouteChangeReason)routeChangeReason;

@end

NS_ASSUME_NONNULL_END
