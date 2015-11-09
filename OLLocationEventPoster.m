//
//  OLLocationEventPoster.m
//  BCOtherCats
//
//  Created by Cody Singleton on 8/18/15.
//  Copyright (c) 2015 bluecats. All rights reserved.
//

#import "OLLocationEventPoster.h"
#import "OtherLevels.h"

static NSString *const OL_API_BASE_URL = @"https://beacons.otherlevels.com/";
static NSString *const LOCATION_EVENT_ID_KEY = @"location_event_id";
static NSString *const NETWORK_ID_KEY = @"network_id";
static NSString *const OL_ID_KEY = @"ol_id";

NSString *const OLZoneEventTypeEnter   = @"Enter";
NSString *const OLZoneEventTypeExit    = @"Exit";
NSString *const OLZoneEventTypeReEnter = @"ReEnter";
NSString *const OLZoneEventTypeDwell   = @"Dwell";
NSString *const OLZoneEventTypeSuspend = @"Suspend";

@implementation OLLocationEventPoster

- (instancetype)initWithZoneIdentifierKeys:(NSArray *)keys
{
    if (self = [super init]) {
        
        _zoneMonitor = [[BCZoneMonitor alloc] initWithDelegate:self queue:nil zoneIdentifierKeys:keys];
        [_zoneMonitor startMonitoringZones];
    }
    return self;
}

- (instancetype)init
{
    if (self = [super init]) {
        
        _zoneMonitor = [[BCZoneMonitor alloc] initWithDelegate:self queue:nil];
        [_zoneMonitor startMonitoringZones];
    }
    return self;
}

- (void)dealloc
{
    _zoneMonitor = nil;
}


#pragma mark - BCZoneMonitorDelegate methods

- (void)zoneMonitor:(BCZoneMonitor *)monitor didDwellInZone:(BCZone *)zone forTimeInterval:(NSTimeInterval)dwellTimeInterval
{
    //NSLog(@"Did dwell in zone %@ for %.02f", zone.identifier, dwellTimeInterval);
    if ([BlueCatsSDK isNetworkReachable]) { // ignore event, if network not available
        
        NSString *eventTypeString = [NSString stringWithFormat:@"%@%ld", OLZoneEventTypeDwell, (long)dwellTimeInterval];
        NSString *locationEventIdentifier = [self locationEventIdentifierWithZone:zone andEventTypeString:eventTypeString];
        [self postOLLocationEventWithIdentifier:locationEventIdentifier andTeamID:zone.site.teamID];
    }
}

- (void)zoneMonitor:(BCZoneMonitor *)monitor didEnterZone:(BCZone *)zone
{
    //NSLog(@"Did enter zone %@", zone.identifier);
    if ([BlueCatsSDK isNetworkReachable]) { // ignore event, if network not available
        
        NSString *locationEventIdentifier = [self locationEventIdentifierWithZone:zone andEventTypeString:OLZoneEventTypeEnter];
        [self postOLLocationEventWithIdentifier:locationEventIdentifier andTeamID:zone.site.teamID];
    }
}

- (void)zoneMonitor:(BCZoneMonitor *)monitor didExitZone:(BCZone *)zone
{
    //NSLog(@"Did exit zone %@", zone.identifier);
    if ([BlueCatsSDK isNetworkReachable]) { // ignore event, if network not available
        
        NSString *locationEventIdentifier = [self locationEventIdentifierWithZone:zone andEventTypeString:OLZoneEventTypeExit];
        [self postOLLocationEventWithIdentifier:locationEventIdentifier andTeamID:zone.site.teamID];
    }
}

- (void)zoneMonitor:(BCZoneMonitor *)monitor didReEnterZone:(BCZone *)zone
{
    //NSLog(@"Did reEnter zone %@", zone.identifier);
    if ([BlueCatsSDK isNetworkReachable]) { // ignore event, if network not available
        
        NSString *locationEventIdentifier = [self locationEventIdentifierWithZone:zone andEventTypeString:OLZoneEventTypeReEnter];
        [self postOLLocationEventWithIdentifier:locationEventIdentifier andTeamID:zone.site.teamID];
    }
}

- (void)zoneMonitor:(BCZoneMonitor *)monitor willSuspendMonitoringInSite:(BCSite *)site untilDate:(NSDate *)date
{
    //NSLog(@"Will suspend zone monitoring in site %@ until %@", site.name, date);
    if ([BlueCatsSDK isNetworkReachable]) { // ignore event, if network not available
        
        NSString *locationEventIdentifier = [NSString stringWithFormat:@"%@_%@", [site.name stringByReplacingOccurrencesOfString:@" " withString:@"_"] , OLZoneEventTypeSuspend];
        [self postOLLocationEventWithIdentifier:[locationEventIdentifier uppercaseString] andTeamID:site.teamID];
    }
}

- (void)zoneMonitor:(BCZoneMonitor *)monitor willResumeMonitoringInSite:(BCSite *)site
{
    //NSLog(@"Will resume zone monitoring in site %@", site.name);
}

#pragma mark - Private methods

- (NSString *)locationEventIdentifierWithZone:(BCZone *)zone andEventTypeString:(NSString *)eventTypeString
{
    BOOL shouldPrefixOLEventIDsWithSiteName = NO;
    NSString *prefixOLEventIDsWithSiteNameValue = [zone.site stringValueForCustomValueKey:@"PrefixOLEventIDsWithSiteNameKey" ignoreCase:YES];
    if (prefixOLEventIDsWithSiteNameValue.length > 0) {
        shouldPrefixOLEventIDsWithSiteName = [prefixOLEventIDsWithSiteNameValue boolValue];
    }
    
    NSString *locationEventIdentifier = nil;
    if (shouldPrefixOLEventIDsWithSiteName) {
        locationEventIdentifier = [NSString stringWithFormat:@"%@_%@_%@", [zone.site.name stringByReplacingOccurrencesOfString:@" " withString:@"_"] , zone.identifier, eventTypeString];
    }
    else {
        locationEventIdentifier = [NSString stringWithFormat:@"%@_%@", zone.identifier, eventTypeString];
    }
    return [locationEventIdentifier uppercaseString];
}

- (void) postOLLocationEventWithIdentifier:(NSString *)locationEventIdentifier andTeamID:(NSString *)teamID
{
    NSError *error;
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:nil delegateQueue:nil];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/beacon-push", [OtherLevels getAppKey], [OtherLevels getTrackingId]] relativeToURL:[NSURL URLWithString:OL_API_BASE_URL]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    [request setHTTPMethod:@"POST"];
    NSDictionary *parameters = @{LOCATION_EVENT_ID_KEY : locationEventIdentifier,
                                 NETWORK_ID_KEY : teamID,
                                 OL_ID_KEY : [OtherLevels ol_id]};
    NSData *postData = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:&error];
    [request setHTTPBody:postData];
    
    
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (error) {
            //NSLog(@"Failed to post location event %@ with error %@" locationEventIdentifier, error);
        }
    }];
    
    [postDataTask resume];
}

@end
