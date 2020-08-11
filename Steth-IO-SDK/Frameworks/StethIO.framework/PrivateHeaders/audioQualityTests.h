//
//  audioQualityTests.h
//  Steth.io
//
//  Created by Ray Miller on 12/16/19.
//  Copyright © 2019 Strato Scientific. All rights reserved.
//

#ifndef audioQualityTests_h
#define audioQualityTests_h

#include <stdio.h>

//At 10 Hz sampling:
//4 is 150 BPM
//15 is 40 BPM
#define MIN_PERIOD 3
#define MAX_PERIOD 15

#define LOWPASS_FREQ 300.0
#define HIGHPASS_FREQ 400.0

//For analysis windows on envelopes
#define BASE_WINDOW 20
#define WINDOW_SHIFT 5

//low frequency vs high frequency minimum ratio (clarity)
#define CLARITY_THRESHOLD 8.0

#define SHORT_CORRELATION_PEAK_THRESHOLD 0.8

#define SHORT_CORRELATION_PROMINENCE  0.8

#define LONG_CORRELATION_PEAK_THRESHOLD 0.3

#define LONG_CORRELATION_PROMINENCE 0.3

//call with count=0 to reset before recording!
int evaluateAudio(float *samples, int count);
void addStatusAudio(float *samples, int statusMap, int count);

#endif /* audioQualityTests_h */
