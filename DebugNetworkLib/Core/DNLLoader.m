//
//  DNLLoader.m
//  DebugNetworkLib
//
//  Copyright © 2020 Anh Dung. All rights reserved.
//

#import "DNLLoader.h"

@implementation DNLLoader

+ (void)load
{
    SEL implementDebugNetworkLibSelector = NSSelectorFromString(@"implementDebugNetworkLib");
    if ([NSURLSessionConfiguration respondsToSelector:implementDebugNetworkLibSelector])
    {
        [NSURLSessionConfiguration performSelector:implementDebugNetworkLibSelector];
    }
}

@end
