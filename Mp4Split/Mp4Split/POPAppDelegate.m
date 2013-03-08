//
//  POPAppDelegate.m
//  Mp4Split
//
//  Created by Kevin Scardina on 3/8/13.
//  Copyright (c) 2013 Kevin Scardina. All rights reserved.
//

#import "POPAppDelegate.h"

@implementation POPAppDelegate

- (void)dealloc
{
    [super dealloc];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	// Insert code here to initialize your application
}

- (IBAction)openMp4Click:(id)sender {
	NSOpenPanel* oDlg = [NSOpenPanel openPanel];
    [oDlg setCanChooseFiles:YES];
    [oDlg setCanCreateDirectories:NO];
    [oDlg beginSheetModalForWindow:[self window] completionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton)
        {
            NSArray* urls = [oDlg URLs];
            NSURL *url = [urls objectAtIndex:0];
            QTMovie *nm = [QTMovie movieWithURL:url error:nil];
            if(nm)
            {
				[[self mp4Player] setMovie:nm];
				[[self mp4Player] play:nm];
				//[[self mp4Player] setControllerVisible:YES];
            }
        }
    }];
}
@end
