
function [y] = img2rid(image_name, input_path, output_path )
%img2rid Converts an image to RID format.
%   y = img2rid (IMAGE_NAME, INPUT_PATH, OUTPUT_PATH) converts an image to
%   a new image in RID format. IMAGE_NAME is the source image you want to convert,
%   INPUT_PATH is the complete path to the source image location, and
%   OUTPUT_PATH is the complete path to the desired RID image location.

y=0;
%image = rgb2gray(image);
info=imfinfo(input_path);
im = imread(input_path);
filename = strcat(image_name, '.rid');

f = fopen(strcat(output_path, filename), 'w');

fwrite(f, info.Width, 'int32');
fwrite(f, info.Height, 'int32');
fwrite(f, im, 'uint8');

fclose(f);

y=1;
end

