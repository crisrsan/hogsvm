% CRISTINA RUIZ SANCHO
% HOG + SVM

function [n,det]= runtime (path_to_image)
%addpath('/nobackup/server/users/criru691/HOG+SVM');


%image = imread(path_to_image);
im = imfinfo(path_to_image);
image = imread(path_to_image);
minsize = 184; %minimum window size
maxsize = im.Height; %maximum window size
maxsize = minsize;

scale_factor=1.20;
overlap_factor=0.5;
s=minsize;
% WINDOWS = 64x128.
% IMAGE SCANNING - window selection
n = 0;
det=0;
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
            n=n+1;
            r
            c
            s
            ped = classify_region(r+round(s/2)-1, c+(round(s*0.5/2))-1, s, image);
            
            if (ped ==1)
                %PEDESTRIAN DETECTED!
                %disp('Pedestrian detected!');
                rectangle('Position',[c, r, s*0.5, s], 'LineWidth', 2, 'EdgeColor', 'b');
                %pause()
                hold on
            det = det+1;
            else
                %disp('NO pedestrians detected in this region - r -c');
              
            end
        end
    end
    
    s = round(s*scale_factor);
end

disp('SCANNING FINISHED')

end