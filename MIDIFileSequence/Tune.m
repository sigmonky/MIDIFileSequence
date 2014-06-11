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
    
    Tune *firstTune = [[Tune alloc] initWithTitle:@"test"
                                         fileName:@"test"];
    
    [tunes addObject:firstTune];
    
    Tune *getTune = [tunes objectAtIndex:0];
    
    NSString *title = getTune.title;
    
    NSLog(@"show the title:%@",title);
    
    return [@[firstTune] mutableCopy];
}

- (id)initWithTitle:(NSString *)title fileName:(NSString *)fileName {
    _title = title;
    _fileName = fileName;
}


@end
