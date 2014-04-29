#
#
#

#
OPENCV = -I/usr/include/opencv -lopencv_highgui -lopencv_core -lopencv_imgproc

#
#
#

output:
	$(CC) goh_extractor.c -lm -O3 -o goh_extractor
