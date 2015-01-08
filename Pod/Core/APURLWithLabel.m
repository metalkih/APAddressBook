//
//  APURLWithLabel.m
//  Pods
//
//  Created by Inhong Kim on 2015. 1. 8..
//
//

#import "APURLWithLabel.h"

@implementation APURLWithLabel

- (id)initWithURL:(NSString *)url label:(NSString *)label {
    self = [super init];
    if(self)
    {
        _url = url;
        _label = label;
    }
    return self;
}

@end
