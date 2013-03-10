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
			//NSLog(@"%@ tl/ts => %@", QTStringFromTime([[[self mp4Player] movie] currentTime]), [POPTimeConverter timeStringFromQTTime:[[[self mp4Player] movie] currentTime]]);
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
		[[self mp4Player] play:nm];
		[[self mp4Slider] setMinValue:0.0];
		[[self mp4Slider] setMaxValue:[nm duration].timeValue];
		[[self mp4Slider] setFloatValue:0.0];
		[[self positionLabel] setStringValue:@"00:00:00.000"];
		[self refreshButtons];
		[self refreshTables];
	}
}
- (IBAction)openMp4Click:(id)sender {
	[self closeMp4];
	NSOpenPanel* oDlg = [NSOpenPanel openPanel];
    [oDlg setCanChooseFiles:YES];
    [oDlg setCanCreateDirectories:NO];
    [oDlg beginSheetModalForWindow:[self window] completionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton)
        {
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
	[[self splitPrgressIndicator] setHidden:YES];
	[[self splitButton] setImage:[NSImage imageNamed:@"mp4split-128.png"]];
}
- (void)mp4FileProgress:(float)percent
{
	
}
- (void)mp4TaskProgress:(float)percent
{
	[[self splitPrgressIndicator] setDoubleValue:percent];
}
- (IBAction)splitButtonClick:(id)sender {
	if([@"mp4split-128" compare:[[[self splitButton] image] name]] == 0)
	{
		if([splits count] >= 2)
		{
			//NSMutableArray* cmds = [[NSMutableArray alloc] init];
			NSMutableArray* tasks = [[NSMutableArray alloc] init];
			for(int i = 0, ii = 1; i < [splits count]-1; i++, ii++)
			{
				NSString* startstr = splits[i];
				float startsecs = [POPTimeConverter secsFromTimeString:startstr];
				float lengthsecs = [POPTimeConverter secsFromTimeString:splits[i+1]] - startsecs;
				NSString* lengthstr = [POPTimeConverter timeStringFromSecs:lengthsecs];
				
				NSString* srcpath = [source path];
				NSString* nfn = [NSString stringWithFormat:@"%@%i.%@", [srcpath stringByDeletingPathExtension], ii, [srcpath pathExtension]];
				for(;[[NSFileManager defaultManager] fileExistsAtPath:nfn];){
					nfn = [NSString stringWithFormat:@"%@%i.%@", [srcpath stringByDeletingPathExtension], ++ii, [srcpath pathExtension]];
				}
				/*temp fix*/
				startstr = [POPTimeConverter timeStringFromSecs:((float)[POPTimeConverter secsFromTimeString:startstr] +
							(float)(((float)[[[self mp4Player] movie] duration].timeScale)/1000.0))];
				//NSString* cmd = [NSString stringWithFormat:@"ffmpeg -ss \"%@\" -t \"%@\" -i \"%@\" -acodec copy -vcodec copy \"%@\"", startstr, lengthstr ,srcpath , nfn];
				//[cmds addObject:cmd];
				/*end temp*/
				[tasks addObject:[POPMp4Splitter createTaskWithStart:startstr Length:lengthstr Source:srcpath Destination:nfn]];
			}
			/*temp
			NSString* shscript = [[[source path] stringByDeletingPathExtension] stringByAppendingString:@"[split].sh"];
			[[NSFileManager defaultManager] createFileAtPath:shscript contents:[[cmds componentsJoinedByString:@"\n"] dataUsingEncoding:1] attributes:nil];
			end temp*/
			if(splitter != nil) splitter = nil;
			splitter = [[POPMp4Splitter alloc] initWithTasks:tasks];
			[splitter setDelegate:self];
			[[self splitPrgressIndicator] setDoubleValue:0.0];
			[[self splitPrgressIndicator] setHidden:NO];
			[[self splitButton] setImage:[NSImage imageNamed:@"mp4split-cancel-128.png"]];
			[splitter launch];
		}
	}
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
	/*
	NSString *sci = (NSString*)[aTableColumn identifier];
    NSUInteger ci = (NSUInteger)[sci integerValue];
    NSArray* row = [splitDS objectAtIndex:rowIndex];
    return [row objectAtIndex:ci];*/
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
	[self refreshButtons];
}
/*
- (void)tableView:(NSTableView*)tblView
   setObjectValue:(id)obj
   forTableColumn:(NSTableColumn *)tblColumn
              row:(NSInteger)rowIndex
{
    NSString* v = (NSString*)obj;
    if(v != nil)
    {
        NSString *sci = (NSString*)[aTableColumn identifier];
        NSUInteger ci = (NSUInteger)[sci integerValue];
        NSMutableArray* row = [splitDS objectAtIndex:rowIndex];
        [row replaceObjectAtIndex:ci withObject:v];
    }
}*/
@end
