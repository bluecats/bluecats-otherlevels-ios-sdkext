//
//  OLLocationEventPoster.m
//  BCOtherCats
//
//  Created by Cody Singleton on 8/18/15.
//  Copyright (c) 2015 bluecats. All rights reserved.
//

#import "OLLocationEventPoster.h"
#import "BlueCatsSDK.h"
#import "BCZone.h"
#import "BCSite.h"
#import "OtherLevels.h"

static NSString *const OL_API_BASE_URL = @"https://beacons.otherlevels.com/";
static NSString *const LOCATION_EVENT_ID_KEY = @"location_event_id";
static NSString *const NETWORK_ID_KEY = @"network_id";
static NSString *const OL_ID_KEY = @"ol_id";

static NSString *const OCZoneEventTypeEnter = @"Enter";
static NSString *const OCZoneEventTypeExit = @"Exit";
static NSString *const OCZoneEventTypeReEnter = @"ReEnter";
static NSString *const OCZoneEventTypeDwell = @"Dwell";

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
    if (zone.zoneScope != BCZoneScopeAllBeaconsWithZoneIdentifierCustomValue) return;
    
    if ([BlueCatsSDK isNetworkReachable]) { // ignore event, if network not available
        
        NSString *eventTypeString = [NSString stringWithFormat:@"%@%ld", OCZoneEventTypeDwell, (long)dwellTimeInterval];
        NSString *locationEventIdentifier = [self locationEventIdentifierWithZone:zone andEventTypeString:eventTypeString];
        [self postOLLocationEventWithIdentifier:locationEventIdentifier andTeamID:zone.site.teamID];
    }
}

- (void)zoneMonitor:(BCZoneMonitor *)monitor didEnterZone:(BCZone *)zone
{
    if (zone.zoneScope != BCZoneScopeAllBeaconsWithZoneIdentifierCustomValue) return;
    
    if ([BlueCatsSDK isNetworkReachable]) { // ignore event, if network not available
        
        NSString *locationEventIdentifier = [self locationEventIdentifierWithZone:zone andEventTypeString:OCZoneEventTypeEnter];
        [self postOLLocationEventWithIdentifier:locationEventIdentifier andTeamID:zone.site.teamID];
    }
}

- (void)zoneMonitor:(BCZoneMonitor *)monitor didExitZone:(BCZone *)zone
{
    if (zone.zoneScope != BCZoneScopeAllBeaconsWithZoneIdentifierCustomValue) return;
    
    if ([BlueCatsSDK isNetworkReachable]) { // ignore event, if network not available
        
        NSString *locationEventIdentifier = [self locationEventIdentifierWithZone:zone andEventTypeString:OCZoneEventTypeExit];
        [self postOLLocationEventWithIdentifier:locationEventIdentifier andTeamID:zone.site.teamID];
    }
}

- (void)zoneMonitor:(BCZoneMonitor *)monitor didReEnterZone:(BCZone *)zone
{
    if (zone.zoneScope != BCZoneScopeAllBeaconsWithZoneIdentifierCustomValue) return;
    
    if ([BlueCatsSDK isNetworkReachable]) { // ignore event, if network not available
        
        NSString *locationEventIdentifier = [self locationEventIdentifierWithZone:zone andEventTypeString:OCZoneEventTypeReEnter];
        [self postOLLocationEventWithIdentifier:locationEventIdentifier andTeamID:zone.site.teamID];
    }
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
    
    NSString *URLString = [NSString stringWithFormat:@"%@/%@/beacon-push", [OtherLevels getAppKey], [OtherLevels getTrackingId]];
    
    NSLog(@"%@",URLString);

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
        NSLog(@"data = %@, response = %@, error =%@ }", [NSJSONSerialization JSONObjectWithData:data options:0 error:nil], response, error);
    }];
    
    [postDataTask resume];
}

@end
