//
// Created by Marek Cirkos on 17/03/2014.
// Copyright (c) 2014 pixle. All rights reserved.
//

#import "KZBResponseTrackingNode.h"

@implementation KZBResponseTrackingNode

- (id)initWithEndPoint:(NSString *)endPoint response:(id)response responseObject:(id)responseObject
{
  self = [super init];
  if (self) {
    _endPoint = [endPoint copy];
    _response = response;
    _date = [NSDate date];
    _responseObject = responseObject;
  }
  
  return self;
}


- (id)initWithEndPoint:(NSString *)endPoint response:(id)response
{
  return [self initWithEndPoint:endPoint response:response responseObject:nil];
}

- (NSString *)description
{
  return [NSString stringWithFormat:@"KZBResponseTrackingNode endPoint %@ at %@ received response:\n %@", self.endPoint, self.date, self.response];
}


@end