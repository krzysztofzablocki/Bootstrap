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

+ (void)trackResponse:(id)response object:(id)objectOrError forEndPoint:(NSString *)endPoint
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
  [nodes addObject:[[KZBResponseTrackingNode alloc] initWithEndPoint:endPoint response:response responseObject:objectOrError]];
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

+ (void)printAll
{
  static dispatch_once_t onceToken;
  static NSDateFormatter *formatter;
  dispatch_once(&onceToken, ^{
    formatter = [NSDateFormatter new];
    formatter.dateStyle = NSDateFormatterShortStyle;
    formatter.timeStyle = NSDateFormatterMediumStyle;
  });

  [self.responses enumerateKeysAndObjectsUsingBlock:^(NSString *endPoint, NSArray *trackedNodes, BOOL *stop) {
    NSLog(@"endPoint %@ has been called %@ times:\n", endPoint, @(trackedNodes.count));
    [trackedNodes enumerateObjectsUsingBlock:^(KZBResponseTrackingNode *node, NSUInteger idx, BOOL *stop) {
      NSLog(@"%@",[NSMutableString stringWithFormat:@"[%@] %@ {\nresponse %@\nobject %@ }\n", @(idx), [formatter stringFromDate:node.date], node.response, node.responseObject]);
    }];
  }];
}
@end