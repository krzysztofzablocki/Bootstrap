//
//  Created by merowing on 09/10/14.
//
//
//
#ifdef DEBUG

@import UIKit;

#import "KZBApiEnforcers.h"
#import "RSSwizzle.h"
#import "KZAsserts.h"

#define SELECTOR(sel) NSStringFromSelector(@selector(sel))


@interface KZBApiEnforcers ()
@end

@implementation KZBApiEnforcers

+ (void)load
{
  [KZBApiEnforcers enforceUIKitOnMainThread];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

+ (void)enforceUIKitOnMainThread
{
  static const void *key = &key;
  [@[ SELECTOR(setNeedsDisplay), SELECTOR(setNeedsLayout) ] enumerateObjectsUsingBlock:^(NSString *selectorString, NSUInteger idx, BOOL *stop) {
    RSSwizzleInstanceMethod(UIView.class, NSSelectorFromString(selectorString), RSSWReturnType(
      void), RSSWArguments(), RSSWReplacement({
      if (((UIView *)self).window) {
        dispatch_queue_t queue = dispatch_get_current_queue();
        // iOS 8 layouts the MFMailComposeController in a background thread on an UIKit queue.
        if (!queue || !strstr(dispatch_queue_get_label(queue), "UIKit")) {
          AssertTrueOrReturn(NSThread.isMainThread);
        }

        RSSWCallOriginal();
      } else {
        RSSWCallOriginal();
      }
    }), RSSwizzleModeOncePerClass, key);
  }];
}

#pragma clang diagnostic pop

@end

#endif