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
    
    Progression *progression = [Progression new];
    
    NSArray *tonicSubs = @[@0,@4,@9];
    NSArray *subDominantSubs = @[@5,@2];
    NSArray *dominantSubs = @[@7,@11];
   
    int tonicIndex = arc4random() % [tonicSubs count];
    int tonicChordType;
    
    if ([tonicSubs[tonicIndex] integerValue] == 0 ) {
        tonicChordType = ChordQualityMajor;
    } else {
        tonicChordType = ChordQualityMinor;
    }
    
    
    int  subDominantIndex = arc4random() % [subDominantSubs count];
    int subDominantChordType;
    
    if ([subDominantSubs[subDominantIndex] integerValue] == 5 ) {
        subDominantChordType = ChordQualityMajor;
    } else {
         subDominantChordType = ChordQualityMinor;
    }
    
    NSInteger dominantIndex = arc4random() % [dominantSubs count];
    
   NSInteger  adjustTonic = [tonicSubs[tonicIndex] integerValue];
   NSInteger  tonic = 60 + adjustTonic;
    
    NSInteger adjustSubdominant = [subDominantSubs[subDominantIndex] integerValue];
    NSInteger subDominant = 60 + adjustSubdominant;
    NSUInteger dominant = 60 + (NSUInteger)dominantSubs[dominantIndex];
    
    progression.chordProgression = (NSMutableArray *)@
            [
                [[Chord alloc] initWithRoot:tonic  quality:tonicChordType extension:nil],
                [[Chord alloc] initWithRoot:subDominant quality:subDominantChordType extension:nil],
                [[Chord alloc] initWithRoot:67 quality:ChordQualityMajor extension:nil]
             
             
            ];

    
    Player *piano = [Player new];
    piano.instrument = @"piano";
    piano.midiInstrument = @5;
    piano.performance = [progression basicChordProgression];
    
    NSMutableArray *voicedProgression = [progression voicedChordProgression];
    
    
    Player *bass = [Player new];
    bass.instrument = @"bass";
    bass.midiInstrument = @32;
    bass.performance = [progression bassLine];
    
    
    Player *drums = [Player new];
    drums.instrument = @"drums";
    drums.midiInstrument = @115;
    drums.performance = (NSMutableArray *)
                @[
                    @[@0, @[@80],@0.5],
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
