//
//  SBPipe.h
//  SwitchboardSDK
//
//  Created by Pesti József on 2022. 12. 12..
//

#import <Foundation/Foundation.h>
#import "SBAudioSinkNode.h"
#import "SBAudioSourceNode.h"

NS_ASSUME_NONNULL_BEGIN

@interface SBPipe : NSObject

@property (nonatomic, strong) SBAudioSinkNode* inputNode;
@property (nonatomic, strong) SBAudioSourceNode* outputNode;

@end

NS_ASSUME_NONNULL_END
