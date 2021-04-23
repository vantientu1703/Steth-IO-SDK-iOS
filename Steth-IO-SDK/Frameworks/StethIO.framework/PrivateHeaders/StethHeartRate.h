//
//  StethHeartRate.h
//  Steth.io
//
//  Created by Tom Andersen on 2015/4/22.
//  Copyright (c) 2015 Strato Scientific. All rights reserved.
//

#ifndef __Steth_io__StethHeartRate__
#define __Steth_io__StethHeartRate__

#include <stdio.h>

extern long sBPMBufferCount;
extern const long  kBPMFrequencyDropFactor;
extern float sBPMDownsampledBuffer[];

void glrate_setBPMErrorThreshold(double threshold); // 0.1 to 1.0 please . 1.0 means let everything through
void glrate_setBPMWindow(double window);
double glrate_currentHearRate(float* samples, long numSamples);
void glrate_resetHeartRate(void);
void downSample(float* samples,int numSamples,float rate);


#endif /* defined(__Steth_io__StethHeartRate__) */
