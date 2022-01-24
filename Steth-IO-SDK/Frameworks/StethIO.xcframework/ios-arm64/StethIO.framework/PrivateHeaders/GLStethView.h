//
//  GLStethView.h
//  Steth.io
//
//  Created by Tom Andersen on 2015/1/20.
//  Copyright (c) 2015 Strato Scientific. All rights reserved.
//

#ifndef __Steth_io__GLStethView__
#define __Steth_io__GLStethView__

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>
#include <OpenGLES/ES2/gl.h>

extern const long kMaxSoundSamplesToStore; // Max data points that we can store. When full we refuse to store more

#define LUNG_USE_HF_LINE 0

// Float point
// CGPoints are two doubles, where we use a lot of floats
struct FloatPoint
{
    float x;
    float y;
};
typedef struct FloatPoint  FloatPoint;

struct SVertex
{
GLubyte r; GLubyte g; GLubyte b; GLubyte a; GLfloat x; GLfloat y;
};
typedef struct SVertex  SVertex;


typedef struct glsteth_obj glsteth_obj;

extern long gLoopingIndex;
extern const float kMaxDisplayFrequencyLung;
extern const float kMaxDisplayFrequencyHeart;
extern const long kMaxSecondsToStoreInFile;

// Create the object and keep until you are done
glsteth_obj* glsteth_NEW(void);
void glsteth_FREE(glsteth_obj* obj);

void gl_steth_set_dsplay_frequency(glsteth_obj* obj, double displayMaxFrequencyHz);

// CALL ONCE and once only per draw
void glsteth_prepare_to_draw(glsteth_obj* obj);
void glsteth_sync_to_main_thread(glsteth_obj* obj); // call on main thread after loading sound. 

// returns end time in seconds when ready to draw.
double glsteth_getEndTime(glsteth_obj* obj);
double glsteth_getStartTime(glsteth_obj* obj);
double glsteth_normalizedWindowX(glsteth_obj* obj, double cursorTime, double windowWidthSeconds, double windowEndTime);

// retrieve sound data main thread - malloc called so free() on returned samples, please
float* glsteth_mallocSamples(glsteth_obj* obj, double startTime, double endTime, long* outSampleCount);
long glsteth_getNumSamples(glsteth_obj* obj);


// drawing basics, erase, etc.
void glsteth_setBackground(glsteth_obj* obj, GLboolean whiteBackground);
void glsteth_setViewPort(glsteth_obj* obj, long backingWidth, long backingHeight);
void glsteth_clearBuffer(glsteth_obj* obj);
void glsteth_setVerticalZoom(glsteth_obj* obj, float inVerticalZoom);


// Drawing the power spectrum
void glsteth_renderPowerSpectrumColours(glsteth_obj* obj, double startTime, double endTime, int useLung);
void glsteth_drawPowerLine(glsteth_obj* obj, double startTime, double endTime);
void glsteth_drawSignalLine(glsteth_obj* obj, double startTime, double endTime);

// SLOW call to get the screen in a CSV file
// outLength includes the null byte at the end.
char* glsteth_mallocPowerSpectrumToXYZRGBCSV(glsteth_obj* obj, double startTime, double endTime, long* outLength, int useLung);

double* glsteth_calculateMeasures(glsteth_obj* obj, double startTime, double endTime, long* numMeasures);


void glsteth_drawCursor(glsteth_obj* obj, double cursorTime, double windowWidthSeconds, double windowEndTime, double bottom, double top);
void glsteth_upperLeftIndicator(glsteth_obj* obj, GLfloat offset);
void glsteth_drawCursorWhilePlayingSound(glsteth_obj* obj, double windowWidthSeconds, double windowEndTime, double audioLatency);

// Draw the pulse line...
void glsteth_drawBeatLine(glsteth_obj* obj, double startTime, double endTime, float* downsampledBuffer, int bufferCount, float downSampleFactor);
void glsteth_setCompressBaselineNoise(glsteth_obj* obj, GLboolean compressBaselineNoise);
GLboolean glsteth_getCompressBaselineNoise(glsteth_obj* obj);
void glsteth_setShowPowerPlotAsFilledIn(glsteth_obj* obj, GLboolean showPowerPlotAsFilledIn);
GLboolean glsteth_getShowPowerPlotAsFilledIn(glsteth_obj* obj);

// adding/setting sound data to display (not listen to)
// SOUND is ASSUMED kAudioFrequencyExact Hz, mono
// Time is 0 at the start of the buffer and the number of samples stored in total implies the total time stored.
void glsteth_emptySoundBuffer(glsteth_obj* obj);
void glsteth_addToSoundBuffer(glsteth_obj* obj, float* samples, float* graphSamples, long newCount, long useHeart);

void glsteth_addToSampleBuffer(glsteth_obj* obj, float* samples,long newCount, long useHeart); //



uint32_t glsteth_interpolatedRGBAPremultipliedPixel(glsteth_obj* obj, double inAtTime, double inY, int useLung);

float* glsteth_powerLineData(glsteth_obj* obj, long* outNumPoints, double* ioStartSeconds, double* ioEndSeconds, float inViewWidth);
float* glsteth_powerLineDataNoCache(glsteth_obj* obj, long* outNumPoints, double* ioStartSeconds, double* ioEndSeconds, float inViewWidth, GLfloat** outHighFreqPoints, int doScale);
void glsteth_powerLineDataSetScale(glsteth_obj* obj, long* outNumPoints, double* ioStartSeconds, double* ioEndSeconds, float inViewWidth, GLboolean oneAndDone); // call on load from file to set scale on entire file.
float* glsteth_signalLineData(glsteth_obj* obj, long* outNumPoints, double* ioStartSeconds, double* ioEndSeconds, float inViewWidth);
float* glsteth_normalizedSignalHighestValueXY(glsteth_obj* obj, double startSeconds, double plusMinus);

SVertex* glsteth_mallocLineIntoTriangleStripWithColour(glsteth_obj* obj, GLfloat* drawPoints, long* numPoints, double startTime, double endTime, GLfloat* outMinY);


void glsteth_findSmoothEnvelope(glsteth_obj* obj);

double* findTransitionPairs(glsteth_obj* obj, float* drawPoints, long numPoints, double startTime, double endTime, long* numMeasures);

#endif /* defined(__Steth_io__GLStethView__) */
