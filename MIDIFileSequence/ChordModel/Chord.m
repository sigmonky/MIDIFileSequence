//
//  Chord.m
//  MIDIFileSequence
//
//  Created by Randy Weinstein on 11/16/14.
//  Copyright (c) 2014 Rockhopper Technologies. All rights reserved.
//

#import "Chord.h"

@implementation Chord



- (NSMutableArray *) getChordMembers {
    
    NSMutableArray *chordMembers = [NSMutableArray new];
    long nextMember;
    
    NSMutableArray *chordIntervals = [NSMutableArray new];
    
    chordIntervals[ChordQualityMajor] = @[@4,@7];
    chordIntervals[ChordQualityMinor] = @[@3,@7];
    chordIntervals[ChordQualityDiminished] = @[@3,@6];
    chordIntervals[ChordQualityAugmented] = @[@4,@8];
    chordIntervals[ChordQualityDominant] = @[@4,@7,@10];
    
    chordMembers[0] = [NSNumber numberWithInt:self.Root];

    
    for (int16_t x = 0; x <  [chordIntervals[self.Quality] count];x++) {
        nextMember = [chordIntervals[self.Quality][x] integerValue];
        chordMembers[x+1] = [NSNumber numberWithLong:self.Root + nextMember];
    }
    
    return chordMembers;
    
}
@end
