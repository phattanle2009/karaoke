//
//  TMURemotePeerAudioBus.h
//  SwitchboardSDK
//
//  Created by Daniel Goguen on 09/08/16.
//
//

#import <Foundation/Foundation.h>
#import "SBAudioSource.h"

@interface SBAudioSourceWrapper : NSObject

- (instancetype)initWithRemoteMusicBus:(id<SBAudioSource>)remoteMusicBus;
- (void*)internalObject;

@end
