//
//  SBAudioDeviceWrapper.h
//  SwitchboardSDK
//
//  Created by Balázs Kiss on 21/07/16.
//
//

#import <Foundation/Foundation.h>
#import "SBAudioDevice.h"

@interface SBAudioDeviceWrapper : NSObject

- (instancetype)initWithRemotePeerAudioBus:(id<SBAudioDevice>)remotePeerAudioBus;
- (void*)internalObject;

@end
