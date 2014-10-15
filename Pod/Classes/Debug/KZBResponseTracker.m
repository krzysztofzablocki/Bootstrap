//
//  Created by merowing on 03/02/2014.
//
//
//


#import "KZBResponseTracker.h"
#import "KZBResponseTrackingNode.h"

@interface KZBResponseTracker ()
@property(nonatomic, strong, readonly) NSMutableDictionary *responses;
@end

@implementation KZBResponseTracker {
  NSMutableDictionary *_responses;
}

+ (KZBResponseTracker *)sharedInstance
{
  static dispatch_once_t onceToken;
  static KZBResponseTracker *singleton;
  dispatch_once(&onceToken, ^{
    singleton = [[KZBResponseTracker alloc] init];
  });

  return singleton;
}

+ (void)trackResponse:(id)jsonResponse error:(NSError *)error forEndPoint:(NSString *)endPoint
{
  if (endPoint.length == 0) {
    endPoint = @"Uncategorized";
  }

  NSMutableDictionary *const responses = [self sharedInstance].responses;
  NSMutableArray *nodes = responses[endPoint];
  if (!nodes) {
    nodes = [NSMutableArray new];
    responses[endPoint] = nodes;
  }
  [nodes addObject:[[KZBResponseTrackingNode alloc] initWithEndPoint:endPoint response:jsonResponse ?: error]];
}

+ (NSDictionary *)responses
{
  return [[self sharedInstance].responses copy];
}


- (NSMutableDictionary *)responses
{
  if (!_responses) {
    _responses = [NSMutableDictionary new];
  }
  return _responses;
}

@end