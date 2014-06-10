% CRISTINA RUIZ SANCHO
% HOG + SVM

function [n, det]= test_neg(path_images)
%addpath('/nobackup/server/users/criru691/HOG+SVM');
    w=3;
    
	f= fopen(strcat(path_images, 'namelist.txt'), 'r');
    n=0;
    det =0;
    for m=1:w
        while (~feof(f))
    
            name = fscanf(f,'%s', 1);
            n = n+1; 
            if(~isempty(name))
                path = strcat(path_images, name);
                im=imfinfo(path);
                
                switch(m)
                    case 1
                        r=1;
                        c=1;
                    case 2
                        r = (im.Height/2)-s/2+1;
                        c = (im.Width/2)-(s*0.5/2)+1;
                    case 3
                        r = im.Height/3;
                        c = im.Width/3;
                end
                
                s=128;
                   
                plot = 0;
                image = imread(path);
                if(plot)
                    imshow(path);
                    rectangle('Position',[c, r, s*0.5, s], 'LineWidth', 2, 'EdgeColor', 'b');
                    pause();
                end    
                [ped] = classify_region(r, c, s, image);
                       
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
    end

disp('SCANNING FINISHED')

end