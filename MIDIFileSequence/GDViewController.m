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

NSTimer *monitor;
int lastMeasure = 0;
int lastBeat = 0;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.soundEngine = [[GDSoundEngine alloc] init];
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
    [self.soundEngine loadMIDIFile:@"howDeepIsOceanBass"
    startPoint:124.00
    loopCount:1
    loopDuration:16.0
    playBackRate:1.0
     
     ];
    [self.soundEngine playMIDIFile];
    monitor = [NSTimer scheduledTimerWithTimeInterval:.05
                                            target:self
                                            selector:@selector(monitorPlayback)
                                            userInfo:nil
                                            repeats:YES];
    
}

- (void) monitorPlayback {
    
    MusicTimeStamp currentTime = [self.soundEngine getPlayTime];
    if ( currentTime > 0) {
        int measure = (int) currentTime/4.0;
        int beat = (int) fmod(currentTime,4.0) + 1;
        if ( beat != lastBeat || measure != lastMeasure ) {
            //NSLog(@"%d:%d",measure,beat);
            self.TimeDisplay.text = [NSString stringWithFormat:@"%d:%d",measure,beat];
            lastMeasure = measure;
            lastBeat = beat;
        }
    } else {
        NSLog(@"Done");
        [monitor invalidate];
    }

}

@end
