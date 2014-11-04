//
//  GDViewController.h
//  MIDIFileSequence
//
//  Created by Gene De Lisa on 6/26/12.
//  Copyright (c) 2012 Rockhopper Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tune.h"

@interface GDViewController : UIViewController
@property (weak, nonatomic) IBOutlet UISlider *startLoopSlider;
@property (weak, nonatomic) IBOutlet UISlider *endloopSlider;

@property (weak, nonatomic) IBOutlet UILabel *TimeDisplay;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (strong,nonatomic) Tune *currentTune;
- (IBAction)play:(UIButton *)sender;
- (IBAction)loadMidi:(id)sender;
- (IBAction)stopMidi:(id)sender;
- (IBAction)nudgeBackLoopStart:(id)sender;
- (IBAction)nudgeBackLoopEnd:(id)sender;
- (IBAction)nudgeForwardLoopStart:(id)sender;
- (IBAction)nudgeForwardLoopEnd:(id)sender;
- (IBAction)pianoMuteToggle:(id)sender;
- (IBAction)bassMuteToggle:(id)sender;
- (IBAction)clickMuteToggle:(id)sender;



@end
