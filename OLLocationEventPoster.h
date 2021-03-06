//
//  OLLocationEventPoster.h
//  BCOtherCats
//
//  Created by Cody Singleton on 8/18/15.
//  Copyright (c) 2015 bluecats. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BlueCatsSDK.h"

@interface OLLocationEventPoster : NSObject <BCZoneMonitorDelegate>

@property (nonatomic, readonly) BCZoneMonitor *zoneMonitor;

- (instancetype)initWithZoneIdentifierKeys:(NSArray *)keys;
- (NSString *)locationEventIdentifierWithZone:(BCZone *)zone andEventTypeString:(NSString *)eventTypeString;
- (void) postOLLocationEventWithIdentifier:(NSString *)locationEventIdentifier andTeamID:(NSString *)teamID;

@end

extern NSString *const OLZoneEventTypeEnter;
extern NSString *const OLZoneEventTypeExit;
extern NSString *const OLZoneEventTypeReEnter;
extern NSString *const OLZoneEventTypeDwell;
extern NSString *const OLZoneEventTypeSuspend;
