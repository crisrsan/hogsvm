% CRISTINA RUIZ
% Prepare POSITIVE (pedestrian imgs) and NEGATIVE (non-pedestrian images) samples


function [neg_info, pos_info] = prepare_samples (path_negatives, path_positives, path_rid)
	
  
	
   %CREATE THE LIST FOR NEGATIVES/POSITIVES IF IT DOESN'T EXIST (ONLY THE FIRST TIME)
%   neg_dir = dir(path_negatives);
%   f = fopen(strcat(path_negatives, 'list.txt'), 'w');
%     for i=3:length(neg_dir)
%         if(~strcmp(neg_dir(i).name,'list.txt')) 
%             fprintf(f, '%s', neg_dir(i).name);
%             fprintf(f, '\n');
%         end
%     end
%     fclose(f);
    

    %NEGATIVES%
   	neg_info = struct('filename', {}, 'width', {}, 'height', {}, 'row', {}, 'col', {}, 'size', {});

    i=1;
    f = fopen(strcat(path_negatives, 'list.txt'), 'r');
	while(~feof(f))
        name = fscanf(f,'%s', 1);
        name
        if(~isempty(name))
            neg_info(i).filename = name;
            im=imfinfo(strcat(path_negatives, neg_info(i).filename)); %Filename, Width, Heigth
            neg_info(i).width = im.Width;
            neg_info(i).height=im.Height;
            neg_info(i).row = 0;
            neg_info(i).col = 0;
            neg_info(i).size = 0;
		%CONVERT NEGATIVES TO RID
		img2rid(neg_info(i).filename, im.Filename, path_rid);
        i = i+1;
        end
    end

    %POSITIVES%
	pos_info = struct('filename', {}, 'width', {}, 'height', {}, 'row', {}, 'col', {}, 'size', {});

	i=1;
	f= fopen(strcat(path_positives, 'list.txt'), 'r');
	while (~feof(f)) % !!! ERROR AL ACCEDIR A ÚLTIMA IMATGE, PERQUÉ ESTÁ EN BLANC!
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


end