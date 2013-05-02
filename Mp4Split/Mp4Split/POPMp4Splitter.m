//
//  POPMp4Splitter.m
//  Mp4Split
//
//  Created by Kevin Scardina on 3/9/13.
//  Copyright (c) 2013 Kevin Scardina. All rights reserved.
//

#import "POPMp4Splitter.h"
#import "POPmp4v2dylibloader.h"
#import "POPTimeConverter.h"

@implementation POPMp4Splitter
{
	NSMutableArray* tasks;
	NSMutableArray* chapters;
	int currentTaskIdx;
	float currentTaskDuration;
	id <POPMp4SplitterDelegate> _delegate;
	bool splitting;
}

+(NSTask*) createTaskWith:(NSString*)src Destination:(NSString*)dst Start:(NSString*)ss Length:(NSString*)len
{
	
	NSTask* task = [[NSTask alloc] init];
	
	NSString* ffmpeg_path = [[NSUserDefaults standardUserDefaults] objectForKey:@"ffmpeg-path"];
	if(ffmpeg_path == nil) ffmpeg_path = @"";
	if([ffmpeg_path compare:@""] == 0)
	{
		ffmpeg_path = [[NSBundle mainBundle] pathForResource:@"ffmpeg" ofType:nil];
	}
	
	[task setLaunchPath:ffmpeg_path];
	[task setStandardOutput:[NSPipe pipe]];
	[task setStandardError:[task standardOutput]];
//	[task setArguments:[NSArray arrayWithObjects:@"-ss", ss, @"-t", len, @"-i", src, @"-copyts",
//						@"-acodec", @"copy", @"-vcodec", @"copy", dst,nil]];
	[task setArguments:[NSArray arrayWithObjects:
						@"-ss", ss,
						@"-t", len,
						@"-i", src,
						@"-map", @"0:0",
						@"-map", @"0:1",
						@"-copyts",
						@"-c:v", @"copy",
						@"-c:a:0", @"copy",
						@"-threads", @"0",
						dst,nil]];
	return task;
}

+(NSTask*) createConvertTaskWith:(NSString*)src Destination:(NSString*)dst Start:(NSString*)ss Length:(NSString*)len
{
	
	NSTask* task = [[NSTask alloc] init];
	
	NSString* ffmpeg_path = [[NSUserDefaults standardUserDefaults] objectForKey:@"ffmpeg-path"];
	if(ffmpeg_path == nil) ffmpeg_path = @"";
	if([ffmpeg_path compare:@""] == 0)
	{
		ffmpeg_path = [[NSBundle mainBundle] pathForResource:@"ffmpeg" ofType:nil];
	}
	
	[task setLaunchPath:ffmpeg_path];
	[task setStandardOutput:[NSPipe pipe]];
	[task setStandardError:[task standardOutput]];
	
	dst = [[dst stringByDeletingPathExtension] stringByAppendingString:@".mp4"];
	NSNumber* usePassthroughNumber = [[NSUserDefaults standardUserDefaults] objectForKey:@"use-passthrough"];
	BOOL usePassthrough = false;
	if(usePassthroughNumber != nil) usePassthrough = [usePassthroughNumber boolValue];
	if(usePassthrough)
	{
		[task setArguments:[NSArray arrayWithObjects:@"-ss", ss, @"-t", len, @"-i", src,
							@"-copyts", @"-vsync", @"passthrough",
							@"-acodec", @"libfaac", @"-ac", @"2", @"-ab", @"128k",
							@"-vcodec", @"libx264", @"-threads", @"0", dst,nil]];
	}
	else
	{
		[task setArguments:[NSArray arrayWithObjects:@"-ss", ss, @"-t", len, @"-i", src, @"-copyts",
							@"-acodec", @"libfaac", @"-ac", @"2", @"-ab", @"128k",
							@"-vcodec", @"libx264", @"-threads", @"0", dst,nil]];
	}
	return task;
}

+(BOOL) ffmpegIsWorking:(NSString*)ffmpeg_path
{
	NSTask* task = [[NSTask alloc] init];
	
	if(ffmpeg_path == nil) ffmpeg_path = @"";
	if([ffmpeg_path compare:@""] == 0)
	{
		ffmpeg_path = [[NSBundle mainBundle] pathForResource:@"ffmpeg" ofType:nil];
	}
	
	[task setLaunchPath:ffmpeg_path];
	[task setStandardOutput:[NSPipe pipe]];
	[task setStandardError:[task standardOutput]];
	[task setArguments:[NSArray arrayWithObjects:@"-version", nil]];
	[task launch];
	[task waitUntilExit];
	//NSLog(@"%i", [task terminationStatus]);
	if([task terminationStatus] == 0)
	{
		return YES;
	}
	return NO;
}

-(id) initWithTasks:(NSArray*)tsks Chapters:(NSArray *)chaps
{
	_delegate = nil;
	//copy the chaps array into chapters
	tasks = [[NSMutableArray alloc] init];
	chapters = [[NSMutableArray alloc] init];
	for (NSDictionary* chap in chaps) {
		NSLog(@"Chapter start time %f, duration %f",  [[chap objectForKey:@"startTime"] floatValue],  [[chap objectForKey:@"duration"] floatValue]);
	}
	for(int i = 0; i < [tsks count]; i++)
	{
		NSTask* tsk = [tsks objectAtIndex:i];
		[tasks addObject:tsk];
		
		NSMutableArray* mchaps = [[NSMutableArray alloc] init];
		float st = [POPTimeConverter secsFromTimeString:[[[tsk arguments] objectAtIndex:1] copy]];
		float dur = [POPTimeConverter secsFromTimeString:[[[tsk arguments] objectAtIndex:3] copy]];
		float et = st + dur;
		int ii = 1;
		NSLog(@"Task %i: %f to %f:", i, st, et);
		for(NSDictionary* chap in chaps)
		{
			float cst = [[chap objectForKey:@"startTime"] floatValue];
			if(cst > st && cst <= et)
			{
				float ndur = cst - st;
				NSString* ntitle = [NSString stringWithFormat:@"%i", ii++];
				st = cst;
				NSLog(@"Chapter %i duration %f", ii, ndur);
				NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:
									 ntitle, @"title",
									 [NSNumber numberWithFloat:ndur], @"duration",
									 nil];
				[mchaps addObject:dic];
			}
		}
		[chapters addObject:mchaps];
	}
	splitting = false;
	currentTaskIdx = 0;
	currentTaskDuration = 0.0;
	return self;
}

-(void) setDelegate:(id)delegate
{
	_delegate = delegate;
}

-(NSString*) taskSourcePathAt:(NSInteger)idx
{
	if(idx < [tasks count])
	{
		return [[[tasks objectAtIndex:idx] arguments] objectAtIndex:5];
	}
	return @"";
}

-(NSString*) taskDestinationPathAt:(NSInteger)idx
{
	if(idx < [tasks count])
	{
		NSArray * args = [[tasks objectAtIndex:idx] arguments];
		return [args objectAtIndex:[args count]-1];
	}
	return @"";
}

-(NSString*) taskStartTimeStringAt:(NSInteger)idx
{
	if(idx < [tasks count])
	{
		return [[[tasks objectAtIndex:idx] arguments] objectAtIndex:1];
	}
	return @"";
}

-(NSString*) taskLengthTimeStringAt:(NSInteger)idx
{
	if(idx < [tasks count])
	{
		return [[[tasks objectAtIndex:idx] arguments] objectAtIndex:3];
	}
	return @"";
}

-(BOOL) isSplitting
{
	return splitting;
}

- (void)taskExited
{
	NSTask* task = (NSTask*)[tasks objectAtIndex:currentTaskIdx];
	NSString* outPath = [[[task arguments] objectAtIndex:([[task arguments] count] - 1)] copy];
    [[NSNotificationCenter defaultCenter] 
     removeObserver:self
     name:NSFileHandleReadCompletionNotification
     object:[[task standardOutput] fileHandleForReading]];
    //[[self splitInfoThread] cancel];
    
    if(!splitting)
    {
        if(_delegate != nil)
		{
			[_delegate mp4SplitExit];
		}
		return;
    }
	[task waitUntilExit];
	if([task terminationStatus] != 0)
	{
		NSRunAlertPanel(@"FFMPEG ERROR", [NSString stringWithFormat:@"ffmpeg was unable to complete its task with exit status %i", [task terminationStatus]], @"OK", nil, nil);
	}
	else
	{
		NSArray* cchps = [chapters objectAtIndex:currentTaskIdx];
#pragma mark Add mp4 chapters
		//add the mp4 chapter marks.
		MP4FileHandle mp4File = _MP4Modify([outPath cStringUsingEncoding:NSStringEncodingConversionAllowLossy], 0);
		if(mp4File != NULL)
		{
			MP4Chapter_t* mp4Chapters = malloc(sizeof(MP4Chapter_t)*[cchps count]);
			//		NSMutableArray* m4vChapters = [NSMutableArray array];
			//		unsigned long long chap_st_secs = 0.0;
			for(int i = 0; i < [cchps count]; i++)
			{
				float chap_len_secs = [[[cchps objectAtIndex:i] objectForKey:@"duration"] floatValue];
				NSString* chap_name = [[cchps objectAtIndex:i] objectForKey:@"title"];
				
				mp4Chapters[i].duration = chap_len_secs * 1000.0;
				strcpy(mp4Chapters[i].title, [chap_name cStringUsingEncoding:NSStringEncodingConversionAllowLossy]);
				
				//			chap_st_secs += chap_len_secs;
				//			QTTime t_qt_time = QTMakeTime(chap_len_secs * 1000, 1000);
				//			NSValue* m4v_chap_qttime = [NSValue valueWithQTTime:t_qt_time];
				//			NSDictionary* new_m4v_chap = [NSDictionary dictionaryWithObjectsAndKeys:
				//										  chap_name, QTMovieChapterName,
				//										  m4v_chap_qttime, QTMovieChapterStartTime,
				//										  nil];
				//			NSDictionary* new_m4v_chap_attrs = [NSDictionary dictionaryWithObjectsAndKeys:
				//												, nil]
			}
			if(_MP4SetChapters(mp4File, mp4Chapters, (unsigned int)[cchps count], MP4ChapterTypeAny) != MP4ChapterTypeAny)
			{
				NSLog(@"Chapters were not able to be set");
			}
			_MP4Close(mp4File, 0);
			free(mp4Chapters);
		}
	}
	currentTaskIdx += 1;
    if(_delegate != nil)
	{
		[_delegate mp4TaskProgress:((float)currentTaskIdx/(float)[tasks count])*100.0];
	}
    if(currentTaskIdx < [tasks count])
    {
        if(splitting)
		{
			[self runCurrentTask];
		}
		else
		{
			currentTaskIdx++;
		}
    }
    else
    {
		splitting =  NO;
        if(_delegate != nil)
		{
			[_delegate mp4SplitExit];
		}
    }
}

-(void) taskReadStdOut:(NSNotification*)noti
{
    //NSError *error;
	if(splitting == false)
	{
		NSTask* task = [tasks objectAtIndex:currentTaskIdx];
		[task terminate];
		[self taskExited];
	}
	else
	{
		NSData* data = [[noti userInfo] objectForKey:NSFileHandleNotificationDataItem];
		if([data length])
		{
			@try
			{
				NSString* datastr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
				NSArray* lines = [datastr componentsSeparatedByString:@"\r"];
				for (int i = 0; i < [lines count]; i++)
				{
					NSString* line = lines[i];
					NSRange rng = [line rangeOfString:@"time="];
					if(rng.location != NSNotFound)
					{
						NSError* rxError;
						NSRegularExpression* rx = [NSRegularExpression regularExpressionWithPattern:@"[0-9]{2}\\:[0-9]{2}\\:[0-9]{2}\\.{0,1}[0-9]{0,2}" options:NSRegularExpressionCaseInsensitive error:&rxError];
						NSString* timeStr = [line substringWithRange:[rx rangeOfFirstMatchInString:line options:0 range:NSMakeRange(0,[line length])]];
						float currentSecs = [POPTimeConverter secsFromTimeString:timeStr];
						if(_delegate != nil)
						{
							[_delegate mp4FileProgress:(currentSecs/currentTaskDuration)*100];
						}
					}
				}
			}
			@catch (NSException *e)
			{
				NSLog(@"Exception: %@", [e description]);
				NSLog(@"Carry on my son...");
			}
			//NSLog(@"%@", datastr);
		}
		else {
			[self taskExited];
		}
		[[noti object] readInBackgroundAndNotify];
	}
}

-(void) runCurrentTask
{
	NSTask* task = (NSTask*)[tasks objectAtIndex:currentTaskIdx];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(taskReadStdOut:)
     name:NSFileHandleReadCompletionNotification
     object:[[task standardOutput] fileHandleForReading]
     ];
    [[[task standardOutput] fileHandleForReading] readInBackgroundAndNotify];
    
    currentTaskDuration = [POPTimeConverter secsFromTimeString:[[task arguments] objectAtIndex:3]];
	NSLog(@"Running task:\n ffmpeg %@", [[task arguments] componentsJoinedByString:@" "]);
    
    [task launch];
}

-(void) launch
{
	splitting = true;
	currentTaskIdx = 0;
	[self runCurrentTask];
}

-(void) cancel
{
	splitting = false;
}

@end
