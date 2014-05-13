% CRISTINA RUIZ SANCHO
% HOG + SVM

function []= runtime (path_to_image, image_name)
addpath('/nobackup/server/users/criru691/HOG+SVM');

%image = imread(path_to_image);
im = imfinfo(path_to_image);

minsize = 128; %minimum window size
%maxsize = im.Height; %maximum window size
maxsize = 128;

scale_factor=1.30;
overlap_factor=0.5;
s=minsize;
% WINDOWS = 64x128.
% IMAGE SCANNING - window selection
while(s <=maxsize)

    overlap_h=64*overlap_factor;
    overlap_v=64*overlap_factor;
    
    for r=0:overlap_v:(im.Height-s)
    %for r=round(s/2):8:round(im.Height-(s/2))
        for c=0:overlap_h:(im.Width-(s*0.5))
        %for c=round(s*0.4/2):8:round(im.Width-(s*0.4/2))
            % FEATURE EXTRACTION - Window classification
            %imshow(path_to_image);
            %rectangle('Position',[c, r, s*0.4, s], 'LineWidth', 2, 'EdgeColor', 'r');
            %hold on
            %plot(c+round((s*0.4)/2),r+round(s/2),'r.','MarkerSize',20) 
            %pause()
            %ped = classify_region(r, c, s, path_to_image, image_name);
            ped = classify_region(r+round(s/2), c+((s*0.5)/2), s, path_to_image, image_name);
            
            if (ped ==1)
                %PEDESTRIAN DETECTED!
                disp('Pedestrian detected!');
                imshow(path_to_image);
                rectangle('Position',[c, r, s*0.5, s], 'LineWidth', 2, 'EdgeColor', 'b');
                pause()
            
            else
                disp('NO pedestrians detected in this region - r -c');
              
            end
        end
    end
    s = s*scale_factor;
end

disp('SCANNING FINISHED')

end