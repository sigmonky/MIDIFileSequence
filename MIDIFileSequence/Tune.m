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
    
    Tune *firstTune = [[Tune alloc] initWithTitle:@"How Deep Is the Ocean"
                                         fileName:@"How Deep Is The Ocean"];
    
    [tunes addObject:firstTune];
    firstTune = [[Tune alloc] initWithTitle:@"Embraceable You"
                                   fileName:@"Embraceable You"];
    [tunes addObject:firstTune];
   
    
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
