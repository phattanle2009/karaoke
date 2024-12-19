//
//  SwitchboardSDK.h
//  SwitchboardSDK
//
//  Created by Nádor Iván on 2022. 07. 01..
//

#import <Foundation/Foundation.h>

//! Project version number for SwitchboardSDK.
FOUNDATION_EXPORT double SwitchboardSDKVersionNumber;

//! Project version string for SwitchboardSDK.
FOUNDATION_EXPORT const unsigned char SwitchboardSDKVersionString[];

#import <SwitchboardSDK/SBAudioBuffer.h>
#import <SwitchboardSDK/SBAudioDevice.h>
#import <SwitchboardSDK/SBAudioDeviceWrapper.h>
#import <SwitchboardSDK/SBAudioGraph.h>
#import <SwitchboardSDK/SBAudioGraphFactory.h>
#import <SwitchboardSDK/SBAudioNode.h>
#import <SwitchboardSDK/SBAudioPlayerNode.h>
#import <SwitchboardSDK/SBAudioProcessorNode.h>
#import <SwitchboardSDK/SBAudioSinkNode.h>
#import <SwitchboardSDK/SBAudioSource.h>
#import <SwitchboardSDK/SBAudioSourceNode.h>
#import <SwitchboardSDK/SBAudioSourceWrapper.h>
#import <SwitchboardSDK/SBBoolParameter.h>
#import <SwitchboardSDK/SBBusSelectNode.h>
#import <SwitchboardSDK/SBBusSplitterNode.h>
#import <SwitchboardSDK/SBChannelSplitterNode.h>
#import <SwitchboardSDK/SBClippingDetectorNode.h>
#import <SwitchboardSDK/SBCodec.h>
#import <SwitchboardSDK/SBDiagnosticRecorderNode.h>
#import <SwitchboardSDK/SBDiscardNode.h>
#import <SwitchboardSDK/SBDuckingCompressor.h>
#import <SwitchboardSDK/SBFloatParameter.h>
#import <SwitchboardSDK/SBGainNode.h>
#import <SwitchboardSDK/SBIntParameter.h>
#import <SwitchboardSDK/SBLogger.h>
#import <SwitchboardSDK/SBMixerNode.h>
#import <SwitchboardSDK/SBMonoBusMergerNode.h>
#import <SwitchboardSDK/SBMonoToMultiChannelNode.h>
#import <SwitchboardSDK/SBMultiChannelToMonoNode.h>
#import <SwitchboardSDK/SBMusicDuckingNode.h>
#import <SwitchboardSDK/SBMusicDuckingV2Node.h>
#import <SwitchboardSDK/SBMuteNode.h>
#import <SwitchboardSDK/SBOfflineGraphRenderer.h>
#import <SwitchboardSDK/SBParameter.h>
#import <SwitchboardSDK/SBPassthroughNode.h>
#import <SwitchboardSDK/SBPipe.h>
#import <SwitchboardSDK/SBRecorderNode.h>
#import <SwitchboardSDK/SBResampledSinkNode.h>
#import <SwitchboardSDK/SBResampledSourceNode.h>
#import <SwitchboardSDK/SBResamplerNode.h>
#import <SwitchboardSDK/SBSilenceNode.h>
#import <SwitchboardSDK/SBSimpleDuckingCompressor.h>
#import <SwitchboardSDK/SBSineGeneratorNode.h>
#import <SwitchboardSDK/SBStereoBusMergerNode.h>
#import <SwitchboardSDK/SBStereoPannerNode.h>
#import <SwitchboardSDK/SBStringParameter.h>
#import <SwitchboardSDK/SBSubgraphProcessorNode.h>
#import <SwitchboardSDK/SBSubgraphSinkNode.h>
#import <SwitchboardSDK/SBSubgraphSourceNode.h>
#import <SwitchboardSDK/SBSwitchboardSDK.h>
#import <SwitchboardSDK/SBSynthNode.h>
#import <SwitchboardSDK/SBUIntParameter.h>
#import <SwitchboardSDK/SBVUMeterNode.h>
#import <SwitchboardSDK/SBVoiceActivityDetectorNode.h>
#import <SwitchboardSDK/SBWhiteNoiseGeneratorNode.h>

#if TARGET_OS_IOS
#import <SwitchboardSDK/SBAudioEngine.h>
#import <SwitchboardSDK/SBAudioProcessor.h>
#import <SwitchboardSDK/SBIOSAudioIO.h>
#elif TARGET_OS_OSX
#import <SwitchboardSDK/SBAudioEngine.h>
#endif

#if !TARGET_OS_WATCH
#import <SwitchboardSDK/SBStreamPlayerNode.h>
#import <SwitchboardSDK/SBUsageTrackerNode.h>
#import <SwitchboardSDK/StreamPlayerNodeDelegate.h>
#endif
