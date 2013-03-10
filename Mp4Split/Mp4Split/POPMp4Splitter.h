//
//  POPMp4Splitter.h
//  Mp4Split
//
//  Created by Kevin Scardina on 3/9/13.
//  Copyright (c) 2013 Kevin Scardina. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol POPMp4SplitterDelegate
- (void)mp4SplitExit;
- (void)mp4FileProgress:(float)percent;
- (void)mp4TaskProgress:(float)percent;
@end

@interface POPMp4Splitter : NSObject

+(NSTask*) createTaskWithStart:(NSString*)ss Length:(NSString*)len Source:(NSString*)src Destination:(NSString*)dst;

-(id) initWithTasks:(NSArray*)tsks;
-(void) setDelegate:(id)delegate;
-(void) launch;

@end
