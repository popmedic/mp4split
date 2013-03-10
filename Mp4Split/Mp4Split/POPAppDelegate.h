//
//  POPAppDelegate.h
//  Mp4Split
//
//  Created by Kevin Scardina on 3/8/13.
//  Copyright (c) 2013 Kevin Scardina. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QTKit/QTKit.h>

@interface POPAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSSplitView *mainVerticalSplitView;
@property (assign) IBOutlet QTMovieView *mp4Player;
@property (assign) IBOutlet NSSlider *mp4Slider;
@property (assign) IBOutlet NSTextField *positionLabel;
@property (assign) IBOutlet NSButton *addSplitButton;
@property (assign) IBOutlet NSButton *removeSplitButton;
@property (assign) IBOutlet NSToolbarItem *splitButton;
@property (assign) IBOutlet NSProgressIndicator *splitPrgressIndicator;
@property (assign) IBOutlet NSButton *playPauseButton;
@property (assign) IBOutlet NSTableView *splitsTableView;
@property (assign) IBOutlet NSTableView *segmentsTableView;
- (IBAction)openMp4Click:(id)sender;
- (IBAction)closeMp4Click:(id)sender;
- (IBAction)playPauseClick:(id)sender;
- (IBAction)mp4SliderSeek:(id)sender;
- (IBAction)addSplitClick:(id)sender;
- (IBAction)removeSplitClick:(id)sender;
- (IBAction)splitButtonClick:(id)sender;

- (void) mp4SplitExit;
- (void)mp4FileProgress:(float)percent;
- (void)mp4TaskProgress:(float)percent;
@end
