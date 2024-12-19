//
//  StreamPlayerNodeDelegate.h
//  SwitchboardSDK
//
//  Created by Gergye Mihály on 2023. 05. 31..
//

#import <Foundation/Foundation.h>

@protocol StreamPlayerNodeDelegate <NSObject>

- (void)streamPlayerNode:(void*)streamPlayer didChangeSampleRate:(uint32_t)sampleRate;

@end
