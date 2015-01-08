//
//  APInstantMessages.h
//  Pods
//
//  Created by Inhong Kim on 2015. 1. 8..
//
//

#import <Foundation/Foundation.h>

@interface APInstantMessages : NSObject

@property (nonatomic, readonly) NSString *service;
@property (nonatomic, readonly) NSString *username;

- (instancetype)initWithInstantDictionary:(NSDictionary *)dictionary;

@end
