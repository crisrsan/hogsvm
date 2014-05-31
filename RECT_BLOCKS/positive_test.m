% CRISTINA RUIZ SANCHO
% HOG + SVM

function [n, det]= positive_test(path_positives)
%addpath('/nobackup/server/users/criru691/HOG+SVM');

 
	f= fopen(strcat(path_positives, 'namelist.txt'), 'r');
    n=0;
    det =0;
    while (~feof(f))
    %for i=1:500    
        name = fscanf(f,'%s', 1);
        n = n+1; 
        if(~isempty(name))
            path = strcat(path_positives, name);
            im=imfinfo(path);
            s = 128;
            r = (im.Height/2)-s/2+1;
            c = (im.Width/2)-(s*0.5/2)+1;
            plot = 0;
            image = imread(path);
            if(plot)
                 imshow(path);
                 rectangle('Position',[c, r, s*0.5, s], 'LineWidth', 2, 'EdgeColor', 'b');
                 pause();
            end    
            
            ped = classify_region(r+round(s/2)-1, c+((s*0.5)/2)-1, s, image);
                        
            if (ped ==1)
                %PEDESTRIAN DETECTED!
                disp('Pedestrian detected!');
                
      
                det = det+1;
            else
                disp('NO pedestrians detected in this region - r -c');
            end          
         
        end
    end
	fclose(f);   


disp('SCANNING FINISHED')

end