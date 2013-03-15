//
//  POPAppDelegate.m
//  Mp4Split
//
//  Created by Kevin Scardina on 3/8/13.
//  Copyright (c) 2013 Kevin Scardina. All rights reserved.
//
#import "POPTimeConverter.h"
#import "POPAppDelegate.h"
#import "POPMp4Splitter.h"

@implementation POPAppDelegate
{
	NSURL* source;
	NSTimer* sliderTimer;
	long long oldSliderValue;
	NSMutableArray* splits;
	POPMp4Splitter* splitter;
	double currentFrameRate;
	NSArray* currentChapters;
	BOOL mp4Loading;
}
- (void)dealloc
{
    [super dealloc];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
	CGFloat f = [[[[self mainVerticalSplitView] subviews] objectAtIndex:0] frame].size.width;
	[[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithFloat:f] forKey:@"vsplit1"];
	f = [[[[self mainVerticalSplitView] subviews] objectAtIndex:1] frame].size.width;
	[[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithFloat:f] forKey:@"vsplit2"];
	[self stopSliderTimer];
	sliderTimer = nil;
	splitter = nil;
	splits = nil;
	return YES;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	// Insert code here to initialize your application
	splitter = nil;
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
	for (QTTrack* track in [movie tracks])
    {
		NSString* mt = [[track trackAttributes] objectForKey:QTTrackMediaTypeAttribute];
		NSNumber* layer = [[track trackAttributes] objectForKey:QTTrackLayerAttribute];
		if([mt compare:@"vide"] == 0 && [layer shortValue] == -1)
		{
			[track setEnabled:NO];
			//DisposeMovieTrack([track quickTimeTrack]);
		}
    }
}

- (IBAction)chapterMenuItemClick:(id)sender {
	if([[self mp4Player] movie] != nil)
	{
		currentChapters = [[[self mp4Player] movie] chapters];
		NSDictionary* chapter = [currentChapters objectAtIndex:[sender tag]];
		QTTime qttime;
		[[chapter objectForKey:QTMovieChapterStartTime] getValue:&qttime];
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
			currentChapters = [[[self mp4Player] movie] chapters];
			
			for(int i = 0; i < [currentChapters count]; i++) {
				NSDictionary* chapter = [currentChapters objectAtIndex:i];
				NSString* name = [chapter objectForKey:QTMovieChapterName];
				QTTime qttime;
				[[chapter objectForKey:QTMovieChapterStartTime] getValue:&qttime];
				NSString* time = [POPTimeConverter timeStringFromQTTime:qttime FrameRate:currentFrameRate];
				NSString* title = [NSString stringWithFormat:@"%@ : %@", name, time];
				NSMenuItem* item = [[NSMenuItem alloc] initWithTitle:title action:@selector(chapterMenuItemClick:) keyEquivalent:@""];
				[item setTag:i];
				[[self chaptersMenu] addItem:item];
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
	QTMovie *nm = [QTMovie movieWithURL:url error:nil];
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

- (IBAction)jumpToClick:(id)sender {
	if([[self mp4Player] movie] != nil)
	{
		
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

- (IBAction)nudgeFowardClick:(id)sender {
	if([[self mp4Player] movie] != nil)
	{
		float csecs = [POPTimeConverter secsFromQTTime:[[[self mp4Player] movie] currentTime] FrameRate:currentFrameRate];
		QTTime nqt = [POPTimeConverter qttimeFromSecs:csecs+1.0 Scale:[[[self mp4Player] movie] currentTime].timeScale];
		[[[self mp4Player] movie] setCurrentTime:nqt];
	}
}

- (IBAction)nudgeBackwardClick:(id)sender {
	if([[self mp4Player] movie] != nil)
	{
		float csecs = [POPTimeConverter secsFromQTTime:[[[self mp4Player] movie] currentTime] FrameRate:currentFrameRate];
		QTTime nqt = [POPTimeConverter qttimeFromSecs:csecs-1.0 Scale:[[[self mp4Player] movie] currentTime].timeScale];
		[[[self mp4Player] movie] setCurrentTime:nqt];
	}
}

- (IBAction)addSplitClick:(id)sender {
	[splits addObject:[POPTimeConverter timeStringFromQTTime:[[[self mp4Player] movie] currentTime] FrameRate:currentFrameRate]];
	[splits sortUsingComparator:^(id s1, id s2){
		return [(NSString*)s1 compare:(NSString*)s2];
	}];
	[self refreshButtons];
	[self refreshTables];
}

- (IBAction)removeSplitClick:(id)sender {
	if([[self splitsTableView] selectedRow] > -1)
	{
		[splits removeObjectAtIndex:[[self splitsTableView] selectedRow]];
		[self refreshButtons];
		[self refreshTables];
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
- (IBAction)splitButtonClick:(id)sender {
	if([@"mp4split-128" compare:[[[self splitButton] image] name]] == 0)
	{
		if([splits count] >= 2)
		{
			NSMutableArray* tasks = [[NSMutableArray alloc] init];
			for(int i = 0, ii = 1; i < [splits count]-1; i++, ii++)
			{
				NSString* startstr = splits[i];
				float startsecs = [POPTimeConverter secsFromTimeString:startstr];
				float lengthsecs = [POPTimeConverter secsFromTimeString:splits[i+1]] - startsecs;
				NSString* lengthstr = [POPTimeConverter timeStringFromSecs:lengthsecs];
				
				NSString* srcpath = [source path];
				NSString* outFolder = (NSString*)[[NSUserDefaults standardUserDefaults] objectForKey:@"output-folder"];
				NSString* choice = (NSString*)[[NSUserDefaults standardUserDefaults] objectForKey:@"output-folder-choice"];
				NSString* dstpath = [srcpath stringByDeletingPathExtension];
				if(outFolder == nil) outFolder = @"";
				if(choice == nil) choice = @"0";
				if([choice compare:@"1"] == 0)
				{
					dstpath = [NSString stringWithFormat:@"%@/%@", outFolder, [dstpath lastPathComponent]];
				}
				NSString* nfn = [NSString stringWithFormat:@"%@%i.%@", dstpath, ii, @"mp4"/*[srcpath pathExtension]*/];
				for(;[[NSFileManager defaultManager] fileExistsAtPath:nfn];){
					nfn = [NSString stringWithFormat:@"%@%i.%@", dstpath, ++ii, @"mp4"/*[srcpath pathExtension]*/];
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
			if(splitter != nil) splitter = nil;
			splitter = [[POPMp4Splitter alloc] initWithTasks:tasks];
			[splitter setDelegate:self];
			[[self taskProgressIndicator] setDoubleValue:0.0];
			[[self taskProgressIndicator] setHidden:NO];
			[[self fileProgressIndicator] setDoubleValue:0.0];
			[[self fileProgressIndicator] setHidden:NO];
			[[self splitButton] setImage:[NSImage imageNamed:@"mp4split-cancel-128.png"]];
			[splitter launch];
		}
	}
	else{
		if(splitter != nil)
		{
			[splitter cancel];
		}
	}
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
	
	NSString *outFileTemplate = [[NSUserDefaults standardUserDefaults] objectForKey:@"output-file-template"];
	if(outFileTemplate == nil) outFileTemplate = @"";
	[[self preferencesOutputFileTemplateText] setStringValue:outFileTemplate];
	
	[NSApp beginSheet: [self prefsWindow] modalForWindow: [self window] modalDelegate:nil didEndSelector:NULL contextInfo:NULL];
}

- (IBAction)preferencesCloseButtonClick:(id)sender {
	NSString* ffmpeg_path = [[self preferencesFfmpegPathText] stringValue];
	NSInteger choice = [[self preferencesOutputFolderMatrix] selectedTag];
	NSString* outFolder = [[[self preferencesOutputFolderText] stringValue] stringByStandardizingPath];
	NSString* outFileTemplate = [[self preferencesOutputFileTemplateText] stringValue];
	
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
	
	if([outFileTemplate compare:@""] == 0)
	{
		outFileTemplate = @"{SRC}{IDX}";
	}
	
	[[NSUserDefaults standardUserDefaults] setObject:ffmpeg_path forKey:@"ffmpeg-path"];
	[[NSUserDefaults standardUserDefaults] setObject:choiceStr forKey:@"output-folder-choice"];
	[[NSUserDefaults standardUserDefaults] setObject:outFolder forKey:@"output-folder"];
	[[NSUserDefaults standardUserDefaults] setObject:outFileTemplate forKey:@"output-file-template"];
	
	[NSApp endSheet:[self prefsWindow]];
    [[self prefsWindow] orderOut:self];
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
		return splits[rowInd];
	}
	else if(tblView == [self segmentsTableView])
	{
		NSString* startstr = splits[rowInd];
		float startsecs = [POPTimeConverter secsFromTimeString:startstr];
		float lengthsecs = [POPTimeConverter secsFromTimeString:splits[rowInd+1]] - startsecs;
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

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
	[self refreshButtons];
}
@end
