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
#import "Player.h"
#import "Progression.h"

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
    
    
    Chord *currentChord = [[Chord alloc] initWithRoot:60 quality:ChordQualityMajor extension:nil];
    
    Progression *progression = [Progression new];
    progression.chordProgression = @
            [
                [[Chord alloc] initWithRoot:60 quality:ChordQualityMinor extension:nil],
                [[Chord alloc] initWithRoot:65 quality:ChordQualityDominant extension:nil],
                [[Chord alloc] initWithRoot:67 quality:ChordQualityMajor extension:nil],
             
            ];

    
    
    
    
    NSMutableArray *chordMembers1 = [currentChord getChordMembers];
    int16_t bassNote1 = [currentChord getBassNote];
    
    Player *piano = [Player new];
    piano.instrument = @"piano";
    piano.midiInstrument = @0;
    piano.performance = [progression basicChordProgression];
    
    
    
    Player *bass = [Player new];
    bass.instrument = @"bass";
    bass.midiInstrument = @32;
    bass.performance = [progression bassLine];
    
    
    Player *drums = [Player new];
    drums.instrument = @"drums";
    drums.midiInstrument = @115;
    drums.performance = (NSMutableArray *)
                @[
                    @[@0, @[@20],@0.4],
                    @[@0.5, @[@80],@0.2],
                    @[@0.75, @[@80],@0.2]
                 ];
    
    
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
