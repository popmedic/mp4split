//
//  POPAppDelegate.m
//  Mp4Split
//
//  Created by Kevin Scardina on 3/8/13.
//  Copyright (c) 2013 Kevin Scardina. All rights reserved.
//
#import "POPAppDelegate.h"
#import "POPmp4v2dylibloader.h"

@implementation POPMainWindow
- (BOOL)windowShouldClose:(id)sender
{
	POPMp4Splitter* splitter = [(POPAppDelegate*)[NSApp delegate] splitter];
	if(splitter != nil)
	{
		if([splitter isSplitting])
		{
			if(NSRunAlertPanel(@"Currently splitting!!!", @"You are currently splitting are you sure you want to quit?", @"Cancel", @"Quit", nil) == NSAlertDefaultReturn)
			{
				return false;
			}
			else
			{
				[splitter cancel];
				return true;
			}
		}
	}
	return true;
}
@end

@implementation POPAppDelegate
{
	NSURL* source;
	NSTimer* sliderTimer;
	long long oldSliderValue;
	NSMutableArray* splits;
	double currentFrameRate;
	NSArray* currentChapters;
	BOOL mp4Loading;
	POPMp4Splitter* _splitter;
	NSString* outputPrefix;
	NSInteger outputAddToIndex;
}
- (void)dealloc
{
    [super dealloc];
}

-(NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{	
	CGFloat f = [[[[self mainVerticalSplitView] subviews] objectAtIndex:0] frame].size.width;
	[[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithFloat:f] forKey:@"vsplit1"];
	f = [[[[self mainVerticalSplitView] subviews] objectAtIndex:1] frame].size.width;
	[[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithFloat:f] forKey:@"vsplit2"];
	
	[self stopSliderTimer];
	sliderTimer = nil;
	_splitter = nil;
	splits = nil;
	
	return NSTerminateNow;
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
	return YES;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	// Insert code here to initialize your application
	_splitter = nil;
	sliderTimer = nil;
	mp4Loading = NO;
	oldSliderValue = 0.0;
	splits = [[NSMutableArray alloc] init];
	[[self mp4Player] setMovie:nil];
	
	CGFloat f = [[[NSUserDefaults standardUserDefaults] valueForKey:@"vsplit1"] floatValue];
	NSSize size;
	if(f != 0){
		size = [[[[self mainVerticalSplitView] subviews] objectAtIndex:0] frame].size;
		size.width = f;
		[[[[self mainVerticalSplitView] subviews] objectAtIndex:0] setFrameSize:size];
		f = [[[NSUserDefaults standardUserDefaults] valueForKey:@"vsplit2"] floatValue];
		size = [[[[self mainVerticalSplitView] subviews] objectAtIndex:1] frame].size;
		size.width = f;
		[[[[self mainVerticalSplitView] subviews] objectAtIndex:1] setFrameSize:size];
	}
	
	[[self splitsTableView] setDoubleAction:@selector(splitsTableViewDoubleClick:)];
	
	[self startSliderTimer];
	[self refreshButtons];
}

- (void)refreshButtons
{
	BOOL ppbe = YES;
	BOOL mse = YES;
	BOOL sbe = YES;
	BOOL asbe = YES;
	BOOL rsbe = YES;
	BOOL cme = YES;
	if([[self mp4Player] movie] == nil)
	{
		ppbe = NO;
		mse = NO;
		sbe = NO;
		asbe = NO;
		rsbe = NO;
		cme = NO;
	}
	else if([splits count] < 2)
	{
		sbe = NO;
	}
	if([[self splitsTableView] selectedRow] < 0)
	{
		rsbe = NO;
	}
	[[self playPauseButton] setEnabled:ppbe];
	[[self mp4Slider] setEnabled:mse];
	[[self addSplitButton] setEnabled:asbe];
	[[self removeSplitButton] setEnabled:rsbe];
	[[self controlMenu] setEnabled:cme];
	if(sbe == YES)
	{
		[[self splitButton] setAction:@selector(splitButtonClick:)];
	}
	else
	{
		[[self splitButton] setAction:nil];
	}
}

- (void) refreshTables
{
	[[self splitsTableView] reloadData];
	[[self segmentsTableView] reloadData];
}

- (double)getMovieFrameRate:(QTMovie*)movie
{
	double result = 0;
	
    for (QTTrack* track in [movie tracks])
    {
        QTMedia* media = [track media];
		
        if ([media hasCharacteristic:QTMediaCharacteristicHasVideoFrameRate])
        {
            QTTime mediaDuration = [(NSValue*)[media attributeForKey:QTMediaDurationAttribute] QTTimeValue];
            long long mediaDurationScaleValue = mediaDuration.timeScale;
            long mediaDurationTimeValue = mediaDuration.timeValue;
            long mediaSampleCount = [(NSNumber*)[media attributeForKey:QTMediaSampleCountAttribute] longValue];
            result = (double)mediaSampleCount * ((double)mediaDurationScaleValue / (double)mediaDurationTimeValue);
            break;
        }
    }

    return result;
}

- (void)removeSubtitleTracks:(QTMovie*) movie
{
	int ti = 0;
	for (QTTrack* track in [movie tracks])
    {
		NSString* mt = [[track trackAttributes] objectForKey:QTTrackMediaTypeAttribute];
		NSNumber* layer = [[track trackAttributes] objectForKey:QTTrackLayerAttribute];
		NSLog(@"Track %i Type/layer: %@/%i", ti, mt, [layer shortValue]);
//		if([mt compare:@"vide"] == 0 && [layer shortValue] == -1)
//		{
//			[track setEnabled:NO];
//			DisposeMovieTrack([track quickTimeTrack]);
//		}
		ti++;
    }
}

- (IBAction)chapterMenuItemClick:(id)sender {
	if([[self mp4Player] movie] != nil)
	{
		/*currentChapters = [[[self mp4Player] movie] chapters];
		NSDictionary* chapter = [currentChapters objectAtIndex:[sender tag]];
		QTTime qttime;
		[[chapter objectForKey:QTMovieChapterStartTime] getValue:&qttime];
		[[[self mp4Player] movie] setCurrentTime:qttime];*/
		NSArray* a = [[sender title] componentsSeparatedByString:@" - "];
		QTTime qttime = [POPTimeConverter qttimeFromSecs:[POPTimeConverter secsFromTimeString:[a objectAtIndex:1]] Scale:[[[self mp4Player] movie] currentTime].timeScale];
		[[[self mp4Player] movie] setCurrentTime:qttime];
	}
}
- (void)unloadMovieChapters
{
	while([[[self chaptersMenu] itemArray] count] > 0)
	{
		[[self chaptersMenu] removeItemAtIndex:0];
	}
}
- (void)loadMovieChapters:(QTMovie*)movie
{
	if(movie != nil)
	{
		if([movie chapterCount] > 0)
		{
			currentChapters = [movie chapters];
			
			for(int i = 0; i < [currentChapters count]; i++) {
				NSDictionary* chapter = [currentChapters objectAtIndex:i];
				NSString* name = [chapter objectForKey:QTMovieChapterName];
				QTTime qttime;
				[[chapter objectForKey:QTMovieChapterStartTime] getValue:&qttime];
				NSString* time = [POPTimeConverter timeStringFromQTTime:qttime FrameRate:currentFrameRate];
				NSString* title = [NSString stringWithFormat:@"%@ - %@", name, time];
				NSMenuItem* item = [[NSMenuItem alloc] initWithTitle:title action:@selector(chapterMenuItemClick:) keyEquivalent:@""];
				[item setTag:i];
				[[self chaptersMenu] addItem:item];
			}
		}
		else
		{
			[POPmp4v2dylibloader loadMp4v2Lib:[[NSBundle mainBundle] pathForResource:@"libmp4v2.2" ofType:@"dylib"]];
			MP4FileHandle mp4file = _MP4Modify([[source path] cStringUsingEncoding:NSStringEncodingConversionAllowLossy], 0);
			unsigned int chapCnt;
			MP4Chapter_t *gchaps;
			_MP4GetChapters(mp4file, &gchaps, &chapCnt, MP4ChapterTypeNero);
			_MP4Close(mp4file, 0);
			if(gchaps != NULL)
			{
				MP4Duration st = 0.0;
				for(int i = 0; i < chapCnt; i++)
				{
					NSString* name = [NSString stringWithCString:gchaps[i].title encoding:NSStringEncodingConversionAllowLossy];
					NSString* time = [POPTimeConverter timeStringFromSecs:(float)st/1000.0];
					NSString* title = [NSString stringWithFormat:@"%@ - %@", name, time];
					NSMenuItem* item = [[NSMenuItem alloc] initWithTitle:title action:@selector(chapterMenuItemClick:) keyEquivalent:@""];
					[item setTag:i];
					[[self chaptersMenu] addItem:item];
					st = st + gchaps[i].duration;
				}
				_MP4Free(gchaps);
			}
		}
	}
}

- (void)refreshSlider:(NSTimer*)theTimer
{
	if([[self mp4Player] movie] != nil)
	{
		if(mp4Loading == YES)
		{
			float dur = [[[self mp4Player] movie] duration].timeValue;
			float max = [[[self mp4Player] movie] maxTimeLoaded].timeValue;
			double res = max/dur;
			[[self mp4LoadingProgressIndicator] setDoubleValue:res*100];
			if(res == 1)
			{
				[[self mp4LoadingProgressIndicator] setHidden:YES];
				mp4Loading = NO;
			}
			
		}
		if(oldSliderValue == [[[self mp4Player] movie] currentTime].timeValue)
		{
			[[self playPauseButton] setState:NO];
		}
		else
		{
			[[self playPauseButton] setState:YES];
			[[self mp4Slider] setFloatValue:[[[self mp4Player] movie] currentTime].timeValue];
			[[self positionLabel] setStringValue:[POPTimeConverter timeStringFromQTTime:[[[self mp4Player] movie] currentTime] FrameRate:currentFrameRate]];
		}
		oldSliderValue = [[[self mp4Player] movie] currentTime].timeValue;
	}
	else if([[self mp4Slider] isEnabled] == NO)
	{
		[[self mp4Slider] setFloatValue:0.0];
	}
}

- (void)startSliderTimer
{
    
    [self stopSliderTimer];
    sliderTimer = [NSTimer timerWithTimeInterval:0.25 target:self selector:@selector(refreshSlider:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:sliderTimer forMode:NSDefaultRunLoopMode];
}

- (void)stopSliderTimer
{
    if(sliderTimer != nil)
    {
        [sliderTimer invalidate];
        sliderTimer = nil;
    }
}

- (void) openMp4:(NSURL*)url
{
	NSError* error;
//	QTMovie *nm = [[QTMovie alloc] initWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[url path], QTMovieFileNameAttribute, [NSNumber numberWithBool:NO], QTMovieEditableAttribute, [NSNumber numberWithBool:YES], QTMovieOpenAsyncOKAttribute, nil] error:&error];
	QTMovie *nm = [QTMovie movieWithURL:url error:&error];
	if(nm)
	{
		source = [url copy];
		[[self mp4Slider] setMinValue:0.0];
		[[self mp4Slider] setMaxValue:[nm duration].timeValue];
		[[self mp4Slider] setFloatValue:0.0];
		[[self mp4LoadingProgressIndicator] setDoubleValue:0];
		[[self volumeSlider] setFloatValue:[nm volume]];
		[[self positionLabel] setStringValue:@"00:00:00.000"];
		currentFrameRate = [self getMovieFrameRate:nm];
		[self loadMovieChapters:nm];
		[self removeSubtitleTracks:nm];
		[[self mp4Player] setMovie:nm];
		[[self mp4LoadingProgressIndicator] setHidden:NO];
		mp4Loading = YES;
		[self refreshButtons];
		[self refreshTables];
		
//		NSMutableString* outStr = [[NSMutableString alloc] initWithString:
//								   [NSString stringWithFormat:@"Movie \"%@\" Attributes:\n\n", [url path]]];
//		NSDictionary* attrs = [nm movieAttributes];
//		NSEnumerator* keyEnumerator = [attrs keyEnumerator];
//		id key;
//		while((key = [keyEnumerator nextObject]) != nil)
//		{
//			[outStr appendFormat:@"\t%@: %@\n", key, [attrs objectForKey:key]];
//		}
//		[outStr appendString:@"\nTracks:"];
//		NSArray* tracks = [nm tracks];
//		for (int i = 0; i < [tracks count]; i++)
//		{
//			
//			QTTrack* track = [tracks objectAtIndex:i];
//			[outStr appendFormat:@"\n\tTrack %i", i];
//			NSDictionary* trackAttrs = [track trackAttributes];
//			keyEnumerator = [trackAttrs keyEnumerator];
//			while((key = [keyEnumerator nextObject]) != nil)
//			{
//				[outStr appendFormat:@"\n\t\t%@: %@", key, [trackAttrs objectForKey:key]];
//			}
//		}
//		NSLog(@"%@", outStr);
	}
	else
	{
		NSRunAlertPanel(@"UNABLE TO OPEN",
						[NSString stringWithFormat:@"Unable to open:%@\n\nReason:\n%@", [url path], [error description]],
						@"Ok",
						nil,
						nil);
	}
}
- (IBAction)openMp4Click:(id)sender {
	
	NSOpenPanel* oDlg = [NSOpenPanel openPanel];
	[oDlg setCanChooseFiles:YES];
    [oDlg setCanCreateDirectories:NO];
    [oDlg beginSheetModalForWindow:[self window] completionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton)
        {
			[self closeMp4];
            NSArray* urls = [oDlg URLs];
            NSURL *url = [urls objectAtIndex:0];
            [self openMp4:url];
        }
    }];
}

- (void) closeMp4{
	if([[self mp4Player] movie] != nil)
	{
		[[[self mp4Player] movie] stop];
		[[self mp4Player] setMovie:nil];
		[splits removeAllObjects];
		[self unloadMovieChapters];
		[self refreshButtons];
		[self refreshTables];
	}
}
- (IBAction)closeMp4Click:(id)sender {
	[self closeMp4];
}

- (IBAction)playPauseClick:(id)sender {
	if([[self mp4Player] movie] != nil)
	{
		if([[self playPauseButton] state] == NO)
		{
			[[[self mp4Player] movie] stop];
		}
		else{
			[[[self mp4Player] movie] play];
		}
	}
}

- (IBAction)volumeSliderSeek:(id)sender {
	if([[self mp4Player] movie] != nil)
	{
		[[[self mp4Player] movie] setVolume:[[self volumeSlider] floatValue]];
	}
}

- (IBAction)mp4SliderSeek:(id)sender {
	if([[self mp4Player] movie] != nil)
	{
		QTTime qtt = QTMakeTime((long)(long)[[self mp4Slider] floatValue], [[[self mp4Player] movie] currentTime].timeScale);
		[[[self mp4Player] movie] setCurrentTime:qtt];
	}
}

- (IBAction)playPauseMenuClick:(id)sender {
	if([[self mp4Player] movie] != nil)
	{
		if([[self playPauseButton] state] == YES)
		{
			[[[self mp4Player] movie] stop];
		}
		else{
			[[[self mp4Player] movie] play];
		}
	}
}

- (IBAction)reversePlayClick:(id)sender {
	if([[self mp4Player] movie] != nil)
	{
		float r = [[[self mp4Player] movie] rate];
		r = r*-1;
		[[[self mp4Player] movie] setRate:r];
	}
}

- (IBAction)speedUpClick:(id)sender {
	if([[self mp4Player] movie] != nil)
	{
		float r = [[[self mp4Player] movie] rate];
		r = r*2;
		[[[self mp4Player] movie] setRate:r];
	}
}

- (IBAction)slowDownClick:(id)sender {
	if([[self mp4Player] movie] != nil)
	{
		float r = [[[self mp4Player] movie] rate];
		if(r!=0)
		{
			r = r/2;
		}
		[[[self mp4Player] movie] setRate:r];
	}
}

- (IBAction)nudgeForwardClickx1:(id)sender {
	if([[self mp4Player] movie] != nil)
	{
		float csecs = [POPTimeConverter secsFromQTTime:[[[self mp4Player] movie] currentTime] FrameRate:currentFrameRate];
		QTTime nqt = [POPTimeConverter qttimeFromSecs:csecs+1.0 Scale:[[[self mp4Player] movie] currentTime].timeScale];
		[[[self mp4Player] movie] setCurrentTime:nqt];
	}
}

- (IBAction)nudgeForwardx10Click:(id)sender {
	if([[self mp4Player] movie] != nil)
	{
		float csecs = [POPTimeConverter secsFromQTTime:[[[self mp4Player] movie] currentTime] FrameRate:currentFrameRate];
		QTTime nqt = [POPTimeConverter qttimeFromSecs:csecs+10.0 Scale:[[[self mp4Player] movie] currentTime].timeScale];
		[[[self mp4Player] movie] setCurrentTime:nqt];
	}
}

- (IBAction)nudgeBackwardx1Click:(id)sender {
	if([[self mp4Player] movie] != nil)
	{
		float csecs = [POPTimeConverter secsFromQTTime:[[[self mp4Player] movie] currentTime] FrameRate:currentFrameRate];
		QTTime nqt = [POPTimeConverter qttimeFromSecs:csecs-1.0 Scale:[[[self mp4Player] movie] currentTime].timeScale];
		[[[self mp4Player] movie] setCurrentTime:nqt];
	}
}

- (IBAction)nudgeBackwardx10Click:(id)sender {
	if([[self mp4Player] movie] != nil)
	{
		float csecs = [POPTimeConverter secsFromQTTime:[[[self mp4Player] movie] currentTime] FrameRate:currentFrameRate];
		QTTime nqt = [POPTimeConverter qttimeFromSecs:csecs-10.0 Scale:[[[self mp4Player] movie] currentTime].timeScale];
		[[[self mp4Player] movie] setCurrentTime:nqt];
	}
}

-(void)addSplit:(QTTime)time
{
	NSString* addStr = [POPTimeConverter timeStringFromQTTime:time FrameRate:currentFrameRate];
	NSImage* img = [[[self mp4Player] movie] frameImageAtTime:time];
	NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:addStr, @"startTimeStr", img, @"image", nil];
	[splits addObject:dic];
	[splits sortUsingComparator:^(id o1, id o2){
		return [(NSString*)[(NSDictionary*)o1 objectForKey:@"startTimeStr"]  compare:(NSString*)[(NSDictionary*)o2 objectForKey:@"startTimeStr"]];
	}];
	
	for(int i = 0; i < [splits count]; i++)
	{
		NSDictionary* dic = [splits objectAtIndex:i];
		if([addStr compare:[dic objectForKey:@"startTimeStr"]] == 0)
		{
			[[self splitsTableView] selectRowIndexes:[NSIndexSet indexSetWithIndex:i] byExtendingSelection:NO];
			i = (int)[splits count];
		}
	}
}

- (IBAction)addSplitClick:(id)sender {
	/*NSString* addStr = [POPTimeConverter timeStringFromQTTime:[[[self mp4Player] movie] currentTime] FrameRate:currentFrameRate];
	NSImage* img = [[[self mp4Player] movie] frameImageAtTime:[[[self mp4Player] movie] currentTime]];
	[splits addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"startTimeStr", addStr, @"image", img, nil]];
	[splits sortUsingComparator:^(id o1, id o2){
		return [(NSString*)[(NSDictionary*)o1 objectForKey:@"startTimeStr"]  compare:(NSString*)[(NSDictionary*)o2 objectForKey:@"startTimeStr"]]; }];*/
	[self addSplit:[[[self mp4Player] movie] currentTime]];
	[self refreshButtons];
	[self refreshTables];
}

- (IBAction)removeSplitClick:(id)sender {
	NSInteger selectedRow = [[self splitsTableView] selectedRow];
		if(selectedRow > -1)
	{
		[splits removeObjectAtIndex:selectedRow];
		[self refreshButtons];
		[self refreshTables];
		if([splits count] > 0)
		{
			if(selectedRow < [splits count])
			{
				[[self splitsTableView] selectRowIndexes:[NSIndexSet indexSetWithIndex:selectedRow] byExtendingSelection:NO];
			}
			else
			{
				[[self splitsTableView] selectRowIndexes:[NSIndexSet indexSetWithIndex:[splits count]-1] byExtendingSelection:NO];
			}
		}
	}
}

- (IBAction)splitEveryChaptersClick:(id)sender
{
	if([[self mp4Player] movie] != nil)
	{
		NSAlert *alert = [NSAlert alertWithMessageText:@"Place a split every chapter?"
										 defaultButton:@"OK"
									   alternateButton:@"Cancel"
										   otherButton:nil
							 informativeTextWithFormat:@""];
		NSTextField *input = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 200, 24)];
		[input setStringValue:@"1"];
		[alert setAccessoryView:input];
		NSInteger choose = [alert runModal];
		if (choose == NSAlertDefaultReturn)
		{
			[POPmp4v2dylibloader loadMp4v2Lib:[[NSBundle mainBundle] pathForResource:@"libmp4v2.2" ofType:@"dylib"]];
			NSInteger everyXChpts = [[input stringValue] integerValue];
			MP4FileHandle mp4file = _MP4Modify([[source path] cStringUsingEncoding:NSStringEncodingConversionAllowLossy], 0);
			unsigned int chapCnt;
			MP4Chapter_t *gchaps;
			_MP4GetChapters(mp4file, &gchaps, &chapCnt, MP4ChapterTypeNero);
			_MP4Close(mp4file, 0);
			
			if(gchaps != NULL)
			{
				MP4Duration st = 0.0;
				for(NSInteger i = 0;i < chapCnt; i++)
				{
					if(i == 0)
					{
						NSString* startTimeStr = [POPTimeConverter timeStringFromSecs:(float)st/1000.0];
						NSImage* img = [[[self mp4Player] movie] frameImageAtTime:[POPTimeConverter qttimeFromSecs:(float)st/1000 Scale:[[[self mp4Player] movie] currentTime].timeScale]];
						[splits addObject:[NSDictionary dictionaryWithObjectsAndKeys:
										   startTimeStr,
										   @"startTimeStr",
										   img,
										   @"image",
										   nil]];
					}
					else if (i % everyXChpts == 0)
					{
						NSString* startTimeStr = [POPTimeConverter timeStringFromSecs:(float)st/1000.0];
						NSImage* img = [[[self mp4Player] movie] frameImageAtTime:[POPTimeConverter qttimeFromSecs:(float)st/1000 Scale:[[[self mp4Player] movie] currentTime].timeScale]];
						[splits addObject:[NSDictionary dictionaryWithObjectsAndKeys:
										   startTimeStr,
										   @"startTimeStr",
										   img,
										   @"image",
										   nil]];
					}
						
					st = st + gchaps[i].duration;
				}
				[self refreshTables];
				[self refreshButtons];
				_MP4Free(gchaps);
			}
		}
	}
}

- (IBAction)splitEverySecondsClick:(id)sender
{
	if([[self mp4Player] movie] != nil)
	{
		NSAlert *alert = [NSAlert alertWithMessageText:@"Place a split every chapter?"
										 defaultButton:@"OK"
									   alternateButton:@"Cancel"
										   otherButton:nil
							 informativeTextWithFormat:@""];
		NSTextField *input = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 200, 24)];
		[input setStringValue:@"1"];
		[alert setAccessoryView:input];
		NSInteger choose = [alert runModal];
		if (choose == NSAlertDefaultReturn)
		{
			double cur_secs = 0.0;
			double total_secs = [POPTimeConverter secsFromQTTime:[[[self mp4Player]movie]duration] FrameRate:currentFrameRate];
			double everyXSecs = [[input stringValue]doubleValue];
			if(everyXSecs > 0)
			{
				while(cur_secs < total_secs)
				{
					//[splits addObject:[POPTimeConverter timeStringFromSecs:cur_secs]];
					[splits addObject:[NSDictionary dictionaryWithObjectsAndKeys:
									   [POPTimeConverter timeStringFromSecs:cur_secs],
									   @"startTimeStr",
									   [[[self mp4Player] movie] frameImageAtTime:[POPTimeConverter qttimeFromSecs:(float)cur_secs Scale:[[[self mp4Player] movie] currentTime].timeScale]],
									   @"image",
									   nil]];
					cur_secs = cur_secs + everyXSecs;
				}
				[self refreshTables];
				[self refreshButtons];
			}
		}
	}
}

- (void) mp4SplitExit{
	[[self taskProgressIndicator] setHidden:YES];
	[[self fileProgressIndicator] setHidden:YES];
	[[self splitButton] setImage:[NSImage imageNamed:@"mp4split-128.png"]];
}
- (void)mp4FileProgress:(float)percent
{
	[[self fileProgressIndicator] setDoubleValue:percent];
}
- (void)mp4TaskProgress:(float)percent
{
	[[self taskProgressIndicator] setDoubleValue:percent];
}
- (void)outputFilenameSheetDidEnd:(NSWindow *)sheet returnCode:(NSUInteger)returnCode contextInfo:(void *)contextInfo {
    [sheet orderOut:self];
    
    if (returnCode == 0)
	{
		 NSMutableArray* tasks = [[NSMutableArray alloc] init];
		 for(int i = 0; i < [splits count]-1; i++)
		 {
			 NSString* startstr = [[splits objectAtIndex:i] objectForKey:@"startTimeStr"];
			 float startsecs = [POPTimeConverter secsFromTimeString:startstr];
			 float lengthsecs = [POPTimeConverter secsFromTimeString:[[splits objectAtIndex:i+1] objectForKey:@"startTimeStr"]] - startsecs;
			 NSString* lengthstr = [POPTimeConverter timeStringFromSecs:lengthsecs];
			 
			 NSString* srcpath = [source path];
			 NSString* outFolder = (NSString*)[[NSUserDefaults standardUserDefaults] objectForKey:@"output-folder"];
			 NSString* choice = (NSString*)[[NSUserDefaults standardUserDefaults] objectForKey:@"output-folder-choice"];
			 NSString* dstpath = [srcpath stringByDeletingLastPathComponent];
			 if(outFolder == nil) outFolder = dstpath;
			 if(choice == nil) choice = @"0";
			 if([choice compare:@"1"] == 0)
			 {
				 dstpath = outFolder;
			 }
			 
			 NSString* nfn = [NSString stringWithFormat:@"%@/%@%i.%@", dstpath, outputPrefix, (i+1)+(int)outputAddToIndex, @"mp4"];
			 for(int ii = 1;[[NSFileManager defaultManager] fileExistsAtPath:nfn];ii++)
			 {
				 nfn = [NSString stringWithFormat:@"%@/%@%i(%i).%@", dstpath, outputPrefix, (i+1)+(int)outputAddToIndex, ii, @"mp4"];
			 }
			 
			 if([[srcpath pathExtension] compare:@"mp4" options:NSCaseInsensitiveSearch] == 0)
			 {
				 [tasks addObject:[POPMp4Splitter createTaskWith:srcpath Destination:nfn Start:startstr Length:lengthstr]];
			 }
			 else
			 {
				 [tasks addObject:[POPMp4Splitter createConvertTaskWith:srcpath Destination:nfn Start:startstr Length:lengthstr]];
			 }
		 }
		 if(_splitter != nil) _splitter = nil;
		 _splitter = [[POPMp4Splitter alloc] initWithTasks:tasks];
		 [_splitter setDelegate:self];
		 [[self taskProgressIndicator] setDoubleValue:0.0];
		 [[self taskProgressIndicator] setHidden:NO];
		 [[self fileProgressIndicator] setDoubleValue:0.0];
		 [[self fileProgressIndicator] setHidden:NO];
		 [[self splitButton] setImage:[NSImage imageNamed:@"mp4split-cancel-128.png"]];
		 [_splitter launch];
	}
}
- (IBAction)splitButtonClick:(id)sender {
	if([@"mp4split-128" compare:[[[self splitButton] image] name]] == 0)
	{
		if([splits count] >= 2)
		{
			[[self outputFilenameText] setStringValue:[[[source path] lastPathComponent] stringByDeletingPathExtension]];
			[[self outputFilenameAddToIndexText] setStringValue:@"0"];
			[NSApp beginSheet:[self outputFilenameWindow] modalForWindow:[self window] modalDelegate:self didEndSelector:@selector(outputFilenameSheetDidEnd:returnCode:contextInfo:) contextInfo:NULL];
		}
	}
	else{
		if(_splitter != nil)
		{
			[_splitter cancel];
		}
	}
}

- (IBAction)helpClick:(id)sender
{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://github.com/popmedic/mp4split#mp4split"]];
}

- (IBAction)preferencesClick:(id)sender {
	NSString* ffmpeg_path = (NSString*)[[NSUserDefaults standardUserDefaults] objectForKey:@"ffmpeg-path"];
	if(ffmpeg_path == nil) ffmpeg_path = @"";
	[[self preferencesFfmpegPathText] setStringValue:ffmpeg_path];
	
	NSString* choice = (NSString*)[[NSUserDefaults standardUserDefaults] objectForKey:@"output-folder-choice"];
	if(choice == nil) choice = @"0";
	if([choice compare:@"0"] == 0)
	{
		[[self preferencesOutputFolderMatrix] selectCellAtRow:0 column:0];
	}
	else
	{
		[[self preferencesOutputFolderMatrix] selectCellAtRow:1 column:0];
	}
	
	NSString* outFolder = [[NSUserDefaults standardUserDefaults] objectForKey:@"output-folder"];
	if(outFolder == nil) outFolder = @"";
	[[self preferencesOutputFolderText] setStringValue:outFolder];
	
	NSNumber* usePassthrough = [[NSUserDefaults standardUserDefaults] objectForKey:@"use-passthrough"];
	[[self preferencesUsePassthroughCheckBox] setState:[usePassthrough integerValue]];
	
	[NSApp beginSheet: [self prefsWindow] modalForWindow: [self window] modalDelegate:nil didEndSelector:NULL contextInfo:NULL];
}

- (IBAction)preferencesCloseButtonClick:(id)sender {
	NSString* ffmpeg_path = [[self preferencesFfmpegPathText] stringValue];
	NSInteger choice = [[self preferencesOutputFolderMatrix] selectedTag];
	NSString* outFolder = [[[self preferencesOutputFolderText] stringValue] stringByStandardizingPath];
	
	if([ffmpeg_path compare:@""] != 0)
	{
		if(![[NSFileManager defaultManager] fileExistsAtPath:ffmpeg_path])
		{
			NSRunAlertPanel(@"ffmpeg path error.", [NSString stringWithFormat:@"ffmpeg path: %@ does not exist.", ffmpeg_path], @"OK", nil, nil);
			return;
		}
	}
	if([POPMp4Splitter ffmpegIsWorking:ffmpeg_path] == NO)
	{
		NSRunAlertPanel(@"ffmpeg path error.", [NSString stringWithFormat:@"ffmpeg path: %@ returned a bad exit status for -version.", ffmpeg_path], @"OK", nil, nil);
		return;
	}
	
	if(choice != 0)
	{
		BOOL isFolder;
		if([outFolder compare:@""] == 0) outFolder = [@"~/Movies" stringByStandardizingPath];
		if([[NSFileManager defaultManager]  fileExistsAtPath:outFolder isDirectory:&isFolder] == NO)
		{
			NSRunAlertPanel(@"Output folder error.", [NSString stringWithFormat:@"Output folder path: %@ does not exist.", outFolder], @"OK", nil, nil);
			return;
		}
		else if(isFolder == NO)
		{
			NSRunAlertPanel(@"Output folder error.", [NSString stringWithFormat:@"Output folder path: %@ is not a folder.", outFolder], @"OK", nil, nil);
			return;
		}
	}
	NSString* choiceStr = [NSString stringWithFormat:@"%li", choice];
	
	NSNumber* usePassthrough = [NSNumber numberWithInteger:[[self preferencesUsePassthroughCheckBox] state]];
	
	[[NSUserDefaults standardUserDefaults] setObject:ffmpeg_path forKey:@"ffmpeg-path"];
	[[NSUserDefaults standardUserDefaults] setObject:choiceStr forKey:@"output-folder-choice"];
	[[NSUserDefaults standardUserDefaults] setObject:outFolder forKey:@"output-folder"];
	[[NSUserDefaults standardUserDefaults] setObject:usePassthrough forKey:@"use=passthrough"];
	
	[NSApp endSheet:[self prefsWindow]];
    [[self prefsWindow] orderOut:self];
}

- (IBAction)outputFilenameOkButtonClick:(id)sender {
	outputPrefix = [NSString stringWithString:[[self outputFilenameText] stringValue]];
	outputAddToIndex = [[[self outputFilenameAddToIndexText] stringValue] integerValue];
	[NSApp endSheet:[self outputFilenameWindow] returnCode:0];
}

- (IBAction)outputFilenameCancelButtonClick:(id)sender {
	[NSApp endSheet:[self outputFilenameWindow] returnCode:1];
}

- (int)numberOfRowsInTableView:(NSTableView *)tblView
{
    if(tblView == [self splitsTableView])
	{
		return (int)[splits count];
	}
	else if(tblView == [self segmentsTableView])
	{
		if([splits count] >= 2)
		{
			return (int)[splits count] - 1;
		}
	}
	return 0;
}

- (id)tableView:(NSTableView*)tblView
objectValueForTableColumn:(NSTableColumn*)tblCol
			row:(NSInteger)rowInd
{
    if(tblView == [self splitsTableView])
	{
		if([[tblCol identifier] compare:@"splitstablestrcol"] == 0)
		{
			NSString* startTimeStr = [[splits objectAtIndex:rowInd] objectForKey:@"startTimeStr"];
			return startTimeStr;
		}
		else if([[tblCol identifier] compare:@"splitstableimgcol"] == 0)
		{
			NSImage* img = [[splits objectAtIndex:rowInd] objectForKey:@"image"];
			return img;
		}
	}
	else if(tblView == [self segmentsTableView])
	{
		NSString* startstr = [[splits objectAtIndex:rowInd] objectForKey:@"startTimeStr"];
		float startsecs = [POPTimeConverter secsFromTimeString:startstr];
		float lengthsecs = [POPTimeConverter secsFromTimeString:[[splits objectAtIndex:rowInd+1] objectForKey:@"startTimeStr"]] - startsecs;
		NSString* lengthstr = [POPTimeConverter timeStringFromSecs:lengthsecs];
		if([[tblCol identifier] compare:@"segmentstablestartcol"] == 0)
		{
			return startstr;
		}
		else if([[tblCol identifier] compare:@"segmentstablelengthcol"] == 0)
		{
			return lengthstr;
		}
		return @"";
	}
	return @"";
	
}

-(IBAction)splitsTableViewDoubleClick:(id)sender
{
	NSInteger idx = [[self splitsTableView] clickedRow];
	if(idx >= 0 && idx < [splits count])
	{
		QTTime qttime = [POPTimeConverter qttimeFromSecs:[POPTimeConverter secsFromTimeString:[[splits objectAtIndex:idx] objectForKey:@"startTimeStr"]] Scale:[[[self mp4Player] movie] currentTime].timeScale];
		[[[self mp4Player] movie] setCurrentTime:qttime];
	}
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
	[self refreshButtons];
}
@end
