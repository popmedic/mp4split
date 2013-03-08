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
{
	NSURL* source;
}
@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet QTMovieView *mp4Player;
- (IBAction)openMp4Click:(id)sender;

@end
