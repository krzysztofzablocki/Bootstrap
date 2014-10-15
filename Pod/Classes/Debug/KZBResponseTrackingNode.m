//
// Created by Marek Cirkos on 17/03/2014.
// Copyright (c) 2014 pixle. All rights reserved.
//

#import "KZBResponseTrackingNode.h"

@implementation KZBResponseTrackingNode

- (id)initWithEndPoint:(NSString *)endPoint response:(id)response
{
  self = [super init];
  if (self) {
    _endPoint = [endPoint copy];
    _response = response;
    _date = [NSDate date];
  }

  return self;
}

- (NSString *)description
{
  return [NSString stringWithFormat:@"KZBResponse %@ endPoint %@ at %@", self.response, self.endPoint, self.date];
}


@end