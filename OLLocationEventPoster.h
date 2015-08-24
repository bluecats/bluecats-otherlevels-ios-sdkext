//
//  OLLocationEventPoster.h
//  BCOtherCats
//
//  Created by Cody Singleton on 8/18/15.
//  Copyright (c) 2015 bluecats. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BCZoneMonitor.h"

@interface OLLocationEventPoster : NSObject <BCZoneMonitorDelegate>

@property (nonatomic, readonly) BCZoneMonitor *zoneMonitor;

- (instancetype)initWithZoneIdentifierKeys:(NSArray *)keys;

@end
