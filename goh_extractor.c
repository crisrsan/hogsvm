#include <stdio.h>
#include <math.h>
#include <stdint.h>

#include <malloc.h>
#include <memory.h>

/*
	portable time function
*/

#ifdef __GNUC__
#include <time.h>
float getticks()
{
	struct timespec ts;

	if(clock_gettime(CLOCK_MONOTONIC, &ts) < 0)
	{
		printf("clock_gettime error\n");

		return -1.0f;
	}

	return ts.tv_sec + 1e-9f*ts.tv_nsec;
}
#else
#include <windows.h>
float getticks()
{
	static double freq = -1.0;
	LARGE_INTEGER lint;

	if(freq < 0.0)
	{
		if(!QueryPerformanceFrequency(&lint))
			return -1.0f;

		freq = lint.QuadPart;
	}

	if(!QueryPerformanceCounter(&lint))
		return -1.0f;

	return (float)( lint.QuadPart/freq );
}
#endif

/*
	- loads an 8-bit grey image saved in the <RID> file format
	- <RID> file contents:
		- a 32-bit signed integer w (image width)
		- a 32-bit signed integer h (image height)
		- an array of w*h unsigned bytes representing pixel intensities
*/

int loadrid(uint8_t* pixels[], int* nrows, int* ncols, const char* path)
{
	FILE* file;
	int w, h;

	// open file
	file = fopen(path, "rb");

	if(!file)
	{
		return 0;
	}

	// read width
	fread(&w, sizeof(int), 1, file);
	// read height
	fread(&h, sizeof(int), 1, file);

	// allocate image memory
	*nrows = h;
	*ncols = w;

	*pixels = (uint8_t*)malloc(w*h*sizeof(uint8_t));

	if(!*pixels)
	{
		fclose(file);

		return 0;
	}

	// read image data
	fread(*pixels, sizeof(uint8_t), w*h, file);

	// clean up
	fclose(file);

	// we're done
	return 1;
}

/*
	
*/

#include "goh.c"

/*
	
*/

int main(int argc, void* argv[])
{
	float t;

	//
	int nrows, ncols;
	uint8_t* pixels;

	int b;
	uint32_t* ibins[B];

	//
	if(argc!=5)
		return 0;

	//
	if(!loadrid(&pixels, &nrows, &ncols, argv[1]))
		return 0;

	//
	for(b=0; b<B; ++b)
		ibins[b] = (uint32_t*)malloc((nrows+1)*(ncols+1)*sizeof(uint32_t));

	//
	///t = getticks();
	get_ibins(pixels, nrows, ncols, ncols, ibins);
	///printf("%f [ms]\n", 1000.0*(getticks()-t));

	//
	int i, n;

	//scanf("%d", &n);
	n=1;
	for(i=0; i<n; ++i)
	{
		int r, c, s;

		float d[DSIZE];

		//
		//scanf("%d %d %d", &r, &c, &s);
		if (sscanf (argv[2], "%i", &r)!=1) {printf ("error");}
		if (sscanf (argv[3], "%i", &c)!=1) {printf ("error");}
		if (sscanf (argv[4], "%i", &s)!=1) {printf ("error");}
		//printf("%d %d %d\n", r, c, s);

		//
		get_descriptor(d, ibins, nrows+1, ncols+1, r, c, s);

		for(b=0; b<DSIZE-1; ++b)
			printf("%f ", d[b]);
		printf("%f\n", d[DSIZE-1]);
	}

	//
	return 0;
}
