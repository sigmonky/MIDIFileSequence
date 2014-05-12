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

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
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
     MusicTimeStamp startTime = ([self.soundEngine trackLength] * startLoopSlider.value);
    [self.soundEngine playMIDIFile:startTime
                        playBackRate:1.0
     ];
    monitor = [NSTimer scheduledTimerWithTimeInterval:.05
                                            target:self
                                            selector:@selector(monitorPlayback)
                                            userInfo:nil
                                            repeats:YES];
    
}

- (IBAction)resetStartLoop:(id)sender {
    NSLog(@"start loop ....%f",startLoopSlider.value);
    NSLog (@"%f",[self.soundEngine trackLength] * startLoopSlider.value);
}

- (IBAction)resetEndLoop:(id)sender {
     NSLog(@"start loop ....%f",endloopSlider.value);
    NSLog (@"%f",[self.soundEngine trackLength] * endloopSlider.value);
}

- (IBAction)loadMidi:(id)sender {
    
   
    [self.soundEngine loadMIDIFile:@"howDeepIsOceanBass"];
}

- (void) monitorPlayback {
    
    MusicTimeStamp currentTime = [self.soundEngine getPlayTime];
    if ( currentTime > 0) {
        int measure = (int) currentTime/4.0;
        int beat = (int) fmod(currentTime,4.0) + 1;
        if ( beat != lastBeat || measure != lastMeasure ) {
            self.TimeDisplay.text = [NSString stringWithFormat:@"%d:%d",measure,beat];
            lastMeasure = measure;
            lastBeat = beat;
        }
        if (currentTime > ([self.soundEngine trackLength] * endloopSlider.value)) {
            [self.soundEngine setPlayerTime:([self.soundEngine trackLength] * startLoopSlider.value)];
            loopCount++;
            if ( loopCount == 5) {
                [monitor invalidate];
                [self.soundEngine stopPlayintMIDIFile];
                loopCount = 0;
            }
        }
    } else {
        NSLog(@"Done");
        //[monitor invalidate];
        
    }

}

@end
