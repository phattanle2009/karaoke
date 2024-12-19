//
//  SBClippingDetectorNode.h
//  SwitchboardSDK
//
//  Created by Pesti József on 2023. 04. 24..
//

#import <Foundation/Foundation.h>
#import "SBAudioSinkNode.h"

NS_ASSUME_NONNULL_BEGIN

@interface SBClippingDetectorNode : SBAudioSinkNode

@property (nonatomic, assign, readonly) BOOL isClipping;

@end

NS_ASSUME_NONNULL_END
