//
//  SBDiagnosticRecorderNode.h
//  SwitchboardSDK
//
//  Created by Iván Nádor on 22/01/2024.
//

#import <Foundation/Foundation.h>
#import "SBAudioProcessorNode.h"
#import "SBCodec.h"

NS_ASSUME_NONNULL_BEGIN

@interface SBDiagnosticRecorderNode : SBAudioProcessorNode

- (instancetype)initWithSampleSeconds:(unsigned int)sampleSeconds;

- (BOOL)dumpWithRecordingFilePath:(NSString*)recordingFilePath andFormat:(SBCodec)format;

- (SBAudioProcessorNode*)createTapWithName:(NSString*)name NS_SWIFT_NAME(createTap(_:));
;

@end

NS_ASSUME_NONNULL_END
