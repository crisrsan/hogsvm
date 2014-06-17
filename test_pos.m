% CRISTINA RUIZ SANCHO
% HOG + SVM

function [n, det, t_final, t_window]= test_pos(path_images)
%addpath('/nobackup/server/users/criru691/HOG+SVM');
    t_inici=cputime;
    t_window=0;
	f= fopen(strcat(path_images, 'namelist.txt'), 'r');
    n=0;
    det =0;
    while (~feof(f))
    %for i=1:50    
        name = fscanf(f,'%s', 1);
        
        if(~isempty(name))
		n = n+1; 
            path = strcat(path_images, name);
            im=imfinfo(path);
            s = 128;
            r = round((im.Height/2)-s/2+1);
            c = round((im.Width/2)-(s*0.5/2)+1);
           
        
            plot = 0;
            image = imread(path);
            if(plot)
                 imshow(path);
                 rectangle('Position',[c, r, s*0.5, s], 'LineWidth', 2, 'EdgeColor', 'b');
                 pause();
            end    
           
	    t1=cputime; 
            [ped] = classify_region(r, c, s, image);
	    t2=cputime-t1;
            t_window=t_window+t2; 
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
t_window=t_window/n;
t_final=cputime-t_inici;
disp('SCANNING FINISHED')

end
