false_pos = 0;
true_neg = 0;
false_neg = 0;
true_pos = 0;
%NEGATIVES%
n=0;
det=0;
for i=1:length(aux_neg_info)
    n=n+1;
    row = aux_neg_info(i).row;
    col = aux_neg_info(i).col;
    size = aux_neg_info(i).size;
    path= aux_neg_info(i).filename;
    img=imread(path);

    ped = classify_region( row, col, size, img);
    
    if (ped ==1)
        false_pos = false_pos +1;
    det=det+1;
    else
        true_neg = true_neg +1;
    end
end

% %POSITIVES%
% for i=1:length(pos_info)
%     row = pos_info(i).row;
%     col = pos_info(i).col;
%     size = pos_info(i).size;
%     path= strcat('/nobackup/server/users/criru691/Dataset/INRIA/train/train_pos_crop/', pos_info(i).filename);
%     img = imread(path);
%  
%     ped = classify_region( row, col, size, path, pos_info(i).filename, img);
%     if (ped ==1)
%         true_pos = true_pos +1;
%     else
%         false_neg = false_neg +1;
%     end
% end