//
//  SBCodec.h
//  SwitchboardSDK
//
//  Created by Nádor Iván on 2022. 08. 30..
//

#pragma once

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, SBCodec) { SBCodecWav = 0, SBCodecVorbis, SBCodecMp3, SBCodecApple };

#ifdef __cplusplus
extern "C" {
#endif

SBCodec SBCodecFromString(NSString* stringValue);
NSString* SBCodecFileExtension(SBCodec codec);

#ifdef __cplusplus
}
#endif
