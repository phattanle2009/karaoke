//
//  SBDuckingCompressor.h
//  SwitchboardSDK
//
//  Created by Iván Nádor on 2023. 07. 14..
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SBDuckingCompressor : NSObject

@property (nonatomic, assign) void* duckingCompressor;

- (instancetype)initWithDuckingCompressor:(void*)duckingCompressor;

@end

NS_ASSUME_NONNULL_END
