//
//  Created by merowing on 21/02/2014.
//
//
//


#import <objc/runtime.h>
#import "KZBAFNetworkingBinder.h"
#import "KZBResponseTracker.h"


@implementation KZBAFNetworkingBinder
#ifdef DEBUG

+ (void)load
{
  //! AFNetworking 2.x
  [self swizzleSelector:NSSelectorFromString(@"setCompletionBlockWithSuccess:failure:") with:@selector(kzd_setCompletionBlockWithSuccess:failure:) inClass:NSClassFromString(@"AFHTTPRequestOperation")];
}

+ (void)swizzleSelector:(SEL)originalSelector with:(SEL)overrideSelector inClass:(Class)targetClass
{
  if (targetClass) {
    Method originalMethod = class_getInstanceMethod(targetClass, originalSelector);
    Method overrideMethod = class_getInstanceMethod(self, overrideSelector);
    class_addMethod(targetClass, overrideSelector, method_getImplementation(overrideMethod), method_getTypeEncoding(overrideMethod));
    overrideMethod = class_getInstanceMethod(targetClass, overrideSelector);
    method_exchangeImplementations(originalMethod, overrideMethod);
  }
}

#pragma clang diagnostic push
#pragma ide diagnostic ignored "InfiniteRecursion"

- (void)kzd_setCompletionBlockWithSuccess:(void (^)(NSOperation *operation, id responseObject))success
                                  failure:(void (^)(NSOperation *operation, NSError *error))failure
{
  return [self kzd_setCompletionBlockWithSuccess:^(id operation, id responseObject) {
    NSHTTPURLResponse *response = (NSHTTPURLResponse*)[operation response];
    [KZBResponseTracker trackResponse:response object:responseObject forEndPoint:response.URL.absoluteString];
    success(operation, responseObject);
  } failure:^(id operation, NSError *error) {
    NSHTTPURLResponse *response = (NSHTTPURLResponse*)[operation response];
    [KZBResponseTracker trackResponse:response object:error forEndPoint:response.URL.absoluteString];
    failure(operation, error);
  }];
}
#pragma clang diagnostic pop
#endif
@end