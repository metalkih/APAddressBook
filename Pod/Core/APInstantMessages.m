//
//  APInstantMessages.m
//  Pods
//
//  Created by Inhong Kim on 2015. 1. 8..
//
//

#import "APInstantMessages.h"
#import <AddressBook/AddressBook.h>

@interface APInstantMessages ()
@property (nonatomic, readwrite) NSString *service;
@property (nonatomic, readwrite) NSString *username;
@end

@implementation APInstantMessages

- (instancetype)initWithInstantDictionary:(NSDictionary *)dictionary {
    if (self = [super init])
    {
        NSString *serviceKey = (__bridge_transfer NSString *)kABPersonSocialProfileServiceKey;
        NSString *usernameKey = (__bridge_transfer NSString *)kABPersonSocialProfileUsernameKey;
        _service = dictionary[serviceKey];
        _username = dictionary[usernameKey];
    }
    return self;
}

@end
