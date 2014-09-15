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

@implementation GDSoundEngine

@synthesize playing = _playing;
@synthesize processingGraph = _processingGraph;
@synthesize samplerNode1 = _samplerNode1;
@synthesize samplerNode2 = _samplerNode2;
@synthesize samplerNode3 = _samplerNode3;
@synthesize mixerNode = _mixerNode;
@synthesize ioNode = _ioNode;
@synthesize ioUnit = _ioUnit;
@synthesize samplerUnit1 = _samplerUnit1;
@synthesize samplerUnit2 = _samplerUnit2;
@synthesize samplerUnit3 = _samplerUnit3;
@synthesize presetNumber = _presetNumber;

@synthesize musicSequence = _musicSequence;
@synthesize musicTrack = _musicTrack;
@synthesize musicPlayer = _musicPlayer;

- (id) init 
{
    if ( self = [super init] ) {
        [self createAUGraph];
        [self startGraph];
        //[self setupSampler:self.presetNumber];
        
    }
    
    return self;
}

#pragma mark - Audio setup
- (BOOL) createAUGraph
{
    NSLog(@"Creating the graph");
    
    CheckError(NewAUGraph(&_processingGraph),
			   "NewAUGraph");
    
    // create the sampler
    // for now, just have it play the default sine tone
	AudioComponentDescription cd = {};
	cd.componentType = kAudioUnitType_MusicDevice;
	cd.componentSubType = kAudioUnitSubType_Sampler;
	cd.componentManufacturer = kAudioUnitManufacturer_Apple;
	cd.componentFlags = 0;
	cd.componentFlagsMask = 0;
	CheckError(AUGraphAddNode(self.processingGraph, &cd, &_samplerNode1), "AUGraphAddNode");
    CheckError(AUGraphAddNode(self.processingGraph, &cd, &_samplerNode2), "AUGraphAddNode");
    CheckError(AUGraphAddNode(self.processingGraph, &cd, &_samplerNode3), "AUGraphAddNode");
    
    
    
    //Mixer Unit
    cd.componentType          = kAudioUnitType_Mixer;
    cd.componentSubType       = kAudioUnitSubType_MultiChannelMixer;
    
    AUGraphAddNode (self.processingGraph, &cd, &_mixerNode);
    
    
   
     //-----------------------------------------------------------
     // Obtain the mixer unit instance from its corresponding node
     
     //-----------------------------------------------------------
     AUGraphNodeInfo (
     self.processingGraph,
     self.mixerNode,
     NULL,
     &_mixerUnit
     );
     
     //--------------------------------
     // Set the bus count for the mixer
     //--------------------------------
     UInt32 numBuses = 3;
     AudioUnitSetProperty(_mixerUnit,
     kAudioUnitProperty_ElementCount,
     kAudioUnitScope_Input,
     0,
     &numBuses,
     sizeof(numBuses));

    
    // I/O unit
    AudioComponentDescription iOUnitDescription;
    iOUnitDescription.componentType          = kAudioUnitType_Output;
    iOUnitDescription.componentSubType       = kAudioUnitSubType_RemoteIO;
    iOUnitDescription.componentManufacturer  = kAudioUnitManufacturer_Apple;
    iOUnitDescription.componentFlags         = 0;
    iOUnitDescription.componentFlagsMask     = 0;
    
    CheckError(AUGraphAddNode(self.processingGraph, &iOUnitDescription, &_ioNode), "AUGraphAddNode");
    
    // now do the wiring. The graph needs to be open before you call AUGraphNodeInfo
	CheckError(AUGraphOpen(self.processingGraph), "AUGraphOpen");
    
	CheckError(AUGraphNodeInfo(self.processingGraph,
                               self.samplerNode1,
                               NULL,
                               &_samplerUnit1),
               "AUGraphNodeInfo");
    CheckError(AUGraphNodeInfo(self.processingGraph,
                               self.samplerNode2,
                               NULL,
                               &_samplerUnit2),
               "AUGraphNodeInfo");
    CheckError(AUGraphNodeInfo(self.processingGraph,
                               self.samplerNode3,
                               NULL,
                               &_samplerUnit3),
               "AUGraphNodeInfo");
    CheckError(AUGraphNodeInfo (
                     self.processingGraph,
                     self.mixerNode,
                     NULL,
                     &_mixerUnit),
                    "AUGraphNodeInfo" );
    
    CheckError(AUGraphNodeInfo(self.processingGraph, self.ioNode, NULL, &_ioUnit), 
               "AUGraphNodeInfo");
    
    //------------------
    // Connect the nodes
    //------------------
    
    AUGraphConnectNodeInput (self.processingGraph, self.samplerNode1, 0, self.mixerNode, 0);
    AUGraphConnectNodeInput (self.processingGraph, self.samplerNode2, 0, self.mixerNode, 1);
    AUGraphConnectNodeInput (self.processingGraph, self.samplerNode3, 0, self.mixerNode, 2);
    
    AudioUnitElement ioUnitOutputElement = 0;
    AudioUnitElement samplerOutputElement = 0;
   /* CheckError(AUGraphConnectNodeInput(self.processingGraph,
                                       self.samplerNode1, samplerOutputElement, // srcnode, inSourceOutputNumber
                                       self.ioNode, ioUnitOutputElement), // destnode, inDestInputNumber
               "AUGraphConnectNodeInput");
    */
    // Connect the mixer unit to the output unit
    AUGraphConnectNodeInput (self.processingGraph, self.mixerNode, 0, self.ioNode, 0);

    
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
        CheckError(AUGraphIsInitialized(self.processingGraph,
                                        &outIsInitialized), "AUGraphIsInitialized");
        if(!outIsInitialized)
            CheckError(AUGraphInitialize(self.processingGraph), "AUGraphInitialize");
        
        Boolean isRunning;
        CheckError(AUGraphIsRunning(self.processingGraph,
                                    &isRunning), "AUGraphIsRunning");
        if(!isRunning)
            CheckError(AUGraphStart(self.processingGraph), "AUGraphStart");
        self.playing = YES;
    }
}
- (void) stopAUGraph {
    
    NSLog (@"Stopping audio processing graph");
    Boolean isRunning = false;
    CheckError(AUGraphIsRunning (self.processingGraph, &isRunning), "AUGraphIsRunning");
    
    if (isRunning) {
        CheckError(AUGraphStop(self.processingGraph), "AUGraphStop");
        self.playing = NO;
    }
}

#pragma mark - Sampler

- (void) setupSampler:(UInt8) pn;
{
    
    
     //-------------------------------------------------
     // Set the AUSampler nodes to be used by each track
     //-------------------------------------------------
     MusicTrack track, trackTwo, trackThree;
     MusicSequenceGetIndTrack(self.musicSequence, 0, &track);
     MusicSequenceGetIndTrack(self.musicSequence, 1, &trackTwo);
     MusicSequenceGetIndTrack(self.musicSequence, 2, &trackThree);
     
     AUNode samplerNode, samplerNodeTwo, samplerNodeThree;
     AUGraphGetIndNode (self.processingGraph, 0, &samplerNode);
     AUGraphGetIndNode (self.processingGraph, 1, &samplerNodeTwo);
     AUGraphGetIndNode (self.processingGraph, 2, &samplerNodeThree);
     
     MusicTrackSetDestNode(track, samplerNode);
     MusicTrackSetDestNode(trackTwo, samplerNodeTwo);
     MusicTrackSetDestNode(trackThree, samplerNodeThree);
   
    
    // propagates stream formats across the connections
    Boolean outIsInitialized;
    CheckError(AUGraphIsInitialized(self.processingGraph,
                                    &outIsInitialized), "AUGraphIsInitialized");
    if(!outIsInitialized) {
        return;
    }
    if(pn < 0 || pn > 127) {
        return;
    }
    NSURL *bankURL;
    bankURL = [[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle] 
                                                  pathForResource:@"fluid_gm" ofType:@"sf2"]];
    NSLog(@"set pn %d", pn);
    
    // fill out a bank preset data structure
    AUSamplerBankPresetData bpdata;
    bpdata.bankURL  = (__bridge CFURLRef) bankURL;
    bpdata.bankMSB  = kAUSampler_DefaultMelodicBankMSB;
    bpdata.bankLSB  = kAUSampler_DefaultBankLSB;
    bpdata.presetID = (UInt8) 0;
    
    // set the kAUSamplerProperty_LoadPresetFromBank property
    CheckError(AudioUnitSetProperty(self.samplerUnit1,
                                    kAUSamplerProperty_LoadPresetFromBank,
                                    kAudioUnitScope_Global,
                                    0,
                                    &bpdata,
                                    sizeof(bpdata)), "kAUSamplerProperty_LoadPresetFromBank");
    bpdata.presetID = (UInt8) 32;
    // set the kAUSamplerProperty_LoadPresetFromBank property
    CheckError(AudioUnitSetProperty(self.samplerUnit2,
                                    kAUSamplerProperty_LoadPresetFromBank,
                                    kAudioUnitScope_Global,
                                    0,
                                    &bpdata,
                                    sizeof(bpdata)), "kAUSamplerProperty_LoadPresetFromBank");
    
    bpdata.presetID = (UInt8) 115;
    CheckError(AudioUnitSetProperty(self.samplerUnit3,
                                    kAUSamplerProperty_LoadPresetFromBank,
                                    kAudioUnitScope_Global,
                                    0,
                                    &bpdata,
                                    sizeof(bpdata)), "kAUSamplerProperty_LoadPresetFromBank");
    
    
    NSLog (@"sampler ready");
}

- (void) setPresetNumber:(UInt8) p
{
    NSLog(@"setPresetNumber %d", p);
    
    _presetNumber = p;
    
    if(self.processingGraph)
        [self setupSampler:p];
}

#pragma mark -
#pragma mark Audio control
- (void)playNoteOn:(UInt32)noteNum :(UInt32)velocity 
{
    UInt32 noteCommand = 0x90 | 0;
    NSLog(@"playNoteOn %lu %lu cmd %lx", noteNum, velocity, noteCommand);
	CheckError(MusicDeviceMIDIEvent(self.samplerUnit1, noteCommand, noteNum, velocity, 0), "NoteOn");
}

- (void)playNoteOff:(UInt32)noteNum
{
	UInt32 noteCommand = 0x80 | 0;
	CheckError(MusicDeviceMIDIEvent(self.samplerUnit1, noteCommand, noteNum, 0, 0), "NoteOff");
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
                    noteType = @"C#";
                    break;
                case 2:
                    noteType = @"D";
                    break;
                case 3:
                    noteType = @"D#";
                    break;
                case 4:
                    noteType = @"E";
                    break;
                case 5:
                    noteType = @"F";
                    break;
                case 6:
                    noteType = @"F#";
                    break;
                case 7:
                    noteType = @"G";
                    break;
                case 8:
                    noteType = @"G#";
                    break;
                case 9:
                    noteType = @"A";
                    break;
                case 10:
                    noteType = @"Bb";
                    break;
                case 11:
                    noteType = @"B";
                    break;
                default:
                    break;
            }
            NSLog([noteType stringByAppendingFormat:[NSString stringWithFormat:@": %i", noteNumber]]);
            
            
            OSStatus result = noErr;
            result = MusicDeviceMIDIEvent (player, midiStatus, note, velocity, 0);
        }
        packet = MIDIPacketNext(packet);
    }
}


 - (void)loadMIDIFile:(NSString *)midifileName
{
    
    NSURL *midiFileURL = [[NSURL alloc] initFileURLWithPath:
                          [[NSBundle mainBundle] pathForResource:midifileName
                                                          ofType:@"mid"]];
    if (midiFileURL) {
        NSLog(@"midiFileURL = '%@'\n", [midiFileURL description]);
    }
    
    
    
    CheckError(NewMusicPlayer(&_musicPlayer), "NewMusicPlayer");
    
    CheckError(NewMusicSequence(&_musicSequence), "NewMusicSequence");
    
    CheckError(MusicPlayerSetSequence(self.musicPlayer, self.musicSequence), "MusicPlayerSetSequence");
    
    
    CheckError(MusicSequenceFileLoad(self.musicSequence,
                                     (__bridge CFURLRef) midiFileURL,
                                     0, // can be zero in many cases
                                     kMusicSequenceLoadSMF_ChannelsToTracks), "MusicSequenceFileLoad");
    
    // Create a client
    OSStatus result = noErr;
    MIDIClientRef virtualMidi;
    result = MIDIClientCreate(CFSTR("Virtual Client"),
                              MyMIDINotifyProc,
                              NULL,
                              &virtualMidi);
    
    // Create an endpoint
    MIDIEndpointRef virtualEndpoint;
    result = MIDIDestinationCreate(virtualMidi, CFSTR("Virtual Destination"), MyMIDIReadProc, self.samplerUnit2, &virtualEndpoint);
    
    NSAssert( result == noErr, @"MIDIDestinationCreate failed. Error code: %d '%.4s'", (int) result, (const char *)&result);
    
     MusicSequenceSetMIDIEndpoint(self.musicSequence, virtualEndpoint);
    
    CheckError(MusicSequenceSetAUGraph(self.musicSequence, self.processingGraph),
               "MusicSequenceSetAUGraph");
     
    //CAShow(self.musicSequence);
    
    UInt32 trackCount;
    CheckError(MusicSequenceGetTrackCount(self.musicSequence, &trackCount), "MusicSequenceGetTrackCount");
    NSLog(@"Number of tracks: %lu", trackCount);
    MusicTrack track;
    for(int i = 0; i < trackCount; i++)
    {
        CheckError(MusicSequenceGetIndTrack (self.musicSequence, i, &track), "MusicSequenceGetIndTrack");
        
        MusicTimeStamp track_length;
        UInt32 tracklength_size = sizeof(MusicTimeStamp);
        CheckError(MusicTrackGetProperty(track, kSequenceTrackProperty_TrackLength, &track_length, &tracklength_size), "kSequenceTrackProperty_TrackLength");
        NSLog(@"Track length %f", track_length);
        
        self.trackLength = track_length;
        
        
        [self iterate:track];
        
    }
    
    
    /*
     OSStatus MusicSequenceNewTrack (
     MusicSequence  inSequence,
     MusicTrack     *outTrack
     );
     
     
    */
    
    CheckError(MusicSequenceNewTrack(self.musicSequence,&track),"MusicSequenceNewTrack");
    //hack to experiment with dynamic sequence generation
    CheckError(MusicSequenceGetIndTrack (self.musicSequence, 3, &track), "MusicSequenceGetIndTrack");
    
    
    for ( int x =0; x < 100; x++) {
        MIDINoteMessage message;
        message.duration = .5;
        message.note = 60 + x%10;
        message.velocity = 100;
        message.channel = 0;
        MusicTrackNewMIDINoteEvent(track, x + .5, &message);
    }
    
    
    
    

    
}

- (void) muteTrack:(NSInteger)trackNum
              mute:(BOOL)muteSetting{
    MusicTrack track;
    CheckError(MusicSequenceGetIndTrack (self.musicSequence, trackNum, &track), "MusicSequenceGetIndTrack");
    
    BOOL muteTrack = muteSetting;
    UInt32 muteTrackSize;
    MusicTrackSetProperty(track, kSequenceTrackProperty_MuteStatus , &muteTrack, &muteTrackSize);

}



- (void) iterate: (MusicTrack) track
{
	MusicEventIterator	iterator;
	CheckError(NewMusicEventIterator (track, &iterator), "NewMusicEventIterator");
    
    
    MusicEventType eventType;
	MusicTimeStamp eventTimeStamp;
    UInt32 eventDataSize;
    const void *eventData;
    
    Boolean	hasCurrentEvent = NO;
    CheckError(MusicEventIteratorHasCurrentEvent(iterator, &hasCurrentEvent), "MusicEventIteratorHasCurrentEvent");
    while (hasCurrentEvent)
    {
        MusicEventIteratorGetEventInfo(iterator, &eventTimeStamp, &eventType, &eventData, &eventDataSize);
        //NSLog(@"event timeStamp %f ", ceil(eventTimeStamp));
        /*if ((ceil(eventTimeStamp) - eventTimeStamp) < .0625) {
            MusicTimeStamp newVal = ceil(eventTimeStamp);
            MusicEventIteratorSetEventTime(iterator,newVal );
        }*/
        
        
        switch (eventType) {
                
            case kMusicEventType_ExtendedNote : {
                ExtendedNoteOnEvent* ext_note_evt = (ExtendedNoteOnEvent*)eventData;
                //NSLog(@"extended note event, instrumentID %lu", ext_note_evt->instrumentID);

            }
                break ;
                
            case kMusicEventType_ExtendedTempo : {
                ExtendedTempoEvent* ext_tempo_evt = (ExtendedTempoEvent*)eventData;
               // NSLog(@"ExtendedTempoEvent, bpm %f", ext_tempo_evt->bpm);

            }
                break ;
                
            case kMusicEventType_User : {
                MusicEventUserData* user_evt = (MusicEventUserData*)eventData;
                // NSLog(@"MusicEventUserData, data length %lu", user_evt->length);
            }
                break ;
                
            case kMusicEventType_Meta : {
                MIDIMetaEvent* meta_evt = (MIDIMetaEvent*)eventData;
                //NSLog(@"MIDIMetaEvent, event type %d", meta_evt->metaEventType);

            }
                break ;
                
            case kMusicEventType_MIDINoteMessage : {
                MIDINoteMessage* note_evt = (MIDINoteMessage*)eventData;
               
                
               if (note_evt->channel == 9 ) {
                    note_evt->note = 50;
                }
                
                if (note_evt->channel == 0 ) {
                    NSLog(@"note event channel %d", note_evt->channel);
                    NSLog(@"event timeStamp %f ", eventTimeStamp);
                    NSLog(@"note event note %d", note_evt->note);
                    NSLog(@"note event duration %f", note_evt->duration);
                    NSLog(@"note event velocity %d", note_evt->velocity);
                    NSLog(@"-----------------------------");
                }
               
            }
                break ;
                
            case kMusicEventType_MIDIChannelMessage : {
                MIDIChannelMessage* channel_evt = (MIDIChannelMessage*)eventData;
                //NSLog(@"channel event status %X", channel_evt->status);
                //NSLog(@"channel event d1 %X", channel_evt->data1);
                //NSLog(@"channel event d2 %X", channel_evt->data2);
                
                if(channel_evt->status == (0xC0 & 0xF0)) {
                    [self setPresetNumber:channel_evt->data1];
                }
            }
                break ;
                
            case kMusicEventType_MIDIRawData : {
                MIDIRawData* raw_data_evt = (MIDIRawData*)eventData;
                //NSLog(@"MIDIRawData, length %lu", raw_data_evt->length);

            }
                break ;
                
            case kMusicEventType_Parameter : {
                ParameterEvent* parameter_evt = (ParameterEvent*)eventData;
               // NSLog(@"ParameterEvent, parameterid %lu", parameter_evt->parameterID);

            }
                break ;
                
            default :
                break ;
        }
        
        CheckError(MusicEventIteratorHasNextEvent(iterator, &hasCurrentEvent), "MusicEventIteratorHasCurrentEvent");
        CheckError(MusicEventIteratorNextEvent(iterator), "MusicEventIteratorNextEvent");
    }
}

- (void) playMIDIFile:(MusicTimeStamp)startPoint
         playBackRate:(float)playBackRate
{
    NSLog(@"starting music player");
    [self stopPlayintMIDIFile];
    CheckError(MusicPlayerSetTime(self.musicPlayer,(MusicTimeStamp)startPoint),"MusicPlayerSetTime");
    
    CheckError(MusicPlayerSetPlayRateScalar(self.musicPlayer,playBackRate),
               "MusicPlayerSetPlayRateScalar");
    
    
    CheckError(MusicPlayerPreroll(self.musicPlayer), "MusicPlayerPreroll");

    CheckError(MusicPlayerStart(self.musicPlayer), "MusicPlayerStart");
    
   
}

- (void) setPlayerTime:(float)playerStartTime {
    CheckError(MusicPlayerSetTime(self.musicPlayer,(MusicTimeStamp)playerStartTime), "MusicPlayerStart");
}

- (MusicTimeStamp)getPlayTime {
    MusicTimeStamp currentTime;
    Boolean isPlaying;
    CheckError(MusicPlayerGetTime(
                self.musicPlayer,&currentTime),
               "MusicPlayerGetTime"
               );

    CheckError(MusicPlayerIsPlaying(self.musicPlayer,&isPlaying),"MusicPlayerIsPlaying");
    if (isPlaying && currentTime > 152.0 ) {
        [self stopPlayintMIDIFile];
    }
    
    if (!isPlaying) {
        currentTime = -1.0;
    }
    
    return currentTime;
}


- (void) stopPlayintMIDIFile
{
    NSLog(@"stopping music player");
       CheckError(MusicPlayerStop(self.musicPlayer), "MusicPlayerStop");
}


-(void) cleanup
{    
    CheckError(MusicPlayerStop(self.musicPlayer), "MusicPlayerStop");
    
    UInt32 trackCount;
    CheckError(MusicSequenceGetTrackCount(self.musicSequence, &trackCount), "MusicSequenceGetTrackCount");
    MusicTrack track;
    for(int i = 0;i < trackCount; i++)
    {
        CheckError(MusicSequenceGetIndTrack (self.musicSequence,0,&track), "MusicSequenceGetIndTrack");
        CheckError(MusicSequenceDisposeTrack(self.musicSequence, track), "MusicSequenceDisposeTrack");
    }
    
    CheckError(DisposeMusicPlayer(self.musicPlayer), "DisposeMusicPlayer");
    CheckError(DisposeMusicSequence(self.musicSequence), "DisposeMusicSequence");
    CheckError(DisposeAUGraph(self.processingGraph), "DisposeAUGraph");
}

@end
