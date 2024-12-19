//
//  SBAudioDevice.h
//  SwitchboardSDK
//
//  Created by Balázs Kiss on 21/07/16.
//
//

#import <Foundation/Foundation.h>

@protocol SBAudioDevice <NSObject>

- (unsigned int)getSampleRate;

- (unsigned int)getNumChannels;

- (BOOL)isRendering;

- (uint32_t)readRenderData:(void*)data numberOfSamples:(uint32_t)count;

- (BOOL)isCapturing;

- (void)writeCaptureData:(void*)data numberOfSamples:(uint32_t)count;

@end
