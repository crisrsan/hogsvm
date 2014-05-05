% CRISTINA RUIZ
% Prepare POSITIVE (pedestrian imgs) and NEGATIVE (non-pedestrian images) samples


function [neg_info, pos_info] = prepare_samples (path_negatives, path_positives, path_rid)
	
%CREATE THE COMPLETE LIST FOR NEGATIVES/POSITIVES IF IT DOESN'T EXIST (ONLY THE FIRST TIME)
% pos_dir = dir(path_positives);
% f_init = fopen(strcat(path_positives, 'list.txt'), 'w');
% for i=3:length(pos_dir)
%     if(~strcmp(pos_dir(i).name,'list.txt')) 
%             fprintf(f_init, '%s', pos_dir(i).name);
%             fprintf(f_init, '\n');
%     end
%  end
%  fclose(f_init);

neg_dir = dir(path_negatives);
f_init = fopen(strcat(path_negatives, 'list.txt'), 'w');
for i=3:length(neg_dir)
    if(~strcmp(neg_dir(i).name,'list.txt')) 
            fprintf(f_init, '%s', neg_dir(i).name);
            fprintf(f_init, '\n');
    end
 end
 fclose(f_init);

%copyfile('/nobackup/server/users/criru691/Dataset/prova_negatives.txt','/nobackup/server/users/criru691/Dataset/INRIA/negatives/prova.txt');
%copyfile('/nobackup/server/users/criru691/Dataset/prova_positives.txt','/nobackup/server/users/criru691/Dataset/INRIA/positives/inria/Train/prova.txt');

%POSITIVES%
    disp('Preparing positive samples (pedestrian images) from ');
    disp(path_positives);
	pos_info = struct('filename', {}, 'width', {}, 'height', {}, 'row', {}, 'col', {}, 'size', {});

	i=1;
	f= fopen(strcat(path_positives, 'list.txt'), 'r');
    %f = fopen(strcat(path_positives, 'prova.txt'), 'r');
    
	while (~feof(f)) %
        name = fscanf(f,'%s', 1);
        if(~isempty(name))
            pos_info(i).filename = name;
            im=imfinfo(strcat(path_positives, pos_info(i).filename));
            pos_info(i).width = im.Width;
            pos_info(i).height = im.Height;
            pos_info(i).row = fscanf(f,'%s', 1);
            pos_info(i).col = fscanf(f,'%s', 1);
            pos_info(i).size = fscanf(f,'%s', 1);
	
		%CONVERT POSITIVES TO RID
		img2rid(pos_info(i).filename, im.Filename, path_rid);
		i=i+1;
        end
	end
	fclose(f);    


%NEGATIVES%
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
                neg_info(i+j).row = 64 + ((im.Height-64)-64)*rand;
                neg_info(i+j).col = 32 + ((im.Width-32)-32)*rand;
                neg_info(i+j).size = 128;
           
            end
		%CONVERT NEGATIVES TO RID
		img2rid(neg_info(i).filename, im.Filename, path_rid);
        i = i+w;
        end
    end
    fclose(f);
    
    
end