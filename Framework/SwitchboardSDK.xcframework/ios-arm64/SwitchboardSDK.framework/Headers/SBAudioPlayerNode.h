//
//  SBAudioPlayer.h
//  SwitchboardSDK
//
//  Created by Nádor Iván on 2022. 08. 30..
//

#import <Foundation/Foundation.h>
#import "SBAudioSourceNode.h"
#import "SBCodec.h"

NS_ASSUME_NONNULL_BEGIN

@interface SBAudioPlayerNode : SBAudioSourceNode

@property (nonatomic, assign, readonly) BOOL isPlaying;
@property (nonatomic, assign) BOOL isLoopingEnabled;
@property (nonatomic, assign) double position;
@property (nonatomic, assign) double startPosition;
@property (nonatomic, assign) double endPosition;
@property (nonatomic, assign) unsigned int numberOfChannels;
@property (nonatomic, assign, readonly) unsigned int sourceSampleRate;

- (BOOL)load:(NSString*)path;
- (BOOL)load:(NSString*)path withFormat:(SBCodec)format;
- (BOOL)stream:(NSString*)path;
- (BOOL)stream:(NSString*)path withFormat:(SBCodec)format;
- (void)play;
- (void)pause;
- (void)stop;
- (double)duration;

@end

NS_ASSUME_NONNULL_END
