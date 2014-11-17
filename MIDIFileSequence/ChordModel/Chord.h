//
//  Chord.h
//  MIDIFileSequence
//
//  Created by Randy Weinstein on 11/16/14.
//  Copyright (c) 2014 Rockhopper Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(int16_t, ChordQualities) {
    ChordQualityMajor,
    ChordQualityMinor,
    ChordQualityDiminished,
    ChordQualityAugmented,
    ChordQualityDominant,
};

typedef NS_ENUM(int16_t, ChordExtensions) {
    Six,
    Seven,
    MajorSeven,
    FlatNine,
    Nine,
    SharpNine,
    Eleven,
    SharpEleven,
    FlatThirteen,
    Thirteen
};

@interface Chord : NSObject
@property (nonatomic,assign) int16_t Root;
@property (nonatomic,assign) int16_t Quality;
@property (nonatomic,strong) NSMutableArray *extensions;

- (NSMutableArray *)getChordMembers;

@end
