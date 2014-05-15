% CRISTINA RUIZ SANCHO
% HOG + SVM

function [n]= runtime (path_to_image, image_name)
%addpath('/nobackup/server/users/criru691/HOG+SVM');
%Function that avoids reading the HOG every time - creating a new
%svm_classifier2.txt
%prepare_class();

%image = imread(path_to_image);
im = imfinfo(path_to_image);
image = imread(path_to_image);
minsize = 128; %minimum window size
%maxsize = im.Height; %maximum window size
maxsize = 128;

scale_factor=1.20;
overlap_factor=0.5;
s=minsize;
% WINDOWS = 64x128.
% IMAGE SCANNING - window selection
n = 0;
imshow(path_to_image);
hold on
while(s <=maxsize)

    overlap_h=64*overlap_factor;
    overlap_v=64*overlap_factor;
    
    for r=1:overlap_v:(im.Height-s+1)

        for c=1:overlap_h:(im.Width-(s*0.5)+1)
      
            % FEATURE EXTRACTION - Window classification
            %imshow(path_to_image);
            %rectangle('Position',[c, r, s*0.4, s], 'LineWidth', 2, 'EdgeColor', 'r');
            %hold on
            %plot(c+round((s*0.4)/2),r+round(s/2),'r.','MarkerSize',20) 
            %pause()
            %ped = classify_region(r, c, s, path_to_image, image_name);
            ped = classify_region(r+round(s/2), c+((s*0.5)/2), s, path_to_image, image_name, image);
            
            if (ped ==1)
                %PEDESTRIAN DETECTED!
                disp('Pedestrian detected!');
                rectangle('Position',[c, r, s*0.5, s], 'LineWidth', 2, 'EdgeColor', 'b');
                %pause()
                hold on
            n = n+1;
            else
                disp('NO pedestrians detected in this region - r -c');
              
            end
        end
    end
    s = s*scale_factor;
end

disp('SCANNING FINISHED')

end