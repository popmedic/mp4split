//
//  POPAppDelegate.h
//  Mp4Split
//
//  Created by Kevin Scardina on 3/8/13.
//  Copyright (c) 2013 Kevin Scardina. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QTKit/QTKit.h>

@interface QTMovie(IdlingAdditions)
-(QTTime)maxTimeLoaded;
@end

@interface POPAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSMenuItem *controlMenu;
@property (assign) IBOutlet NSMenu *chaptersMenu;
@property (assign) IBOutlet NSSplitView *mainVerticalSplitView;
@property (assign) IBOutlet QTMovieView *mp4Player;
@property (assign) IBOutlet NSProgressIndicator *mp4LoadingProgressIndicator;
@property (assign) IBOutlet NSSlider *volumeSlider;
@property (assign) IBOutlet NSSlider *mp4Slider;
@property (assign) IBOutlet NSTextField *positionLabel;
@property (assign) IBOutlet NSButton *addSplitButton;
@property (assign) IBOutlet NSButton *removeSplitButton;
@property (assign) IBOutlet NSToolbarItem *splitButton;
@property (assign) IBOutlet NSProgressIndicator *fileProgressIndicator;
@property (assign) IBOutlet NSProgressIndicator *taskProgressIndicator;
@property (assign) IBOutlet NSButton *playPauseButton;
@property (assign) IBOutlet NSTableView *splitsTableView;
@property (assign) IBOutlet NSTableView *segmentsTableView;

@property (assign) IBOutlet NSWindow *prefsWindow;
@property (assign) IBOutlet NSTextField *preferencesFfmpegPathText;
@property (assign) IBOutlet NSMatrix *preferencesOutputFolderMatrix;
@property (assign) IBOutlet NSTextField *preferencesOutputFolderText;
@property (assign) IBOutlet NSTextField *preferencesOutputFileTemplateText;

- (IBAction)openMp4Click:(id)sender;
- (IBAction)closeMp4Click:(id)sender;
- (IBAction)playPauseClick:(id)sender;
- (IBAction)volumeSliderSeek:(id)sender;
- (IBAction)mp4SliderSeek:(id)sender;
- (IBAction)playPauseMenuClick:(id)sender;
- (IBAction)jumpToClick:(id)sender;
- (IBAction)reversePlayClick:(id)sender;
- (IBAction)speedUpClick:(id)sender;
- (IBAction)slowDownClick:(id)sender;
- (IBAction)nudgeFowardClick:(id)sender;
- (IBAction)nudgeBackwardClick:(id)sender;
- (IBAction)addSplitClick:(id)sender;
- (IBAction)removeSplitClick:(id)sender;
- (IBAction)splitButtonClick:(id)sender;
- (IBAction)preferencesClick:(id)sender;
- (IBAction)preferencesCloseButtonClick:(id)sender;

- (void) mp4SplitExit;
- (void)mp4FileProgress:(float)percent;
- (void)mp4TaskProgress:(float)percent;
@end
