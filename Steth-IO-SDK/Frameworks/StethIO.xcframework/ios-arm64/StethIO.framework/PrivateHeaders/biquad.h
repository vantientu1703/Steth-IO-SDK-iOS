#ifndef __Steth_io__biquad__
#define __Steth_io__biquad__
#include <math.h>

double calculateQFromOctaveWidth(double octaveWidth);
void calculateBiquadPeak(double freqC, double freqTot, double Q, double peakGain,
                        double* a0, double* a1, double* a2, double* b1, double* b2);

void calculateLP2(double freqC, double freqTot, double Q,
                  double *coeffs);

void calculateBW4Section(double freqC, double freqTot, int section,
                         double *coeffs);

void calculateHP2(double freqC, double freqTot, double Q,
                  double *coeffs);

void calculateBP2(double freqC, double freqTot, double Q,
                  double *coeffs);


//const int N = 10;
//double filterCoeffs[5 * N] = {...};
//float delays[2 * N + 2] = {0.f, 0.f, ..., 0.f};
//float input[length], output[length];

// This treat as opaque object that holds all state for a biquad filter
//------------
struct glsteth_filter {
    // coefficients.
    double* coeffs; // [5 * N]
    double* delays; // [2 * N + 2]
    int orderN;  // 0 (trivial) to kMaxOrder
    void* os_setupObj;
    
    double* soundInD;
    double* soundOutD;
    long doublesAllocated;
};
typedef struct glsteth_filter glsteth_filter;

// Create the object and keep until you are done
glsteth_filter* glsteth_filter_NEW(void);
void glsteth_filter_FREE(glsteth_filter* obj);
void glsteth_filter_OS_FREE(glsteth_filter* obj); // OS dependent. On iOS in iosDSP

// removes all filter stages.
void glsteth_filter_clear(glsteth_filter* obj);

// Create a filter, then add filters:
void glsteth_filter_addBiquad(glsteth_filter* filter, double a0, double a1, double a2, double b1, double b2);

// Call to filter a block of sound...
// NOTE: use the same filter for adjacent blocks so everything is smooth.
// ALLOWS inSound and outSound to be the same buffer, as there is a copy done internally.
void glsteth_filter_run(glsteth_filter* filter, float* inSound, float* outSound, long frames); // OS dependent. On iOS in iosDSP
void glsteth_filter_runD(glsteth_filter* obj, double* inSound, double* outSound, long frames); // OS dependent. On iOS in iosDSP

void glsteth_filter_allocateDoublesFor(glsteth_filter* filter, long frames);

// YOU MUST pass 1024 bytes of memory in, then make a platform string on the way out.
void glsteth_filter_signature(glsteth_filter* obj, char* emptyStringCap1024);


//A lightweight single biquad

enum{CUSTOM_TYPE, BIQUAD_TYPE_LP2, BIQUAD_TYPE_HP2, BIQUAD_TYPE_BW4A, BIQUAD_TYPE_BW4B, BIQUAD_TYPE_BWHP4A, BIQUAD_TYPE_BWHP4B, BIQUAD_TYPE_BANDPASS, BIQUAD_TYPE_PEAK};

typedef struct
{
    int filterType;
    float frequency;
    float level; //for peak filter
    float Q;
    double coeff[5];
    double xstate[2]; //should be zeroed
    double ystate[2]; //should be zeroed
    unsigned int index; //should be zeroed
    int designed; //should be 0
} biquadFilter_t;

void designBiquad(biquadFilter_t *filter, double freqTot);
double runBiquad(biquadFilter_t *filter, double freqTot, double xn);
void clearBiquadState(biquadFilter_t *filter);

#endif
