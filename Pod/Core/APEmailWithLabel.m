//
//  APEmailWithLabel.m
//  AddressBook
//
//  Created by Inhong Kim on 2015. 1. 7..
//  Copyright (c) 2015년 alterplay. All rights reserved.
//

#import "APEmailWithLabel.h"

@implementation APEmailWithLabel

- (id)initWithEmail:(NSString *)email label:(NSString *)label {
    self = [super init];
    if(self)
    {
        _email = email;
        _label = label;
    }
    return self;
}
@end
