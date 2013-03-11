//
//  POPTimeConverter.m
//  Mp4Split
//
//  Created by Kevin Scardina on 3/8/13.
//  Copyright (c) 2013 Kevin Scardina. All rights reserved.
//

#import "POPTimeConverter.h"

@implementation POPTimeConverter
+ (NSString*) timeStringFromQTTime:(QTTime)qtTime
{
	float secs = ((float)qtTime.timeValue/(float)qtTime.timeScale);
	return [POPTimeConverter timeStringFromSecs:secs];
	/*NSString* rtn = QTStringFromTime(qtTime);
	rtn = [[rtn substringFromIndex:[rtn rangeOfString:@":"].location+1] stringByDeletingLastPathComponent];
	return rtn;*/
}

+ (float) secsFromTimeString:(NSString*)str
{
	NSArray* matches = [str componentsSeparatedByString:@":"];
	if([matches count] == 3)
	{
		int hours = [(NSString*)matches[0] intValue]*3600;
		int mins = [(NSString*)matches[1] intValue]*60;
		float secs = [(NSString*)matches[2] floatValue];
		return (float)hours+(float)mins+(float)secs;
	}
	return 0.0;
}

+ (NSString*) timeStringFromSecs:(float)secs
{
	NSDateFormatter* datefmt = [[NSDateFormatter alloc] initWithDateFormat:@"%02H:%02M:%02S" allowNaturalLanguage:NO];
	NSDate *date = [NSDate dateWithTimeIntervalSince1970:secs-61200.0];
	NSString *datestr = [datefmt stringFromDate:date];
	return [NSString stringWithFormat:@"%@.%03i", datestr, (int)((secs-(float)floor(secs))*1000)];
}
@end
