//
//  SBOfflineGraphRenderer.h
//  SwitchboardSDK
//
//  Created by Iván Nádor on 2023. 07. 27..
//

#import <Foundation/Foundation.h>
#import "SBCodec.h"

@class SBAudioGraph;

NS_ASSUME_NONNULL_BEGIN

@interface SBOfflineGraphRenderer : NSObject

@property (nonatomic, assign, readonly) void* offlineGraphRenderer;

@property (nonatomic, assign) double maxNumberOfSecondsToRender;
@property (nonatomic, assign) unsigned int sampleRate;
@property (nonatomic, assign) unsigned int bufferDurationMs;

- (instancetype)initWithOfflineGraphRenderer:(void*)offlineGraphRenderer;
- (void)processGraph:(SBAudioGraph*)audioGraph
         withOutputFile:(NSString*)outputFile
    withOutputFileCodec:(SBCodec)outputFileCodec;

@end

NS_ASSUME_NONNULL_END
