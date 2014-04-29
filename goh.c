#ifndef MAX
#define MAX(a, b) ((a)>(b)?(a):(b))
#endif

#ifndef MIN
#define MIN(a, b) ((a)<(b)?(a):(b))
#endif

#ifndef ABS
#define ABS(x) ((x)>0?(x):(-(x)))
#endif

#define B 6

static int rotlutinit = 0;
static int rotlut[512][512];

void precompute_rotlut()
{
	int r, c;

	const float pi = 3.14159265;

	//
	if(rotlutinit)
		return;
	else
		rotlutinit = 1;

	//
	for(r=-255; r<=255; ++r)
		for(c=-255; c<=255; ++c)
		{
			int b;

			//
			if(c==0)
				b = 0;
			else
				b = (int)round( B*(atan(r/(double)c)+pi/2)/pi );

			b = MAX(0, MIN(b, B-1));

			//
			rotlut[r+255][c+255] = b; 
		}
}

int get_ibins(uint8_t img[], int nrows, int ncols, int ldim, uint32_t* ibins[])
{
	int b, m, r, c;

	//
	precompute_rotlut();

	//
	for(b=0; b<B; ++b)
		memset(ibins[b], 0, (nrows+1)*(ncols+1)*sizeof(int32_t));

	//
	for(r=1; r<nrows-1; ++r)
		for(c=1; c<ncols-1; ++c)
		{
			int gr, gc;

			//
			gr = img[(r+1)*ldim + c] - img[(r-1)*ldim + c];
			gc = img[r*ldim + (c+1)] - img[r*ldim + (c-1)];

			//
			b = rotlut[gr+255][gc+255];
			m = sqrt(gr*gr + gc*gc);

			//
			ibins[b][r*(ncols+1)+c] = m;
		}

	//
	for(b=0; b<B; ++b)
		for(r=0; r<nrows+1; ++r)
			for(c=0; c<ncols+1; ++c)
				if(r==0 && c==0)
					;
				else if(r==0)
					ibins[b][r*(ncols+1)+c] += ibins[b][r*(ncols+1)+(c-1)];
				else if(c==0)
					ibins[b][r*(ncols+1)+c] += ibins[b][(r-1)*(ncols+1)+c];
				else
					ibins[b][r*(ncols+1)+c] += ibins[b][(r-1)*(ncols+1)+c]+ibins[b][r*(ncols+1)+(c-1)]-ibins[b][(r-1)*(ncols+1)+(c-1)];

	//
	///for(b=0; b<B; ++b) printf("%d ", ibins[b][nrows*(ncols+1)+ncols]); printf("\n");

	//
	return 1;
}

int get_area_sum(uint32_t sat[], int m, int n, int r, int c, int sr, int sc)
{
	int r1, c1, r2, c2;

	//
	r1 = MIN(MAX(0, r - sr/2), m-1);
	c1 = MIN(MAX(0, c - sc/2), n-1);
	r2 = MIN(MAX(0, r + sr/2), m-1);
	c2 = MIN(MAX(0, c + sc/2), n-1);

	//
	return sat[r1*n+c1] - sat[r1*n+c2] - sat[r2*n+c1] + sat[r2*n+c2];
}

void extract_gradient_orientation_histogram(uint32_t h[], uint32_t* ibins[], int m, int n, int r, int c, int sr, int sc)
{
	int b;

	for(b=0; b<B; ++b)
		h[b] = get_area_sum(ibins[b], m, n, r, c, sr, sc);
}

#ifndef G
#define G 3
#endif

#define DSIZE G*G*B

void get_descriptor(float d[], uint32_t* ibins[], int nrows, int ncols, int r, int c, int s)
{
	int i, j;

	uint32_t id[DSIZE], l1norm;

	//
	for(i=0; i<G; ++i)
		for(j=0; j<G; ++j)
			extract_gradient_orientation_histogram(&id[(i*G+j)*B], ibins, nrows, ncols, r-s/2+i*s/G, c-s/2+j*s/G, s/G, s/G);

	//
	l1norm = 0;

	for(i=0; i<DSIZE; ++i)
		l1norm += id[i];

	//
	for(i=0; i<DSIZE; ++i)
		d[i] = id[i]/(float)(l1norm+1);
}