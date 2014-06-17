//
//  Tune.m
//  MIDIFileSequence
//
//  Created by Weinstein, Randy - Nick.com on 6/11/14.
//  Copyright (c) 2014 Rockhopper Technologies. All rights reserved.
//

#import "Tune.h"

@implementation Tune
+ (NSMutableArray *) theTuneList {
    NSMutableArray *tunes = [[NSMutableArray alloc] init];
    
    Tune *newTune = [[Tune alloc] initWithTitle:@"How Deep Is the Ocean"
                                         fileName:@"How Deep Is The Ocean"];
    
    [tunes addObject:newTune];
    
    newTune = [[Tune alloc] initWithTitle:@"Embraceable You"
                                   fileName:@"Embraceable You"];
    [tunes addObject:newTune];
    
    
    newTune = [[Tune alloc] initWithTitle:@"Afternoon In Paris"
                                 fileName:@"Afternoon In Paris"];
    [tunes addObject:newTune];
    
    return tunes;
}





- (id)initWithTitle:(NSString *)title fileName:(NSString *)fileName {
    if ((self = [super init])) {
        _title = title;
        _fileName = fileName;
    }
    return self;
}


@end
