//
//  POPMp4Splitter.m
//  Mp4Split
//
//  Created by Kevin Scardina on 3/9/13.
//  Copyright (c) 2013 Kevin Scardina. All rights reserved.
//

#import "POPMp4Splitter.h"

@implementation POPMp4Splitter
{
	NSMutableArray* tasks;
	int currentTaskIdx;
	id <POPMp4SplitterDelegate> _delegate;
}
+(NSTask*) createTaskWithStart:(NSString*)ss Length:(NSString*)len Source:(NSString*)src Destination:(NSString*)dst{
	
	NSTask* task = [[NSTask alloc] init];
	[task setLaunchPath:@"/usr/local/bin/ffmpeg"];
	[task setStandardOutput:[NSPipe pipe]];
	[task setStandardError:[task standardOutput]];
	[task setArguments:[NSArray arrayWithObjects:@"-ss", ss, @"-t", len, @"-i", src,
						@"-acodec", @"copy", @"-vcodec", @"copy", dst,nil]];
	return task;
}

-(id) initWithTasks:(NSArray*)tsks{
	_delegate = nil;
	tasks = [[NSMutableArray alloc]init];
	for(int i = 0; i < [tsks count]; i++)
	{
		[tasks addObject:[tsks objectAtIndex:i]];
	}
	currentTaskIdx = 0;
	return self;
}

-(void) setDelegate:(id)delegate{
	_delegate = delegate;
}

- (void)taskExited
{
    NSTask* task = (NSTask*)[tasks objectAtIndex:currentTaskIdx];
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:NSFileHandleReadCompletionNotification
     object:[[task standardOutput] fileHandleForReading]];
    //[[self splitInfoThread] cancel];
    
    /*if(splitting)
    {
        [[self splitOutput] setString:[[[self splitOutput] string] stringByAppendingString:allSplitInfo]];
        [task waitUntilExit];
        if([task terminationStatus] == 0)
        {
            [[self splitOutput] setString:[[[self splitOutput] string] stringByAppendingString:[NSString stringWithFormat:@"Task %@ completed successfully.\n\n", [[task arguments] componentsJoinedByString:@" "]]]];
        }
        else
        {
            [[self splitOutput] setString:[[[self splitOutput] string] stringByAppendingString:[NSString stringWithFormat:@"Task %@ FAILED.\n\n", [[task arguments] componentsJoinedByString:@" "]]]];
        }
    }
    else
    {
        [[self splitOutput] setString:[[[self splitOutput] string] stringByAppendingString:[NSString stringWithFormat:@"Task %@ cancelled.\nWhy you living me baby???\n\n", [[task arguments] componentsJoinedByString:@" "]]]];
    }
    [[self splitOutput] scrollToEndOfDocument:nil];*/
	currentTaskIdx += 1;
    if(_delegate != nil)
	{
		[_delegate mp4TaskProgress:((float)currentTaskIdx/(float)[tasks count])*100.0];
	}
    if(currentTaskIdx < [tasks count])
    {
        [self runCurrentTask];
    }
    else
    {
        if(_delegate != nil)
		{
			[_delegate mp4SplitExit];
		}
    }
}

-(void) taskReadStdOut:(NSNotification*)noti
{
    //NSError *error;
    NSData* data = [[noti userInfo] objectForKey:NSFileHandleNotificationDataItem];
    if([data length])
    {
        /*NSString* sd = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        allSplitInfo = [allSplitInfo stringByAppendingString:sd];
        sd = nil;
        
        allSplitInfo = [allSplitInfo stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        NSString* s = @"";
        if ([allSplitInfo rangeOfString:@"\n" options:NSBackwardsSearch].location != NSNotFound) {
            s = [[allSplitInfo substringFromIndex:[allSplitInfo rangeOfString:@"\n" options:NSBackwardsSearch].location+1] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\n"]];
        }
        if([s rangeOfString:@"frame=" options:NSBackwardsSearch].location != NSNotFound)
        {
            s = [s substringFromIndex:[s rangeOfString:@"frame=" options:NSBackwardsSearch].location];
            
            NSRegularExpression* rx = [NSRegularExpression regularExpressionWithPattern:@"[0-9]{2}\\:[0-9]{2}\\:[0-9]{2}\\.{0,1}[0-9]{0,2}" options:NSRegularExpressionCaseInsensitive error:&error];
            
            runningLength = [self secsFromTimeStr:[s substringWithRange:[rx rangeOfFirstMatchInString:s options:0 range:NSMakeRange(0, [s length])]]] + oldRunLength;
            
            [[self splitProgIndicator] setDoubleValue:runningLength];
            NSLog(@"pos = %f/%f", runningLength, totalLength);
        }
        if(s != nil && s != @"")
        {
            if([s length] > 100)
            {
                s = [s substringFromIndex:[s length] - 99];
            }
            [[self splitInfo] setStringValue:s];
        }*/
		NSString* datastr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		NSLog(@"%@", datastr);
    }
    else {
        [self taskExited];
    }
    [[noti object] readInBackgroundAndNotify];
}

-(void) runCurrentTask
{
    NSLog(@"%d: Running Task", currentTaskIdx);
    NSTask* task = (NSTask*)[tasks objectAtIndex:currentTaskIdx];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(taskReadStdOut:)
     name:NSFileHandleReadCompletionNotification
     object:[[task standardOutput] fileHandleForReading]
     ];
    [[[task standardOutput] fileHandleForReading] readInBackgroundAndNotify];
    
    NSLog(@"Running task %@...\n", [[task arguments] componentsJoinedByString:@" "]);
    
    [task launch];
}

-(void) launch{
	currentTaskIdx = 0;
	[self runCurrentTask];
}

@end
