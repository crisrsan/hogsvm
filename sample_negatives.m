% CRISTINA RUIZ
% Prepare NEGATIVE (background imgs) samples every time a new level of the cascade starts.

function [neg_info_out] = sample_negatives(neg_info_in)
%sample_negatives Prepare new NEGATIVE samples for the "learning" execution.
%   [neg_info] = sample_negatives (PATH_TO_NEGATIVES, W) generates a new set of negatives extracting the information needed for the "learning" stage. 
%   PATH_TO NEGATIVES is the complete path to the negatives folder, 
%	W is the generated number of negative samples per background image.
    
	
%NUMBER OF NEGATIVES = NUMBER OF POSITIVES
    disp('Preparing new negative samples (background images) ...');
  
   	neg_info_out = struct('filename', {}, 'width', {}, 'height', {}, 'row', {}, 'col', {}, 'size', {}, 'pixels', {});
    
    i=1;
    iter = 0;
    while(length(neg_info_out)<length(neg_info_in) && iter < 10)
        for j=1:length(neg_info_in)
            neg_info_out(i).filename = neg_info_in(j).filename;
            neg_info_out(i).width = neg_info_in(j).width;
            neg_info_out(i).height = neg_info_in(j).height;
            neg_info_out(i).row = round(68 + ((neg_info_out(i).height-68)-68)*rand);
            neg_info_out(i).col = round(36 + ((neg_info_out(i).width-36)-36)*rand);
            neg_info_out(i).size = 128;
            neg_info_out(i).pixels = neg_info_in(j).pixels;
            count = 0;
            while((~classify_region(neg_info_out(i).row, neg_info_out(i).col, neg_info_out(i).size, neg_info_out(i).pixels)))
                neg_info_out(i).row = round(68 + ((neg_info_out(i).height-68)-68)*rand);
                neg_info_out(i).col = round(36 + ((neg_info_out(i).width-36)-36)*rand);
                count = count+1;
                if(count>50)
                    i=i-1;
                    break;
                end
            end
            if (length(neg_info_out) >= length(neg_info_in))
                break;
            end
            i = i+1;
        end
        iter = iter+1;
    end
            
% %NO REGENERATE NEGATIVES
%     disp('Preparing new negative samples (background images) ...');
%   
%    	neg_info_out = struct('filename', {}, 'width', {}, 'height', {}, 'row', {}, 'col', {}, 'size', {}, 'pixels', {});
%     
%     i=1;
%     for j=1:length(neg_info_in)
%            
%             ped = classify_region(neg_info_in(j).row, neg_info_in(j).col, neg_info_in(j).size, neg_info_in(j).pixels);
%             if(ped)
%                 neg_info_out(i).filename = neg_info_in(j).filename;
%                 neg_info_out(i).width = neg_info_in(j).width;
%                 neg_info_out(i).height = neg_info_in(j).height;
%                 neg_info_out(i).row = neg_info_in(j).row;
%                 neg_info_out(i).col = neg_info_in(j).col;
%                 neg_info_out(i).size = neg_info_in(j).size;
%                 neg_info_out(i).pixels = neg_info_in(j).pixels;
%                 i = i+1;
%             end
%     end

end