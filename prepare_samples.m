
function [neg_info, pos_info] = prepare_samples (path_negatives, path_positives, path_rid)
%prepare_samples Prepare POSITIVE and NEGATIVE samples for the "learning" execution.
%   [neg_info, pos_info] = prepare_samples (PATH_TO_NEGATIVES,
%   PATH_TO_POSITIVES, PATH_TO_RID) extracts information from the dataset needed for the "learning" stage. 
%   PATH_TO NEGATIVES is the complete path to the negatives folder, 
%   PATH_TO_POSITIVES is the complete path to the positives folder, 
%   PATH_TO_RID is the complete path to the desired RID images location. 
	
    
    % Create a file (namelist.txt) with the complete list of names from the available negatives/positives image set.
    pos_dir = dir(path_positives);
    f_init = fopen(strcat(path_positives, 'namelist.txt'), 'w');
    for i=3:length(pos_dir)
        if(~strcmp(pos_dir(i).name,'namelist.txt') && ~strcmp(pos_dir(i).name,'list.txt')) 
            fprintf(f_init, '%s', pos_dir(i).name);
            fprintf(f_init, '\n');
        end
    end
    fclose(f_init);

    neg_dir = dir(path_negatives);
    f_init = fopen(strcat(path_negatives, 'namelist.txt'), 'w');
    for i=3:length(neg_dir)
        if(~strcmp(neg_dir(i).name,'namelist.txt') && ~strcmp(pos_dir(i).name,'list.txt')) 
            fprintf(f_init, '%s', neg_dir(i).name);
            fprintf(f_init, '\n');
        end
    end
    fclose(f_init);


    % Create a file (prova.txt) to test the program in a specific small set of
    % images (prova_negatives.txt / prova_positives.txt)
    %copyfile('/nobackup/server/users/criru691/Dataset/INRIA/train/prova_negatives.txt','/nobackup/server/users/criru691/Dataset/INRIA/train/train_negatives/prova.txt');
    %copyfile('/nobackup/server/users/criru691/Dataset/INRIA/train/prova_positives.txt','/nobackup/server/users/criru691/Dataset/INRIA/train/train_positives/prova.txt');



% We can work with ORIGINAL POSITIVES (train_positives) & list.txt (name r c s), 
% or with CROP POSITIVES (train_crop_positives) & namelist.txt (name).
% The region of interest specified in the list of ORIGINAL POSITIVES is more accurate, 
% but work with fixed size regions from CROPPED POSITIVES could improve computation cost. 

%     % ---------------ORIGINAL POSITIVES--------------- %
%     disp('Preparing positive samples (pedestrian images) from ');
%     disp(path_positives);
% 	pos_info = struct('filename', {}, 'width', {}, 'height', {}, 'row', {}, 'col', {}, 'size', {});
% 
% 	i=1;
% 	f= fopen(strcat(path_positives, 'list.txt'), 'r');
%     %f = fopen(strcat(path_positives, 'prova.txt'), 'r');
%     
% 	while (~feof(f)) %
%         name = fscanf(f,'%s', 1);
%         if(~isempty(name))
%             pos_info(i).filename = name;
%             im=imfinfo(strcat(path_positives, pos_info(i).filename));
%             pos_info(i).width = im.Width;
%             pos_info(i).height = im.Height;
%             pos_info(i).row = fscanf(f,'%s', 1);
%             pos_info(i).col = fscanf(f,'%s', 1);
%             pos_info(i).size = fscanf(f,'%s', 1);
% 	
%             %CONVERT POSITIVES TO RID
%             img2rid(pos_info(i).filename, im.Filename, path_rid);
%             i=i+1;
%         end
% 	end
% 	fclose(f);    


    % --------------- CROPPED POSITIVES--------------- %
    % 96x160pixels images, with a centered 64x128 pedestrian region.    
    disp('Preparing positive samples (pedestrian images) from ');
    disp(path_positives);
	pos_info = struct('filename', {}, 'width', {}, 'height', {}, 'row', {}, 'col', {}, 'size', {});

	i=1;
	f= fopen(strcat(path_positives, 'namelist.txt'), 'r');
    %f = fopen(strcat(path_positives, 'prova.txt'), 'r');
    
	while (~feof(f)) %
        name = fscanf(f,'%s', 1);
        if(~isempty(name))
            pos_info(i).filename = name;
            im=imfinfo(strcat(path_positives, pos_info(i).filename));
            pos_info(i).width = im.Width;
            pos_info(i).height = im.Height;
            pos_info(i).row = im.Height/2;
            pos_info(i).col = im.Width/2;
            pos_info(i).size = 128;
	
            %CONVERT POSITIVES TO .rid
            img2rid(pos_info(i).filename, im.Filename, path_rid);
            i=i+1;
        end
	end
	fclose(f);   



    % --------------- NEGATIVES --------------- %
    disp('Preparing negative samples (background images) from ');
    disp(path_negatives);
   	neg_info = struct('filename', {}, 'width', {}, 'height', {}, 'row', {}, 'col', {}, 'size', {});
    
    w = 3; % Number of windows per negative image
    i=1;
    f = fopen(strcat(path_negatives, 'list.txt'), 'r');
    %f = fopen(strcat(path_negatives, 'prova.txt'), 'r');
    
	while(~feof(f))
        name = fscanf(f,'%s', 1);
        if(~isempty(name))
            for j =0:(w-1) % GENERATE 3 TRAINING WINDOWS PER IMAGE
                
                neg_info(i+j).filename = name;
                im=imfinfo(strcat(path_negatives, neg_info(i+j).filename)); %Filename, Width, Heigth
                neg_info(i+j).width = im.Width;
                neg_info(i+j).height=im.Height;                
                neg_info(i+j).row = round(64 + ((im.Height-64)-64)*rand);
                neg_info(i+j).col = round(32 + ((im.Width-32)-32)*rand);
                neg_info(i+j).size = 128;
           
            end
		%CONVERT NEGATIVES TO .rid
		img2rid(neg_info(i).filename, im.Filename, path_rid);
        i = i+w;
        end
    end
    fclose(f);
        
end