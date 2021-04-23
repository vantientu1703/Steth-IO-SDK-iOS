//
//  StethAudioFilters.h
//  Steth.io
//
//  Created by Tom Andersen on 2015/1/20.
//  Copyright (c) 2015 Strato Scientific. All rights reserved.
//

#ifndef __Steth_io__StethAudioFilters__
#define __Steth_io__StethAudioFilters__

#include <stdio.h>
#include "biquad.h"

extern const int kUseHeartFilters;
extern const int kUseLungFilters;


typedef enum {BEAT_STATUS_IDLE, BEAT_STATUS_IN_PROGRESS, BEAT_STATUS_FOUND} BeatStatus_t;

typedef struct{
    //We will find the maximum sample value from first to last if they are valid
    //
    BeatStatus_t status;
    int firstSampleIndex;
    int lastSampleIndex;
    int totalSampleDuration;
    float peakSampleWithinDuration;
    float peakRatingWithinDuration;
    float confidence; //that this is a heartbeat [0,1]
} heartPeak_t;


typedef float (*floatFilter)(float);
typedef double (*doubleFilter)(double);

float Butterworth400HzLowPassOn44kSampleRate4Pole(float inSample);
float Butterworth550HzLowPassOn44kSampleRate4Pole(float inSample);
float Butterworth800HzLowPassOn44kSampleRate4Pole(float inSample);
double Butterworth150HzHighPassOn1024SampleRate1Pole(double inSample);
double Butterworth100HzHighPassOn44100SampleRate2Pole(double inSample);
double Butterworth150HzHighPassOn44kSampleRate2Pole(double inSample);
double Butterworth100HzHighPassOn1024SampleRate2Pole(double inSample);
double Butterworth50HzHighPassOn1024SampleRate2Pole(double inSample);
double Butterworth13HzHighPassOn44100SampleRate2Pole(double inSample);
double Butterworth200HzHighPassOn1024SampleRate3Pole(double inSample);
double Butterworth40to130HzBandPassOn1024SampleRate1Pole(double inSample);
double Butterworth100to150HzBandPassOn1024SampleRate2Pole(double inSample);



void stethFilter_NoiseCancel(float* mainBuffer, float* otherBuffer, int frames, float* outBuffer);
float stethFilter_getAppropriateGainHeart(float* buffer, long frames);

void stethFilter_copyRawSamplesForHeartGain(float *buffer, unsigned long frames);

void stethFilter_adaptHeartGain(float *rawInput, float *filteredIo, long frames);


float stethFilter_getAppropriateGainLung(float* buffer, long frames);
void stethFilter_runHeartLungGainControlOnBuffer(float* buffer, float* auxBuffer, long frames, int heartFilter); // for large buffers, mimics the live application of gain.

void stethFilter_runAutoGainCheckOnBuffer(float* buffer, float* graphicsBuffer, long frames, long heartMode); // For large buffer file read, etc - calls autoGainCheckBuffer lots
float stethFilter_autoGainCheckBuffer(float* buffer0, long frames, float targetMax); // LIVE form
void stethFilter_removeLowFrequency(float* buffer, long frames); // removes ultra low frequencies, which can affect gain - remove them as user cannot hear them anyways.


// returns the scale needed to get the loudest sample at max.
// buffer and outBuffer can be the same buffer for inplace.
double stethFilter_normalize(const float* buffer, float* outBuffer, long frames, double max); // often max = 0.9 is a good value to normalize to.
double stethFilter_calm_noise(const float* buffer, float* outBuffer, long frames); // often max = 0.9 is a good value to normalize to.

void stethFilters_setCoefficients(int useLung, double heartLowCut, double heartHighCut, double lungLowCut, double lungHighCut);
float stethFilters_filterASample(float inValue);

void stethFilter_clearAudioQueue(void);
void stethFilter_queueAudio(float *newAudio, long numSamples);

void stethFilter_resetGainControlAndDelay(void);
void stethFilters_allowGainControlToStart(void);

float* stethFilter_calculateAssociativeNoise(float* ioBuffer, long frames, float* outAverageGain); // mallocs a gain for every sample
void stethFilter_applyAssociativeNoise(float* ioBuffer, long frames, float* gainValues);

double ButterworthHP1000(double x);
double ButterworthHP600(double x);

float stethFilter_CutHighFrequencyNoise(float *buffer, long frames);

void stethFilter_addDebuggingTone(float *buffer, int numSamples, float *state, float freq, float level);
void stethFilter_addInstantaneousDebuggingTone(float *sample, float *state, float freq, float level);

//Copy samples and allow access later
void stethFilter_copySamples(float *samples, long length);
float *stethFilter_getSamplesPointer(void);
float *stethFilter_getDisplaySamplesPointer(void);

void stethFilter_lookaheadPeakLimiter(float *earlyInput, float *io, long len, float limit);
void stethFilter_lookaheadGate(float *earlyInput, float *io, long len);
void stethFilter_copyToDisplayBuffer(float *io, long len);

void setActiveNoiseCancelState(int onOff);

void initializeAudioProcessing(void);
void processAudio(float * samples, int numSamples, int isHeartMode, glsteth_filter* filter);
//void processAudioSimple(float * samples, int numSamples, int isHeartMode, glsteth_filter* filter);

void displayStatistics(float *samples, int numSamples);

// simple recording - only takes up to first 3 minutes of audio sent to it before a clear.
void recordRawAudio(float * samples, int numSamples);
void clearRecordedAudio(void);
int numSamplesRecorded(void);
float* recordedSamples(void);


void stethFilter_setProcessingSampleRate(double fs);
double stethFilter_getProcessingSampleRate(void);

//Automatic heart gain will never drop below this setting
//values of 2 to 10 are probably best
void stethFilter_setHeartMinimumGain(double setting);

//This sets the target average level for the automatic lung gain.
//levels between 0.1 and 1.0 are probably best
void stethFilter_setLungTargetLevel(double setting);

//This is the target peak level for the automatic heart gain, prior to limiting. A level greater than 1.0 is no problem,
//although by 4.0 the distortion might be audible.
//This can be set from 0.5 to 4.0, settings from 1.0 to 3.0 are probably best
void stethFilter_setHeartTargetLevel(double setting);

#endif /* defined(__Steth_io__StethAudioFilters__) */

