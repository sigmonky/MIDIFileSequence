//
//  GDViewController.h
//  MIDIFileSequence
//
//  Created by Gene De Lisa on 6/26/12.
//  Copyright (c) 2012 Rockhopper Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GDViewController : UIViewController
@property (weak, nonatomic) IBOutlet UISlider *startLoopSlider;
@property (weak, nonatomic) IBOutlet UISlider *endloopSlider;

@property (weak, nonatomic) IBOutlet UILabel *TimeDisplay;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
- (IBAction)play:(UIButton *)sender;
- (IBAction)resetStartLoop:(id)sender;
- (IBAction)resetEndLoop:(id)sender;
- (IBAction)loadMidi:(id)sender;
@end
