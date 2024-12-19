//
//  SBAudioGraph.h
//  SwitchboardSDK
//
//  Created by Balázs Kiss on 2022. 07. 26..
//

#import <Foundation/Foundation.h>

@class SBAudioNode;
@class SBAudioSourceNode;
@class SBAudioProcessorNode;
@class SBAudioSinkNode;
@class SBAudioBuffer;

NS_ASSUME_NONNULL_BEGIN

@interface SBAudioGraph : NSObject

@property (nonatomic, assign, readonly) void* audioGraph;

@property (nonatomic, strong, readonly) SBAudioSourceNode* inputNode;

@property (nonatomic, strong, readonly) SBAudioSinkNode* outputNode;

@property (nonatomic, strong, readonly) NSArray<SBAudioNode*>* nodes;

@property (nonatomic, assign, readonly) BOOL isRunning;

- (instancetype)initWithAudioGraph:(void*)audioGraph;

- (instancetype)initWithMaxNumberOfChannels:(uint)maxNumberOfChannels;

- (instancetype)initWithMaxNumberOfChannels:(uint)maxNumberOfChannels maxNumberOfFrames:(uint)maxNumberOfFrames;

- (BOOL)addNode:(SBAudioNode*)node NS_SWIFT_NAME(addNode(_:));

- (BOOL)removeNode:(SBAudioNode*)audioNode NS_SWIFT_NAME(removeNode(_:));

- (SBAudioNode*)nodeWithID:(NSString*)nodeID;

- (BOOL)connectSourceNode:(SBAudioSourceNode*)sourceNode toProcessorNode:(SBAudioProcessorNode*)processorNode;

- (BOOL)connectSourceNode:(SBAudioSourceNode*)sourceNode toSinkNode:(SBAudioSinkNode*)sinkNode;

- (BOOL)connectProcessorNode:(SBAudioProcessorNode*)processorNodeSrc
             toProcessorNode:(SBAudioProcessorNode*)processorNodeDst;

- (BOOL)connectProcessorNode:(SBAudioProcessorNode*)processorNode toSinkNode:(SBAudioSinkNode*)sinkNode;

- (BOOL)start;

- (void)stop;

- (BOOL)processBuffer:(SBAudioBuffer* _Nullable)inBuffer outBuffer:(SBAudioBuffer* _Nullable)outBuffer;

@end

NS_ASSUME_NONNULL_END
