//
//  Created by merowing on 03/02/2014.
//
//
//


@import Foundation;

@interface KZBResponseTracker : NSObject
+ (void)trackResponse:(id)response object:(id)objectOrError forEndPoint:(NSString *)endPoint;
+ (NSDictionary *)responses;

+ (void)printAll;
@end