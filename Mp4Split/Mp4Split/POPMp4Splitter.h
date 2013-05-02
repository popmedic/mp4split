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

+(BOOL) ffmpegIsWorking:(NSString*)ffmpeg_path;
+(NSTask*) createTaskWith:(NSString*)src Destination:(NSString*)dst Start:(NSString*)ss Length:(NSString*)len;
+(NSTask*) createConvertTaskWith:(NSString*)src Destination:(NSString*)dst Start:(NSString*)ss Length:(NSString*)len;

-(id) initWithTasks:(NSArray*)tsks Chapters:(NSArray*)chaps;
-(void) setDelegate:(id)delegate;
-(void) launch;
-(void) cancel;

-(BOOL) isSplitting;

-(NSString*) taskSourcePathAt:(NSInteger)idx;
-(NSString*) taskDestinationPathAt:(NSInteger)idx;
-(NSString*) taskStartTimeStringAt:(NSInteger)idx;
-(NSString*) taskLengthTimeStringAt:(NSInteger)idx;
@end
