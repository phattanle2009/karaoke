//
//  SBAudioProcessor.h
//  SwitchboardAudioIOS
//
//  Created by Balázs Kiss on 2021. 04. 12..
//  Copyright © 2021. Synervoz Inc. All rights reserved.
//

#import <CoreAudioTypes/CoreAudioTypes.h>
#import <Foundation/Foundation.h>

@protocol AudioProcessorDelegate;

NS_ASSUME_NONNULL_BEGIN

@interface SBAudioProcessor : NSObject

@property (nonatomic, weak) id<AudioProcessorDelegate> delegate;

- (void)process:(uint32_t)frameCount
     inBufferListPtr:(AudioBufferList*)inBufferListPtr
    outBufferListPtr:(AudioBufferList*)outBufferListPtr
           timeStamp:(const AudioTimeStamp*)inTimeStamp
          sampleRate:(int)sampleRate;

@end

NS_ASSUME_NONNULL_END
