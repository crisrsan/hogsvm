% CRISTINA RUIZ SANCHO
% HOG + SVM

function []= runtime (path_to_image)

minsize %minimum window size
maxsixe %maximum window size
%image = imread(path_to_image);
im = imfinfo(path_to_image);
s=minsize;
% WINDOS = 64x128.
% IMAGE SCANNING - window selection
while(s <=maxsize)
    for r=round(s/2):8:round(im.Height-(s/2))
        for c=round(s*0.4/2):8:round(im.Width-(s*0.4/2))
            % FEATURE EXTRACTION - Window classification
            ped = classify_region(r, c, s, path_to_image, im.filename);
            if (ped ==1)
                %PEDESTRIAN DETECTED!
                imshow(path_to_image);
                rectangle('Position',[(c, r, s*0.4, s], 'LineWidth', 2, 'EdgeColor', 'b');
            end
        end
    end
end


end