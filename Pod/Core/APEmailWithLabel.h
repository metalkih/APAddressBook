//
//  APEmailWithLabel.h
//  AddressBook
//
//  Created by Inhong Kim on 2015. 1. 7..
//  Copyright (c) 2015년 alterplay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APEmailWithLabel : NSObject

@property (nonatomic, readonly) NSString *email;
@property (nonatomic, readonly) NSString *label;

- (id)initWithEmail:(NSString *)email label:(NSString *)label;

@end
