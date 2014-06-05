//
//  GDSoundEngine.h
//  MIDIFileSequence
//
//  Created by Gene De Lisa on 6/26/12.
//  Copyright (c) 2012 Rockhopper Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface GDSoundEngine : NSObject

@property (getter = isPlaying) BOOL playing;
@property (nonatomic) UInt8 presetNumber;
@property (nonatomic) MusicPlayer musicPlayer;
@property (nonatomic) MusicSequence musicSequence;
@property (nonatomic) MusicTrack musicTrack;
@property (nonatomic) id callBackMethod;
@property (nonatomic) MusicTimeStamp trackLength;

- (void)playNoteOn:(UInt32)noteNum :(UInt32)velocity;
- (void)playNoteOff:(UInt32)noteNum;
- (void)loadMIDIFile:(NSString *)midifileName;
- (void) playMIDIFile:(MusicTimeStamp)startPoint
         playBackRate:(float)playBackRate;
- (void) stopPlayintMIDIFile;
- (MusicTimeStamp)getPlayTime;
- (void) setPlayerTime:(float)playerStartTime;
- (void) muteTrack:(NSInteger)trackNum mute:(BOOL)muteSetting;


@end
