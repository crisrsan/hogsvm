% CRISTINA RUIZ
% Prepare NEGATIVE (background imgs) samples every time a new level of the cascade starts.

function [neg_info] = sample_negatives(path_negatives, w)
%sample_negatives Prepare new NEGATIVE samples for the "learning" execution.
%   [neg_info] = sample_negatives (PATH_TO_NEGATIVES, W) generates a new set of negatives extracting the information needed for the "learning" stage. 
%   PATH_TO NEGATIVES is the complete path to the negatives folder, 
%	W is the generated number of negative samples per background image.
    
	
    disp('Preparing new negative samples (background images) from ');
    disp(path_negatives);
   	neg_info = struct('filename', {}, 'width', {}, 'height', {}, 'row', {}, 'col', {}, 'size', {});
    
    i=1;
     f = fopen(strcat(path_negatives, 'namelist.txt'), 'r');
    % Prova.txt --> test the program in a specific small set of images 
    %f = fopen(strcat(path_negatives, 'prova.txt'), 'r');
    
    while (~feof(f))
        name = fscanf(f,'%s', 1);
        if(~isempty(name))
            for j =0:(w-1) % GENERATE w TRAINING WINDOWS PER IMAGE
                 
                neg_info(i+j).filename = name;
                path = strcat(path_negatives, neg_info(i+j).filename);
                im=imfinfo(path); %Filename, Width, Heigth
                neg_info(i+j).width = im.Width;
                neg_info(i+j).height=im.Height;                
                neg_info(i+j).row = round(64 + ((im.Height-64)-64)*rand);
                neg_info(i+j).col = round(32 + ((im.Width-32)-32)*rand);
                neg_info(i+j).size = 128;
                img = imread(path); 
                while(~classify_region(neg_info(i+j).row, neg_info(i+j).col, neg_info(i+j).size, img))
                     disp('Good classification!');
                     neg_info(i+j).row = round(64 + ((im.Height-64)-64)*rand);
                     neg_info(i+j).col = round(32 + ((im.Width-32)-32)*rand);
                end
             end
		%CONVERT NEGATIVES TO .rid
		%img2rid(neg_info(i).filename, im.Filename, path_rid);
        i = i+w;
        end
    end
    fclose(f);
        
end