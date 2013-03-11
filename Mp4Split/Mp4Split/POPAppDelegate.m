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
	if([[self mp4Player] movie] == nil)
	{
		ppbe = NO;
		mse = NO;
		sbe = NO;
		asbe = NO;
		rsbe = NO;
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

- (void)refreshSlider:(NSTimer*)theTimer
{
	if([[self mp4Player] movie] != nil)
	{
		if(oldSliderValue == [[[self mp4Player] movie] currentTime].timeValue)
		{
			[[self playPauseButton] setState:NO];
		}
		else
		{
			[[self playPauseButton] setState:YES];
			[[self mp4Slider] setFloatValue:[[[self mp4Player] movie] currentTime].timeValue];
			[[self positionLabel] setStringValue:[POPTimeConverter timeStringFromQTTime:[[[self mp4Player] movie] currentTime]]];
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
    sliderTimer = [NSTimer timerWithTimeInterval:0.1 target:self selector:@selector(refreshSlider:) userInfo:nil repeats:YES];
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
		[[self mp4Player] setMovie:nm];
		[[self mp4Slider] setMinValue:0.0];
		[[self mp4Slider] setMaxValue:[nm duration].timeValue];
		[[self mp4Slider] setFloatValue:0.0];
		[[self volumeSlider] setFloatValue:[nm volume]];
		[[self positionLabel] setStringValue:@"00:00:00.000"];
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

- (IBAction)addSplitClick:(id)sender {
	[splits addObject:[POPTimeConverter timeStringFromQTTime:[[[self mp4Player] movie] currentTime]]];
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
				NSString* nfn = [NSString stringWithFormat:@"%@%i.%@", dstpath, ii, [srcpath pathExtension]];
				for(;[[NSFileManager defaultManager] fileExistsAtPath:nfn];){
					nfn = [NSString stringWithFormat:@"%@%i.%@", dstpath, ++ii, [srcpath pathExtension]];
				}
				/*temp fix
				startstr = [POPTimeConverter timeStringFromSecs:((float)[POPTimeConverter secsFromTimeString:startstr] +
							(float)(((float)[[[self mp4Player] movie] duration].timeScale)/1000.0))];*/
				
				[tasks addObject:[POPMp4Splitter createTaskWith:srcpath Destination:nfn Start:startstr Length:lengthstr]];
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
	[NSApp beginSheet: [self prefsWindow] modalForWindow: [self window] modalDelegate:nil didEndSelector:NULL contextInfo:NULL];
}

- (IBAction)preferencesCloseButtonClick:(id)sender {
	NSString* ffmpeg_path = [[self preferencesFfmpegPathText] stringValue];
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
	[[NSUserDefaults standardUserDefaults] setObject:ffmpeg_path forKey:@"ffmpeg-path"];
	
	NSInteger choice = [[self preferencesOutputFolderMatrix] selectedTag];
	NSString* outFolder = [[self preferencesOutputFolderText] stringValue];
	if(choice != 0)
	{
		BOOL isFolder;
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
	else
	{
		outFolder = @"";
	}
	NSString* choiceStr = [NSString stringWithFormat:@"%li", choice];
	[[NSUserDefaults standardUserDefaults] setObject:choiceStr forKey:@"output-folder-choice"];
	[[NSUserDefaults standardUserDefaults] setObject:outFolder forKey:@"output-folder"];
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
