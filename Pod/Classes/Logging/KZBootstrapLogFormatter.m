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
    case LOG_FLAG_ERROR:
      return "ERR";
    case LOG_FLAG_WARN:
      return "WRN";
    case LOG_FLAG_INFO:
      return "INF";
    case LOG_FLAG_DEBUG:
      return "DBG";
    case LOG_FLAG_VERBOSE:
      return "VRB";

    default:
      return "";
  }
}

NS_INLINE const char *CRLPointerToLastPathComponent(const char *path) {
  if (!path) { return ""; }

  const char *p = path, *lastSlash = NULL;
  while (*p != '\0') {
    if (*p == '/') { lastSlash = p; }
    p++;
  }

  // If we didn't find a slash, or the slash is the final character in the string,
  // just give back the whole thing.
  if (!lastSlash || *(lastSlash + 1) == '\0') { return path; }

  return lastSlash + 1;
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
                                                            fromDate:logMessage->timestamp];

  NSTimeInterval epoch = [logMessage->timestamp timeIntervalSinceReferenceDate];
  int milliseconds = (int)((epoch - floor(epoch)) * 1000);

  NSString *formattedMsg = [NSString stringWithFormat:@"%04ld-%02ld-%02ld %02ld:%02ld:%02ld:%03d [%s] %s:%d (%s): %@",
                                                      (long)components.year,
                                                      (long)components.month,
                                                      (long)components.day,
                                                      (long)components.hour,
                                                      (long)components.minute,
                                                      (long)components.second,
                                                      milliseconds,
                                                      CRLLogFlagToCString(logMessage->logFlag),
                                                      CRLPointerToLastPathComponent(logMessage->file),
                                                      logMessage->lineNumber,
                                                      logMessage->function ?: "",
                                                      logMessage->logMsg];

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