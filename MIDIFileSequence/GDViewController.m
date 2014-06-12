//
//  GDViewController.m
//  MIDIFileSequence
//
//  Created by Gene De Lisa on 6/26/12.
//  Copyright (c) 2012 Rockhopper Technologies. All rights reserved.
//

#import "GDViewController.h"
#import "GDSoundEngine.h"

@interface GDViewController ()
@property (strong) id soundEngine;
@end

@implementation GDViewController
@synthesize playButton;
@synthesize soundEngine = _soundEngine;
@synthesize startLoopSlider;
@synthesize endloopSlider;

NSTimer *monitor;
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

    UIToolbar *toolbar = [[UIToolbar alloc] init];
    toolbar.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 44);
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"Item" style:UIBarButtonItemStyleBordered target:self action:@selector(btnItem1Pressed:)];
    
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Item" style:UIBarButtonItemStyleBordered target:self action:@selector(btnItem2Pressed:)];
    
     [toolbar setItems:[[NSArray alloc] initWithObjects:leftButton,flex,rightButton, nil]];
    
    toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin| UIViewAutoresizingFlexibleRightMargin ;
    
    [self.view addSubview:toolbar];
    
    
    
}

- (void) viewWillDisappear:(BOOL)animated {
    [self.soundEngine stopPlayintMIDIFile];
    loopCount = 0;
    [monitor invalidate];
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
    monitor = [NSTimer scheduledTimerWithTimeInterval:.01
                                            target:self
                                            selector:@selector(monitorPlayback)
                                            userInfo:nil
                                            repeats:YES];
    
}

- (MusicTimeStamp) getStartingBar:(MusicTimeStamp)rawMidiTime {
    
    startBeat = floor(rawMidiTime/4.0);
    NSLog(@"the beat is %f -- start bar is %f",rawMidiTime,startBeat);
    
    return rawMidiTime;
}

- (MusicTimeStamp) getEndingBar:(MusicTimeStamp)rawMidiTime {
    
    endBeat = floor(rawMidiTime/4.0) + 1.0;
    NSLog(@"the beat is %f -- end bar is %f",rawMidiTime,endBeat);
    
    return rawMidiTime;
}

- (IBAction)resetStartLoop:(id)sender {
    
    //MusicTimeStamp currentBeat = [self.soundEngine trackLength] * startLoopSlider.value * 4.0;
}

- (IBAction)resetEndLoop:(id)sender {
    //MusicTimeStamp currentBeat = [self.soundEngine trackLength] * endloopSlider.value * 4.0;
    
}

- (IBAction)loadMidi:(id)sender {
    NSLog(@"loading ...%@",_currentTune.fileName);
    [self.soundEngine loadMIDIFile:_currentTune.fileName];
    [self setSliders];
}

- (IBAction)stopMidi:(id)sender {
    
    [self.soundEngine stopPlayintMIDIFile];
    loopCount = 0;
    [monitor invalidate];
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

- (void) monitorPlayback {
    
    MusicTimeStamp currentTime = [self.soundEngine getPlayTime];
    MusicTimeStamp loopStart = (floor(self.startLoopSlider.value) * 4.0);
    MusicTimeStamp loopEnd = self.endloopSlider.value * 4.0; //(floor(self.endloopSlider.value) * 4.0 ) - .01;
    if (loopStart >= loopEnd) {
        loopEnd += 4.0;
    }
    
    self.startLoopSlider.value = loopStart/4.0;
    self.endloopSlider.value = loopEnd/4.0;
    
    //NSLog(@"%f -- %f to %f -- %f to %f",currentTime,loopStart,loopEnd,self.startLoopSlider.value,self.endloopSlider.value);
    
    //NSLog(@"%f",currentTime);
    if ( currentTime >= 0) {
        
        if ( currentTime < loopEnd){
            int measure = (int) currentTime/4.0;
            int beat = (int) fmod(currentTime,4.0) + 1;
            if ( beat != lastBeat || measure != lastMeasure ) {
                self.TimeDisplay.text = [NSString stringWithFormat:@"%d:%d",measure,beat];
                lastMeasure = measure;
                lastBeat = beat;
            }
        }
        //if (currentTime > ([self.soundEngine trackLength] * endloopSlider.value)) {
        if (currentTime >= loopEnd - .05) {
            NSLog(@"restart...%f",loopStart - .1);
            //[self.soundEngine setPlayerTime:([self.soundEngine trackLength] * startLoopSlider.value)];
            [self.soundEngine setPlayerTime:loopStart - .05];
            loopCount++;
            if ( loopCount == 100) {
                [monitor invalidate];
                [self.soundEngine stopPlayintMIDIFile];
                loopCount = 0;
            }
        }
    } else {
        NSLog(@"Done");
        [monitor invalidate];
        
    }

}

- (void) setSliders {
    self.startLoopSlider.minimumValue = 0.0f;
    self.startLoopSlider.maximumValue = [self.soundEngine trackLength]/4.0;
    self.endloopSlider.minimumValue = 0.0f;
    self.endloopSlider.maximumValue = [self.soundEngine trackLength]/4.0;;

}

@end
