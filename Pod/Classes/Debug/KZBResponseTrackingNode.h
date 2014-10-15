//
// Created by Marek Cirkos on 17/03/2014.
// Copyright (c) 2014 pixle. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface KZBResponseTrackingNode : NSObject
@property(nonatomic, copy, readonly) NSString *endPoint;
@property(nonatomic, strong, readonly) NSDate *date;
@property(nonatomic, strong, readonly) id response;
@property(nonatomic, strong, readonly) id responseObject;

- (instancetype)initWithEndPoint:(NSString *)endPoint response:(id)response responseObject:(id)responseObject;
- (instancetype)initWithEndPoint:(NSString *)endPoint response:(id)response;
@end