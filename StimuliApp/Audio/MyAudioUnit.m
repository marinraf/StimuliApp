//  Created by Ronald Nicholson on 7/31/17.
//  Copyright © 2017 HotPaw Productions.
//
//Redistribution and use in source and binary forms, with or without modification,
//are permitted provided that the following conditions are met:
//
//1. Redistributions of source code must retain the above copyright notice,
//this list of conditions and the following disclaimer.
//
//2. Redistributions in binary form must reproduce the above copyright notice,
//this list of conditions and the following disclaimer in the documentation
//and/or other materials provided with the distribution.
//
//THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
//INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
//SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
//WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE
//USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//  Audio Unit subclass created in Objective C ,
//    but using only the C subset inside the audio callback context
//    to meet real-time audio predictable latency requirements:
//       - no Obj C or Swift runtime (as per WWDC 2017 session on Core Audio)
//       - no memory management
//       - no potentially blocking locks or GCD calls

#import "MyAudioUnit.h"

float myAUSampleRateHz;
long int myAUToneCounter;
double myAUToneCounterLoop;
long int myAUToneCounterStop;
float myAUChangingTones;
int myAUNumberOfAudios;
long int myAUStart[10];
long int myAUEnd[10];
float myAUFrequency[10];
float myAUAmplitude[10];
float myAUChannel[10];
float myAUPhase[10];
int myAUSong[10];
float *myValues[20];
long int myLengths[20];
AVAudioPCMBuffer *myAudios[20];

@interface MyAudioUnit ()
@property AUAudioUnitBusArray *outputBusArray;
//@property UnsafeBufferPointer *nose;
@end

@implementation MyAudioUnit {  // an eXperimental V3 AudioUnit
    // float              myAUFrequency;
    AudioBufferList const *myAudioBufferList;
    AVAudioPCMBuffer *my_pcmBuffer;
    AUAudioUnitBus *outputBus;
}

// @synthesize parameterTree;
@synthesize outputBusArray;

- (instancetype)initWithComponentDescription: (AudioComponentDescription)componentDescription
                                     options: (AudioComponentInstantiationOptions)options
                                       error: (NSError **)outError {

    self = [super initWithComponentDescription: componentDescription
                                       options: options
                                         error: outError];

    if (self == nil) { return nil; }

    AVAudioFormat *defaultFormat = [[AVAudioFormat alloc]
                                    initStandardFormatWithSampleRate: myAUSampleRateHz
                                    channels: 2];

    outputBus = [[AUAudioUnitBus alloc] initWithFormat:defaultFormat error:nil];
    outputBusArray = [[AUAudioUnitBusArray alloc] initWithAudioUnit: self
                                                            busType: AUAudioUnitBusTypeOutput
                                                             busses: @[outputBus]];

    self.maximumFramesToRender =  512;

    for (int i = 0; i < 20; ++i) {
        free(myValues[i]);
    }

    for (int i = 0; i < 20; ++i) {
        myLengths[i] = myAudios[i].frameLength;
        if (myLengths[i] > 0) {
            myValues[i] = malloc(myAudios[i].frameLength * sizeof(float)); // remember to free eventually
            memcpy(myValues[i], myAudios[i].floatChannelData[0], myAudios[i].frameLength * sizeof(float));
        }
    }
    return self;
}

- (AUAudioUnitBusArray *)outputBusses {
    return outputBusArray;
}

- (BOOL)allocateRenderResourcesAndReturnError:(NSError **)outError {
    if (![super allocateRenderResourcesAndReturnError:outError]) { return NO; }

    my_pcmBuffer = [[AVAudioPCMBuffer alloc] initWithPCMFormat: outputBus.format
                                                 frameCapacity: 4096];
    myAudioBufferList = my_pcmBuffer.audioBufferList;
    return YES;
}

- (void)deallocateRenderResources {
    [super deallocateRenderResources];
}

// sometimes the buffers come back nil, so fix them
void repairOutputBufferList(AudioBufferList *outBufferList,
                            AVAudioFrameCount frameCount,
                            bool zeroFill,
                            AudioBufferList const *myAudioBufferList) {

    UInt32 byteSize = frameCount * sizeof(float);
    int numberOfOutputBuffers = outBufferList->mNumberBuffers;
    if (numberOfOutputBuffers > 2) { numberOfOutputBuffers = 2; }

    for (int i = 0; i < numberOfOutputBuffers; ++i) {
        outBufferList->mBuffers[i].mNumberChannels = myAudioBufferList->mBuffers[i].mNumberChannels;
        outBufferList->mBuffers[i].mDataByteSize = byteSize; // set buffer size
        if (outBufferList->mBuffers[i].mData == NULL) { // copy buffer pointers if needed
            outBufferList->mBuffers[i].mData = myAudioBufferList->mBuffers[i].mData;
        }
        if (zeroFill) { memset(outBufferList->mBuffers[i].mData, 0, byteSize); }
    }
}

// generate random number between 0 and 1 (both included)
double r2()
{
    return (double)rand() * 2.0 / (double)RAND_MAX - 1.0;
}

#pragma mark - AUAudioUnit (AUAudioUnitImplementation)

- (AUInternalRenderBlock)internalRenderBlock {

    AudioBufferList const **myABLCaptured = &myAudioBufferList;

    return ^AUAudioUnitStatus(AudioUnitRenderActionFlags *actionFlags,
                              const AudioTimeStamp *timestamp,
                              AVAudioFrameCount frameCount,
                              NSInteger outputBusNumber,
                              AudioBufferList *outputBufferListPtr,
                              const AURenderEvent *realtimeEventListHead,
                              AURenderPullInputBlock pullInputBlock ) {

        int numBuffers = outputBufferListPtr->mNumberBuffers;

        AudioBufferList const *tmpABL = *myABLCaptured;
        repairOutputBufferList(outputBufferListPtr, frameCount, false, tmpABL);

        float *ptrLeft = (float*)outputBufferListPtr->mBuffers[0].mData;
        float *ptrRight = NULL;
        if (numBuffers == 2) {
            ptrRight = (float*)outputBufferListPtr->mBuffers[1].mData;
        }
        float stop = 1;

        // example C routine to create an audio output waveform
        int n = frameCount;
        myAUToneCounterLoop = CACurrentMediaTime();

        for (int i = 0; i < n; i++) {
            float left = 0;
            float right = 0; // default to silence
            if (myAUToneCounter > 0) {
                left = 0;
                right = 0;
                if (myAUToneCounterStop > 1) {
                    stop = myAUToneCounterStop / myAUChangingTones;
                    myAUToneCounterStop --;
                    if (myAUToneCounterStop == 1) {
                        stop = 0;
                    }
                } else if (myAUToneCounterStop == 1) {
                    stop = 0;
                    myAUToneCounter = 0;
                } else {
                    stop = 1;
                }

                for (int j = 0; j < myAUNumberOfAudios; j++) {
                    if (myAUToneCounter < myAUStart[j] && myAUToneCounter > myAUEnd[j]) {
                        float v1 = 1;
                        if (myAUToneCounter > myAUStart[j] - myAUChangingTones) {
                            v1 = (myAUStart[j] - myAUToneCounter) / myAUChangingTones;
                        } else if (myAUToneCounter < myAUEnd[j] + myAUChangingTones) {
                            v1 = (myAUToneCounter - myAUEnd[j]) / myAUChangingTones;
                        }

                        float x = myAUAmplitude[j] * v1 * stop;

                        if (myAUFrequency[j] > 0.1) {
                            float dp = 2.0 * M_PI * myAUFrequency[j] / myAUSampleRateHz; // calculate phase increment
                            myAUPhase[j] = myAUPhase[j] + dp;
                            x *= sinf(myAUPhase[j]);

                            // sin function is more accurate if angle is within the normal range
                            if (myAUPhase[j] > M_PI) {
                                myAUPhase[j] -= 2.0 * M_PI;
                            }
                        } else if (myAUFrequency[j] < -0.1) {
                            int number = myAUSong[j];
                            long position = myAUStart[j] - myAUToneCounter;

                            bool done = false;

                            for (int i = 0; i < 20; ++i) {
                                if (number == i) {
                                    if (myLengths[i] > position) {
                                        x *= myValues[i][position];
                                        done = true;
                                    }
                                    break;
                                }
                            }
                            if (!done) {
                                x = 0;
                            }
                        } else {
                            x *= r2();
                        }
                        left += x * (1 - myAUChannel[j]);
                        right += x * myAUChannel[j];
                    }
                }
                myAUToneCounter --;
            }
            if (ptrLeft != NULL) { ptrLeft[i] = left; } //write samples to buffer
            if (ptrRight != NULL) { ptrRight[i] = right; }
        }
        return noErr;
    };
}

@end
