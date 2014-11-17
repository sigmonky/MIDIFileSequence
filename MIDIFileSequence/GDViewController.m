//
//  GDViewController.m
//  MIDIFileSequence
//
//  Created by Gene De Lisa on 6/26/12.
//  Copyright (c) 2012 Rockhopper Technologies. All rights reserved.
//

#import "GDViewController.h"
#import "GDSoundEngine.h"
#import "Chord.h"

@interface GDViewController ()
@property (strong) id soundEngine;
@end

@implementation GDViewController
@synthesize playButton;
@synthesize soundEngine = _soundEngine;
@synthesize startLoopSlider;
@synthesize endloopSlider;

int lastMeasure = 0;
int lastBeat = 0;
int loopCount = 0;
MusicTimeStamp startBeat = 0.0;
MusicTimeStamp endBeat = 0.0;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    NSLog(@"current tune is ....%@",self.currentTune.title);
    self.soundEngine = [[GDSoundEngine alloc] init];
    
}

- (void) viewWillDisappear:(BOOL)animated {
    [self.soundEngine stopPlayintMIDIFile];
    loopCount = 0;
}

- (void)viewDidUnload
{
    [self setPlayButton:nil];
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void) callBackMethod {
    
}

- (IBAction)play:(UIButton *)sender {
     MusicTimeStamp startTime = startLoopSlider.value * 4.0;
    [self.soundEngine playMIDIFile:startTime
                        playBackRate:1.0
     ];
    
}


- (IBAction)generateMidi:(id)sender {
    
    Chord *firstChord = [Chord new];

    firstChord.Root = 60;
    firstChord.Quality = ChordQualityDominant;
    
    NSMutableArray *chordMembers = [firstChord getChordMembers];
    
    NSLog(@"loading ...%@",_currentTune.fileName);
    NSMutableDictionary *piano = [[NSMutableDictionary alloc] init];
    piano[@"name"] = @"piano";
    piano[@"midiInstrument"] = @0;
    piano[@"performance"] = @[@[@0,chordMembers,@4.0],@[@4,@[@60,@65,@68],@4.0],@[@8,@[@59,@62,@68],@8.0]];
    
    NSMutableDictionary *bass = [[NSMutableDictionary alloc] init];
    bass[@"name"] = @"bass";
    bass[@"midiInstrument"] = @32;
    bass[@"performance"] = @[@[@0,@[@36],@4.0],@[@4,@[@41],@4.0],@[@8,@[@43],@8.0]];
    
    NSMutableDictionary *drums = [[NSMutableDictionary alloc] init];
    drums[@"name"] = @"drums";
    drums[@"midiInstrument"] = @115;
    drums[@"performance"] = @[
                              @[@0, @[@20],@0.4],@[@0.5, @[@80],@0.2],@[@0.75, @[@80],@0.2]];
    
    
    NSArray *bandPlayingSong = @[piano,bass,drums];

    [self.soundEngine generateMIDIFile:bandPlayingSong];
    [self setSliders];
}

- (IBAction)stopMidi:(id)sender {
    [self.soundEngine cleanup];
    loopCount = 0;
}

- (IBAction)nudgeBackLoopStart:(id)sender {
    self.startLoopSlider.value = (floor(self.startLoopSlider.value)-1.0);
}

- (IBAction)nudgeBackLoopEnd:(id)sender {
    self.endloopSlider.value = (floor(self.endloopSlider.value)-1.0);
}

- (IBAction)nudgeForwardLoopStart:(id)sender {
    self.startLoopSlider.value = (floor(self.startLoopSlider.value)+1.0);
}

- (IBAction)nudgeForwardLoopEnd:(id)sender {
     self.endloopSlider.value = (floor(self.endloopSlider.value)+1.0);
}

- (IBAction)pianoMuteToggle:(id)sender {
    UISwitch *mySwitch = (UISwitch *)sender;
    if ([mySwitch isOn]) {
        [self.soundEngine muteTrack:0 mute:FALSE];
    } else {
        [self.soundEngine muteTrack:0 mute:TRUE];
    }
}

- (IBAction)bassMuteToggle:(id)sender {
    UISwitch *mySwitch = (UISwitch *)sender;
    if ([mySwitch isOn]) {
        [self.soundEngine muteTrack:1 mute:FALSE];
    } else {
        [self.soundEngine muteTrack:1 mute:TRUE];
    }
}

- (IBAction)clickMuteToggle:(id)sender {
    UISwitch *mySwitch = (UISwitch *)sender;
    if ([mySwitch isOn]) {
        [self.soundEngine muteTrack:2 mute:FALSE];
    } else {
        [self.soundEngine muteTrack:2 mute:TRUE];
    }
}


- (void) setSliders {
    self.startLoopSlider.minimumValue = 0.0f;
    self.startLoopSlider.maximumValue = [self.soundEngine trackLength]/4.0;
    self.endloopSlider.minimumValue = 0.0f;
    self.endloopSlider.maximumValue = [self.soundEngine trackLength]/4.0;;

}

@end
