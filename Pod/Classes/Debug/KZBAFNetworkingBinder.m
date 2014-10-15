//
//  Created by merowing on 21/02/2014.
//
//
//


#import <objc/runtime.h>
#import "KZBAFNetworkingBinder.h"
#import "KZBResponseTracker.h"
#import "RSSwizzle.h"


@implementation KZBAFNetworkingBinder
#ifdef DEBUG

typedef void (^KZBSuccesBlock)(id, id);
typedef void (^KZBFailureBlock)(id, NSError*);

+ (void)load
{

  //! AFNetworking 2.x
  Class httpOperationClass = NSClassFromString(@"AFHTTPRequestOperation");
  if (httpOperationClass) {
    RSSwizzleInstanceMethod(httpOperationClass,
      NSSelectorFromString(@"setCompletionBlockWithSuccess:failure:"),
      RSSWReturnType(void),
      RSSWArguments(KZBSuccesBlock success, KZBFailureBlock failure),
      RSSWReplacement({
      RSSWCallOriginal(^(id operation, id responseObject) {
        NSURLResponse *response = [operation response];
        [KZBResponseTracker trackResponse:response error:nil forEndPoint:response.URL.absoluteString];
        success(operation, responseObject);
      }, ^(id operation, NSError *error) {
        NSURLResponse *response = [operation response];
        [KZBResponseTracker trackResponse:response error:error forEndPoint:response.URL.absoluteString];
        failure(operation, error);
      });
    }), 0, NULL);
  }
}
#endif
@end