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
    NSTimer *monitor = [NSTimer scheduledTimerWithTimeInterval:.01
                                                        target:self
                                                      selector:@selector(monitorPlayback)
                                                      userInfo:nil
                                                       repeats:YES];
    
}

- (void) monitorPlayback {
    NSLog(@"monitor");
    [self.soundEngine getPlayTime];
}

@end
