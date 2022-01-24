// wrapper for bsd licensed kiss fft.
#ifdef __cplusplus
extern "C" {
#endif

/*
 * Will compute the power spectrum by doing an FFT with KISS, then getting the
 * sum of the squares of the real and imaginary parts.
 * Note that the output array is half the length of the
 * input array PLUS ONE, and that NumSamples must be EVEN (kiss handles non powers of two I think).
 */
 
 /*
	PowerSpectrumKiss expects YOU to add window on data if you want one
*/
void PowerSpectrumKiss(int numSamples, float *inData, float *outData);


/* applies guassian window. Max samples is only 256 (easy to raise this, though...)*/
void PowerSpectrumKissDoWindow(int numSamples, float *inData, float *outData);
void PowerSpectrumKissMultispectral(int numSamples, float *inData, float *outData);


#ifdef __cplusplus
}
#endif
