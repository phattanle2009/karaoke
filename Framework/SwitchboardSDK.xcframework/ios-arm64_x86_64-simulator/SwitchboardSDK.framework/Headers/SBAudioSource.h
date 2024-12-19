//
//  SBAudioSource.h
//  SwitchboardSDK
//
//  Created by Daniel Goguen on 09/08/16.
//
//

#import <Foundation/Foundation.h>

@protocol SBAudioSource <NSObject>

- (uint32_t)readRenderData:(void*)data numberOfSamples:(uint32_t)count;

- (BOOL)isRendering;

@end
