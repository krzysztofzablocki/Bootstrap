// Adapted from Sidecar

// Sidecar
// Copyright (c) 2014, Crush & Lovely <engineering@crushlovely.com>
// Under the MIT License; see LICENSE file for details.

#import "DDLog.h"
#import "KZBootstrapLogFormatter.h"

@import Darwin;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdirect-ivar-access"

static NSString *const CRLMethodLogFormatterCalendarKey = @"CRLMethodLogFormatterCalendarKey";
static const NSCalendarUnit CRLMethodLogFormatterCalendarUnitFlags = (NSCalendarUnit)(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond);


NS_INLINE const char *CRLLogFlagToCString(int logFlag) {
  switch (logFlag) {
    case DDLogLevelError:
      return "ERR";
    case DDLogLevelWarning:
      return "WRN";
    case DDLogLevelInfo:
      return "INF";
    case DDLogLevelDebug:
      return "DBG";
    case DDLogLevelVerbose:
      return "VRB";

    default:
      return "";
  }
}

@interface KZBootstrapLogFormatter () {
  int32_t atomicLoggerCount;
  NSCalendar *threadUnsafeCalendar;
}

@end


@implementation KZBootstrapLogFormatter

- (NSCalendar *)threadsafeCalendar
{
  int32_t loggerCount = OSAtomicAdd32(0, &atomicLoggerCount);

  if (loggerCount <= 1) {
    // Single-threaded
    if (!threadUnsafeCalendar) { threadUnsafeCalendar = [NSCalendar autoupdatingCurrentCalendar]; }
    return threadUnsafeCalendar;
  }
  else {
    // Multi-threaded. Use the thread-local instance
    NSMutableDictionary *threadDictionary = [[NSThread currentThread] threadDictionary];
    NSCalendar *threadCalendar = [threadDictionary objectForKey:CRLMethodLogFormatterCalendarKey];

    if (!threadCalendar) {
      threadCalendar = [NSCalendar autoupdatingCurrentCalendar];
      [threadDictionary setObject:threadCalendar forKey:CRLMethodLogFormatterCalendarKey];
    }

    return threadCalendar;
  }
}

- (NSString *)formatLogMessage:(DDLogMessage *)logMessage
{
  // Time calculation is ripped from DDTTYLogger

  NSDateComponents *components = [[self threadsafeCalendar] components:CRLMethodLogFormatterCalendarUnitFlags
                                                            fromDate:logMessage->_timestamp];

  NSTimeInterval epoch = [logMessage->_timestamp timeIntervalSinceReferenceDate];
  int milliseconds = (int)((epoch - floor(epoch)) * 1000);

  NSString *formattedMsg = [NSString stringWithFormat:@"%04ld-%02ld-%02ld %02ld:%02ld:%02ld:%03d [%s] %@:%lu (%@): %@",
                                                      (long)components.year,
                                                      (long)components.month,
                                                      (long)components.day,
                                                      (long)components.hour,
                                                      (long)components.minute,
                                                      (long)components.second,
                                                      milliseconds,
                                                      CRLLogFlagToCString(logMessage->_flag),
                                                      [logMessage->_file lastPathComponent],
                                                      (unsigned long)logMessage->_line,
                                                      logMessage->_function ?: @"",
                                                      logMessage->_message];

  return formattedMsg;
}

- (void)didAddToLogger:(id <DDLogger> __unused)logger
{
  OSAtomicIncrement32(&atomicLoggerCount);
}

- (void)willRemoveFromLogger:(id <DDLogger> __unused)logger
{
  OSAtomicDecrement32(&atomicLoggerCount);
}

@end
