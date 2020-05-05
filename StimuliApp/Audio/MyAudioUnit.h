//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

extern float myAUSampleRateHz;
extern long int myAUToneCounter;
extern long int myAUToneCounterStop;
extern float myAUChangingTones;
extern int myAUNumberOfAudios;
extern long int myAUStart[10];
extern long int myAUEnd[10];
extern float myAUFrequency[10];
extern float myAUAmplitude[10];
extern float myAUChannel[10];
extern float myAUPhase[10];
extern int myAUSong[10];

extern AVAudioPCMBuffer *myAudios[20];


@interface MyAudioUnit : AUAudioUnit {
    AUAudioUnitBusArray *outputBusArray;
}

@end
