//
//  APURLWithLabel.h
//  Pods
//
//  Created by Inhong Kim on 2015. 1. 8..
//
//

#import <Foundation/Foundation.h>

@interface APURLWithLabel : NSObject

@property (nonatomic, readonly) NSString *url;
@property (nonatomic, readonly) NSString *label;

- (id)initWithURL:(NSString *)url label:(NSString *)label;

@end
