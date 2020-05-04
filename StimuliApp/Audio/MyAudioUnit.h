//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

extern float myAUSampleRateHz;
extern long int myAUToneCounter;
extern long int myAUToneCounterStop;
extern float myAUChangingTones;
extern int myAUNumberOfAudios;
extern float myAUStart[10];
extern float myAUEnd[10];
extern float myAUFrequency[10];
extern float myAUAmplitude[10];
extern float myAUChannel[10];
extern float myAUPhase[10];
extern float myAUSong[10];

extern AVAudioPCMBuffer *myAudios[20];

//extern AVAudioPCMBuffer *audio0;
//extern AVAudioPCMBuffer *audio1;
//extern AVAudioPCMBuffer *audio2;
//extern AVAudioPCMBuffer *audio3;
//extern AVAudioPCMBuffer *audio4;
//extern AVAudioPCMBuffer *audio5;
//extern AVAudioPCMBuffer *audio6;
//extern AVAudioPCMBuffer *audio7;
//extern AVAudioPCMBuffer *audio8;
//extern AVAudioPCMBuffer *audio9;


@interface MyAudioUnit : AUAudioUnit {
    AUAudioUnitBusArray *outputBusArray;
}

@end
