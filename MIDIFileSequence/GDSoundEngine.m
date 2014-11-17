//
//  GDSoundEngine.m
//  MIDIFileSequence
//
//  Just a sampler connected to RemoteIO. No mixer. 
//  Loads a DLS file.
//
//  Created by Gene De Lisa on 6/26/12.
//  Copyright (c) 2012 Rockhopper Technologies. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>
#import "GDCoreAudioUtils.h"
#import "GDSoundEngine.h"

@interface GDSoundEngine()



@property (readwrite) AUGraph processingGraph;
@property (readwrite) AUNode samplerNode1,samplerNode2,samplerNode3;
@property (readwrite) AUNode mixerNode;
@property (readwrite) AUNode ioNode;
@property (readwrite) AudioUnit samplerUnit1,samplerUnit2,samplerUnit3;
@property (readwrite) AudioUnit mixerUnit;

@property (readwrite) AudioUnit ioUnit;

@end

@implementation GDSoundEngine {
   
}

static GDSoundEngine *refToSelf;

- (id) init 
{
    if ( self = [super init] ) {
       
        refToSelf = self;
        
    }
    
    return self;
}

#pragma mark - Audio setup
- (BOOL) createAUGraph
{
    NSLog(@"Creating the graph");
    
    //Step 1: Create the Audio Graph
    CheckError(
               NewAUGraph(&_processingGraph),
			   "NewAUGraph"
               );
    
    //Step 2: initialize re-usable audio component description struct
    AudioComponentDescription cd = {};
    
    //Step 3: create the sampler nodes
	cd.componentType = kAudioUnitType_MusicDevice;
	cd.componentSubType = kAudioUnitSubType_Sampler;
	cd.componentManufacturer = kAudioUnitManufacturer_Apple;
	cd.componentFlags = 0;
	cd.componentFlagsMask = 0;
    
	CheckError(
               AUGraphAddNode(
                              self.processingGraph,
                              &cd,
                              &_samplerNode1
                              ),
               "AUGraphAddNode -- sampler node 1"
               );
    
    CheckError(
               AUGraphAddNode(self.processingGraph,
                              &cd,
                              &_samplerNode2
                              ),
               "AUGraphAddNode -- sampler node 2"
               );
    
    CheckError(
               AUGraphAddNode(self.processingGraph,
                              &cd,
                              &_samplerNode3
                              ),
               "AUGraphAddNode -- sampler node 3"
               );
    
    //Step 4: create and configure the mixer unit node
    
    //4a: create node
    cd.componentType          = kAudioUnitType_Mixer;
    cd.componentSubType       = kAudioUnitSubType_MultiChannelMixer;
    
    CheckError(
               AUGraphAddNode (self.processingGraph,
                               &cd,
                               &_mixerNode),
               "AUGraphAddNode -- mixer node"
               );
    
    
   
    //4b: Obtain the mixer unit instance from its corresponding node
    
     CheckError(AUGraphNodeInfo (
                      self.processingGraph,
                      self.mixerNode,
                      NULL,
                      &_mixerUnit
                      ),
                "Get Graph Node Info -- mixer node");
     
    //4c: Set the bus count for the mixer

     UInt32 numBuses = 3;
     AudioUnitSetProperty(_mixerUnit,
                          kAudioUnitProperty_ElementCount,
                          kAudioUnitScope_Input,
                          0,
                          &numBuses,
                          sizeof(numBuses)
                          );

    
    //Step 5: create the I/O unit node
    AudioComponentDescription iOUnitDescription;
    iOUnitDescription.componentType          = kAudioUnitType_Output;
    iOUnitDescription.componentSubType       = kAudioUnitSubType_RemoteIO;
    iOUnitDescription.componentManufacturer  = kAudioUnitManufacturer_Apple;
    iOUnitDescription.componentFlags         = 0;
    iOUnitDescription.componentFlagsMask     = 0;
    
    CheckError(AUGraphAddNode(
                              self.processingGraph,
                              &iOUnitDescription,
                              &_ioNode),
               "AUGraphAddNode -- i/o node"
               );
    
    //Step 6: wire up the graph with the nodes just created
    
    //6a:open the processing graph
	CheckError(AUGraphOpen(self.processingGraph),
               "AUGraphOpen");
    
    //6b: get sampler unit associated with sampler node 1
	CheckError(AUGraphNodeInfo(self.processingGraph,
                               self.samplerNode1,
                               NULL,
                               &_samplerUnit1),
               "AUGraphNodeInfo -- sampler unit 1");
    
    //6c: get sampler unit associated with sampler node 2
    CheckError(AUGraphNodeInfo(self.processingGraph,
                               self.samplerNode2,
                               NULL,
                               &_samplerUnit2),
               "AUGraphNodeInfo -- sampler unit 2");
    
    //6d: get sampler unit associated with sampler node 3
    CheckError(AUGraphNodeInfo(self.processingGraph,
                               self.samplerNode3,
                               NULL,
                               &_samplerUnit3),
               "AUGraphNodeInfo -- sampler unit 3");
    
    //6e: get mixer unit associated with the mixer node
    CheckError(AUGraphNodeInfo (
                     self.processingGraph,
                     self.mixerNode,
                     NULL,
                     &_mixerUnit),
                    "AUGraphNodeInfo -- mixer unit" );
    
    //6f: get io unit assoicated with the io node
    CheckError(AUGraphNodeInfo(
                               self.processingGraph,
                               self.ioNode,
                               NULL,
                               &_ioUnit),
               "AUGraphNodeInfo -- i/o unit");
    
    //Step 7: Connect the nodes
    
    //7a: connect sampler node 1 to the mixer node
    CheckError(AUGraphConnectNodeInput (self.processingGraph,
                             self.samplerNode1,
                             0,
                             self.mixerNode,
                             0),
               "AUGraphConnectNodeInput -- connect sampler 1 node output 0 to mixer node input 0");
    
    //7b: connect sampler node 2 to the mixer node
    CheckError(AUGraphConnectNodeInput (self.processingGraph,
                             self.samplerNode2,
                             0,
                             self.mixerNode,
                             1),
               "AUGraphConnectNodeInput -- connect sampler 2 node output 0 to mixer node input 1");
    
    //7c: connect sampler node 3 to the mixer node
    CheckError(AUGraphConnectNodeInput (self.processingGraph,
                             self.samplerNode3,
                             0,
                             self.mixerNode,
                             2),
               "AUGraphConnectNodeInput -- connect sampler 3 node output 0 to mixer node input 2");
    
    //7d: Connect the mixer unit to the output unit
    CheckError(AUGraphConnectNodeInput (self.processingGraph,
                                        self.mixerNode,
                                        0,
                                        self.ioNode,
                                        0),
               "AUGraphConnectNodeInput -- connect mixer node output 0 to i/o node input 0");

    
	NSLog (@"AUGraph is configured");
	CAShow(self.processingGraph);
    
    return YES;
}

- (void) startGraph
{
    if (self.processingGraph) {
        // this calls the AudioUnitInitialize function of each AU in the graph.
        // validates the graph's connections and audio data stream formats.
        // propagates stream formats across the connections
        Boolean outIsInitialized;
        CheckError(AUGraphIsInitialized(
                                        self.processingGraph,
                                        &outIsInitialized),
                   "AUGraphIsInitialized");
        
        if(!outIsInitialized) {
            CheckError(AUGraphInitialize(self.processingGraph),
                       "AUGraphInitialize");
        }
        
        Boolean isRunning;
        CheckError(AUGraphIsRunning(self.processingGraph,
                                    &isRunning),
                   "AUGraphIsRunning");
        
        if(!isRunning) {
            CheckError(AUGraphStart(self.processingGraph),
                       "AUGraphStart");
        }
        
        self.playing = YES;
    }
}
- (void) stopAUGraph {
    
    NSLog (@"Stopping audio processing graph");
    Boolean isRunning = false;
    CheckError(
               AUGraphIsRunning (self.processingGraph, &isRunning),
               "AUGraphIsRunning"
               );
    
    if (isRunning) {
        CheckError(AUGraphStop(self.processingGraph),
                   "AUGraphStop"
                   );
        self.playing = NO;
    }
}

#pragma mark - Sampler

- (void) setupSampler
{
    // get references to music tracks in sequence
     MusicTrack trackOne, trackTwo, trackThree;
     MusicSequenceGetIndTrack(self.musicSequence, 0, &trackOne);
     MusicSequenceGetIndTrack(self.musicSequence, 1, &trackTwo);
     MusicSequenceGetIndTrack(self.musicSequence, 2, &trackThree);
     
    // get references to sampler nodes in audio graph
     AUNode samplerNodeOne, samplerNodeTwo, samplerNodeThree;
     AUGraphGetIndNode (self.processingGraph, 0, &samplerNodeOne);
     AUGraphGetIndNode (self.processingGraph, 1, &samplerNodeTwo);
     AUGraphGetIndNode (self.processingGraph, 2, &samplerNodeThree);
    
    // assign music tracks in sequence to target sampler nodes in audio graph
     MusicTrackSetDestNode(trackOne,   samplerNodeOne);
     MusicTrackSetDestNode(trackTwo,   samplerNodeTwo);
     MusicTrackSetDestNode(trackThree, samplerNodeThree);
   
    
    // initiaize the audio graph
    Boolean outIsInitialized;
    CheckError(AUGraphIsInitialized(self.processingGraph,
                                    &outIsInitialized),
               "AUGraphIsInitialized"
               );
    if(!outIsInitialized) {
        return;
    }
    
    // load the sample bank -- in this case, a sound font
    NSURL *bankURL;
    bankURL = [[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle] 
                                                  pathForResource:@"fluid_gm" ofType:@"sf2"]];
    
    // fill out persistent property values for bank preset data structure
    AUSamplerBankPresetData bpdata;
    bpdata.bankURL  = (__bridge CFURLRef) bankURL;
    bpdata.bankMSB  = kAUSampler_DefaultMelodicBankMSB;
    bpdata.bankLSB  = kAUSampler_DefaultBankLSB;
    
    
    /*
     1) identify a preset or "MIDI instrument" or sample in the soundbank resource
     2) load a preset from the soundbank into the indicated sampler Audio Unit
    */
    bpdata.presetID = (UInt8) 0; //piano midi instrument/sample
    CheckError(AudioUnitSetProperty(self.samplerUnit1,
                                    kAUSamplerProperty_LoadPresetFromBank,
                                    kAudioUnitScope_Global,
                                    0,
                                    &bpdata,
                                    sizeof(bpdata)),
               "kAUSamplerProperty_LoadPresetFromBank");
    
    bpdata.presetID = (UInt8) 32; //upright midi instrument/bass sample
    CheckError(AudioUnitSetProperty(self.samplerUnit2,
                                    kAUSamplerProperty_LoadPresetFromBank,
                                    kAudioUnitScope_Global,
                                    0,
                                    &bpdata,
                                    sizeof(bpdata)),
               "kAUSamplerProperty_LoadPresetFromBank");
    
    bpdata.presetID = (UInt8) 115; //woodblock midi instrument/sample
    CheckError(AudioUnitSetProperty(self.samplerUnit3,
                                    kAUSamplerProperty_LoadPresetFromBank,
                                    kAudioUnitScope_Global,
                                    0,
                                    &bpdata,
                                    sizeof(bpdata)),
               "kAUSamplerProperty_LoadPresetFromBank");
}


#pragma mark -
#pragma mark Audio control
- (void)playNoteOn:(UInt32)noteNum :(UInt32)velocity 
{
    UInt32 noteCommand = 0x90 | 0;
    NSLog(@"playNoteOn %u %u cmd %x", (unsigned int)noteNum, (unsigned int)velocity, (unsigned int)noteCommand);
	CheckError(MusicDeviceMIDIEvent(self.samplerUnit1, noteCommand, noteNum, velocity, 0),
               "NoteOn"
               );
}

- (void)playNoteOff:(UInt32)noteNum
{
	UInt32 noteCommand = 0x80 | 0;
	CheckError(MusicDeviceMIDIEvent(self.samplerUnit1, noteCommand, noteNum, 0, 0),
               "NoteOff"
               );
}


void MyMIDINotifyProc (const MIDINotification  *message, void *refCon) {
    printf("MIDI Notify, messageId=%d,", message->messageID);
}

static void MyMIDIReadProc(const MIDIPacketList *pktlist,
                           void *refCon,
                           void *connRefCon) {
    
    
    AudioUnit *player = (AudioUnit*) refCon;
    
    MIDIPacket *packet = (MIDIPacket *)pktlist->packet;
    for (int i=0; i < pktlist->numPackets; i++) {
        Byte midiStatus = packet->data[0];
        Byte midiCommand = midiStatus >> 4;
        
       
        
        if (midiCommand == 0x09) {
            
            Byte note = packet->data[1] & 0x7F;
            Byte velocity = packet->data[2] & 0x7F;
            
            int noteNumber = ((int) note) % 12;
            NSString *noteType;
            switch (noteNumber) {
                case 0:
                    noteType = @"C";
                    break;
                case 1:
                    noteType = @"C#/Db";
                    break;
                case 2:
                    noteType = @"D";
                    break;
                case 3:
                    noteType = @"D#/Eb";
                    break;
                case 4:
                    noteType = @"E";
                    break;
                case 5:
                    noteType = @"F";
                    break;
                case 6:
                    noteType = @"F#/Gb";
                    break;
                case 7:
                    noteType = @"G";
                    break;
                case 8:
                    noteType = @"G#/Ab";
                    break;
                case 9:
                    noteType = @"A";
                    break;
                case 10:
                    noteType = @"A#/Bb";
                    break;
                case 11:
                    noteType = @"B";
                    break;
                default:
                    break;
            }
            NSLog(@"%@: %i",noteType,noteNumber);
            
            
            OSStatus result = noErr;
            //result = MusicDeviceMIDIEvent (player, midiStatus, 83, 127, 0);
            result = MusicDeviceMIDIEvent (player, midiStatus, note, velocity, 0);
             //[refToSelf playNoteOn:note :127]; [refToSelf playNoteOn:100 :127];
        }
        packet = MIDIPacketNext(packet);
    }
}


- (void) setUpPlayerAndSequence {
    CheckError(NewMusicPlayer(&_musicPlayer),
               "NewMusicPlayer"
               );
    
    CheckError(NewMusicSequence(&_musicSequence),
               "NewMusicSequence"
               );
    
    CheckError(MusicPlayerSetSequence(self.musicPlayer, self.musicSequence),
               "MusicPlayerSetSequence"
               );
    
    CheckError(MusicSequenceSetAUGraph(self.musicSequence, self.processingGraph),
               "MusicSequenceSetAUGraph"
               );
    
    CAShow(self.musicSequence);

}




 - (void)generateMIDIFile:(NSArray *)bandPlayingSong
{
    
    
    [self createAUGraph];
    [self startGraph];
    [self setUpPlayerAndSequence];
    
    
    
   // MusicTrack track1,track2,track3;
    MusicTrack tracks[3];
    
    CheckError(MusicSequenceNewTrack(self.musicSequence,&tracks[0]),"MusicSequenceNewTrack");
    CheckError(MusicSequenceNewTrack(self.musicSequence,&tracks[1]),"MusicSequenceNewTrack");
    CheckError(MusicSequenceNewTrack(self.musicSequence,&tracks[2]),"MusicSequenceNewTrack");
    
    //NSValue *testValue = [NSValue valueWithBytes:&track1 objCType:@encode(MusicTrack)];
    //NSArray *testArray = @[testValue];
    
    //MusicTrack x = CFBridgingRetain([NSValue valueWithBytes:testArray[0] objCType:@encode(MusicTrack)]);

    
    MusicTrackLoopInfo loopSetting = {};
    loopSetting.loopDuration = 16;
    loopSetting.numberOfLoops = 0;
    
    
    
    MusicTrackSetProperty ( tracks[0], kSequenceTrackProperty_LoopInfo, &loopSetting, sizeof(loopSetting));
    MusicTrackSetProperty ( tracks[1], kSequenceTrackProperty_LoopInfo, &loopSetting, sizeof(loopSetting));
    
    loopSetting.loopDuration = 1;
    loopSetting.numberOfLoops = 0;
    
    MusicTimeStamp offsetTime = 0.0;
    
    MusicTrackSetProperty ( tracks[2], kSequenceTrackProperty_LoopInfo, &loopSetting, sizeof(loopSetting));
    MusicTrackSetProperty ( tracks[2], kSequenceTrackProperty_OffsetTime, &offsetTime, sizeof(offsetTime));
    
    
    
    
    
    NSArray *keyboardPerformance = bandPlayingSong[0][@"performance"];
    
     for ( int16_t chordNumber = 0; chordNumber < keyboardPerformance.count; chordNumber++) {
         NSArray *currentChord = keyboardPerformance[chordNumber];
         float beat =  [currentChord[0] floatValue];
         float duration = [currentChord[2] floatValue];
         NSArray *notesInChord = currentChord[1];
         for (int8_t noteNumber = 0; noteNumber < notesInChord.count; noteNumber++ ) {
             MIDINoteMessage voice;
             voice.duration = duration;
             voice.note = [notesInChord[noteNumber] integerValue];
             voice.velocity = 100;
             voice.channel = 1;
             MusicTrackNewMIDINoteEvent(tracks[0], beat, &voice);
         }
     }
    
    
    NSArray *bassPerformance = bandPlayingSong[1][@"performance"];
    
    for ( int16_t chordNumber = 0; chordNumber < bassPerformance.count; chordNumber++) {
        NSArray *currentChord = bassPerformance[chordNumber];
        float beat =  [currentChord[0] floatValue];
        float duration = [currentChord[2] floatValue];
        NSArray *notesInChord = currentChord[1];
        for (int8_t noteNumber = 0; noteNumber < notesInChord.count; noteNumber++ ) {
            MIDINoteMessage voice;
            voice.duration = duration;
            voice.note = [notesInChord[noteNumber] integerValue];
            voice.velocity = 100;
            voice.channel = 1;
            MusicTrackNewMIDINoteEvent(tracks[1], beat, &voice);
        }
    }
    
    NSArray *drumPerformance = bandPlayingSong[2][@"performance"];
    
    for ( int16_t chordNumber = 0; chordNumber < drumPerformance.count; chordNumber++) {
        NSArray *currentChord = drumPerformance[chordNumber];
        float beat =  [currentChord[0] floatValue];
        float duration = [currentChord[2] floatValue];
        NSArray *notesInChord = currentChord[1];
        for (int8_t noteNumber = 0; noteNumber < notesInChord.count; noteNumber++ ) {
            MIDINoteMessage voice;
            voice.duration = duration;
            voice.note = [notesInChord[noteNumber] integerValue];
            voice.velocity = 100;
            voice.channel = 1;
            MusicTrackNewMIDINoteEvent(tracks[2], beat, &voice);
        }
    }



    

    
    [self setupSampler];
    
    OSStatus result = noErr;
    
    // Create a client
    MIDIClientRef virtualMidi;
    result = MIDIClientCreate(CFSTR("Virtual Client"),
                              MyMIDINotifyProc,
                              NULL,
                              &virtualMidi);
    
    NSAssert( result == noErr, @"MIDIClientCreate failed. Error code: %d '%.4s'", (int) result, (const char *)&result);
    
    // Create an endpoint
    MIDIEndpointRef virtualEndpoint1,virtualEndpoint2;
    result = MIDIDestinationCreate(virtualMidi, (CFStringRef)@"Virtual Destination", MyMIDIReadProc, self.samplerUnit1, &virtualEndpoint1);
    result = MIDIDestinationCreate(virtualMidi, (CFStringRef)@"Virtual Destination", MyMIDIReadProc, self.samplerUnit2, &virtualEndpoint2);
    
    NSAssert( result == noErr, @"MIDIDestinationCreate failed. Error code: %d '%.4s'", (int) result, (const char *)&result);
    
    // Set the endpoint of the sequence to be our virtual endpoint
    MusicTrackSetDestMIDIEndpoint(tracks[0], virtualEndpoint1);
    MusicTrackSetDestMIDIEndpoint(tracks[1], virtualEndpoint2);
    

}



- (void) muteTrack:(NSInteger)trackNum
              mute:(BOOL)muteSetting{
    MusicTrack track;
    CheckError(MusicSequenceGetIndTrack (self.musicSequence, trackNum, &track),
               "MusicSequenceGetIndTrack"
               );
    
    BOOL muteTrack = muteSetting;
    UInt32 muteTrackSize = 0;
    MusicTrackSetProperty(track,
                          kSequenceTrackProperty_MuteStatus ,
                          &muteTrack,
                          muteTrackSize
                          );

}

- (void) playMIDIFile:(MusicTimeStamp)startPoint
         playBackRate:(float)playBackRate
{
    NSLog(@"starting music player");
    [self stopPlayintMIDIFile];
    CheckError(MusicPlayerSetTime(self.musicPlayer,(MusicTimeStamp)0),
               "MusicPlayerSetTime"
               );
    
    CheckError(MusicPlayerSetPlayRateScalar(self.musicPlayer,playBackRate),
               "MusicPlayerSetPlayRateScalar"
               );
    
    
    CheckError(MusicPlayerPreroll(self.musicPlayer),
               "MusicPlayerPreroll"
               );

    CheckError(MusicPlayerStart(self.musicPlayer),
               "MusicPlayerStart"
               );
    
   
}

- (void) setPlayerTime:(float)playerStartTime {
    CheckError(MusicPlayerSetTime(self.musicPlayer,(MusicTimeStamp)playerStartTime),
               "MusicPlayerStart"
               );
}

- (MusicTimeStamp)getPlayTime {
    MusicTimeStamp currentTime;
    Boolean isPlaying;
    
    CheckError(MusicPlayerGetTime(
                self.musicPlayer,&currentTime),
               "MusicPlayerGetTime"
               );

    CheckError(MusicPlayerIsPlaying(self.musicPlayer,&isPlaying),
               "MusicPlayerIsPlaying"
               );
    return currentTime;
}


- (void) stopPlayintMIDIFile
{
    NSLog(@"stopping music player");
    CheckError(MusicPlayerStop(self.musicPlayer),
               "MusicPlayerStop"
               );
}


-(void) cleanup
{    
    
    //stop the music player
    CheckError(MusicPlayerStop(self.musicPlayer),
               "MusicPlayerStop"
               );
    
    //get number of tracks in sequence
    UInt32 trackCount;
    CheckError(MusicSequenceGetTrackCount(self.musicSequence, &trackCount),
               "MusicSequenceGetTrackCount"
               );
    
    //dispose of each track in sequence
    MusicTrack track;
    for(int i = 0;i < trackCount; i++)
    {
        CheckError(MusicSequenceGetIndTrack (self.musicSequence,0,&track),
                   "MusicSequenceGetIndTrack"
                   );
        CheckError(MusicSequenceDisposeTrack(self.musicSequence, track),
                   "MusicSequenceDisposeTrack"
                   );
    }
    
    //dispose of the music player
    CheckError(DisposeMusicPlayer(self.musicPlayer),
               "DisposeMusicPlayer"
               );
    
    //dispose of the music sequence
    CheckError(DisposeMusicSequence(self.musicSequence),
               "DisposeMusicSequence"
               );
    
    //dispose of the sound graph
    CheckError(DisposeAUGraph(self.processingGraph),
               "DisposeAUGraph"
               );
}

@end
