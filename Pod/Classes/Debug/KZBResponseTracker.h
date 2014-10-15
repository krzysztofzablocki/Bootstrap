//
//  Created by merowing on 03/02/2014.
//
//
//


@import Foundation;

@interface KZBResponseTracker : NSObject
+ (void)trackResponse:(id)jsonResponse error:(NSError *)error forEndPoint:(NSString *)endPoint;
+ (NSDictionary *)responses;
@end