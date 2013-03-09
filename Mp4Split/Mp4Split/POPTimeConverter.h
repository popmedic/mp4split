//
//  POPTimeConverter.h
//  Mp4Split
//
//  Created by Kevin Scardina on 3/8/13.
//  Copyright (c) 2013 Kevin Scardina. All rights reserved.
//
#import <QTKit/QTKit.h>
#import <Foundation/Foundation.h>

@interface POPTimeConverter : NSObject
+ (NSString*) timeStringFromSecs:(float)secs;
+ (float) secsFromTimeString:(NSString*)str;
+ (NSString*) timeStringFromQTTime:(QTTime)qtTime;
@end
