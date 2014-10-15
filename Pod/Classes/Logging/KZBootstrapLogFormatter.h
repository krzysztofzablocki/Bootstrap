// Adapted from Sidecar
// Sidecar
// Copyright (c) 2014, Crush & Lovely <engineering@crushlovely.com>
// Under the MIT License; see LICENSE file for details.

@import Foundation;
@protocol DDLogFormatter;

/**
A CocoaLumberjack log formatter that includes the date, time, filename, function name
(or selector name), and log level.
*/
@interface KZBootstrapLogFormatter : NSObject <DDLogFormatter>

@end