function [T, G] = feature_extraction(region, pos_info, neg_info, path_rid, path_positives, path_negatives, plot)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
 fv = 54; % Number of D-feature vector HOG

 total_samples = length(neg_info)+length(pos_info);
 T = zeros(total_samples, fv); %Training matrix: samples features
 G = zeros(total_samples, 1); %Group vector: samples annotation
 
 
 region
 disp('Extracting HOG from positives...');
    for k=1:length(pos_info)
            row = str2double(pos_info(k).row);
            col = str2double(pos_info(k).col);
            size = str2double(pos_info(k).size);
            r = (row-size*0.5)+(region(1)*size);
            c = (col-size*0.2)+(region(2)*(size*0.4));
            s = region(3)*(size);
                        
            if(plot) 
                imshow(strcat(path_positives, pos_info(k).filename));
                rectangle('Position',[(col-(size*0.4)/2), row-(size/2), size*0.4, size], 'LineWidth', 2, 'EdgeColor', 'b');
                rectangle('Position', [(c-(s/2)), r-s/2, s, s], 'LineWidth', 1, 'EdgeColor', 'r');
                pause()
            end
            
            path_to_rid_image = strcat(path_rid, pos_info(k).filename,'.rid');
            myCommand = ['./goh_extractor ' path_to_rid_image ' ' int2str(r) ' ' int2str(c) ' ' int2str(s)];
         
            [status, res] = system(myCommand);
            hog = str2num(res); 
            T (k,:) = hog;
            G (k,1) = 1;
                      
    end
    
  disp('Extracting HOG from negatives...');
    for k=1:length(neg_info)
            %negatives
            row = neg_info(k).row;
            col = neg_info(k).col;
            size = neg_info(k).size;
            r = (row-size*0.5)+(region(1)*size);
            c = (col-size*0.2)+(region(2)*(size*0.4));
            s = region(3)*(size);
                        
            if(plot) 
                imshow(strcat(path_negatives, neg_info(k).filename));
                rectangle('Position',[(col-(size*0.4)/2), row-(size/2), size*0.4, size], 'LineWidth', 2, 'EdgeColor', 'b');
                rectangle('Position', [(c-(s/2)), r-s/2, s, s], 'LineWidth', 1, 'EdgeColor', 'r');
                pause()
            end
            
            path_to_rid_image = strcat(path_rid, neg_info(k).filename,'.rid');
            myCommand = ['./goh_extractor ' path_to_rid_image ' ' int2str(r) ' ' int2str(c) ' ' int2str(s)];
            
            [status, res] = system(myCommand);
            hog = str2num(res); 
            T ((length(pos_info)+k),:) = hog;
            G ((length(pos_info)+k),1) = 0;
     end
    
%  disp('Extracting HOG from positives...');
%     for k=1:length(pos_info)
%             %positives
%             row = str2double(pos_info(k).row);
%             col = str2double(pos_info(k).col);
%             size = str2double(pos_info(k).size);
%             r = (row-size*0.5)+(region(1)*size);
%             c = (col-size*0.2)+(region(2)*(size*0.4));
%             s = region(3)*(size);
%                         
%             if(plot) 
%                 imshow(strcat(path_positives, pos_info(k).filename));
%                 rectangle('Position',[(col-(size*0.4)/2), row-(size/2), size*0.4, size], 'LineWidth', 2, 'EdgeColor', 'b');
%                 rectangle('Position', [(c-(s/2)), r-s/2, s, s], 'LineWidth', 1, 'EdgeColor', 'r');
%                 pause()
%             end
%             
%             path_to_rid_image = strcat(path_rid, pos_info(k).filename,'.rid');
%             myCommand = ['./goh_extractor ' path_to_rid_image ' ' int2str(r) ' ' int2str(c) ' ' int2str(s)];
%          
%             [status, res] = system(myCommand);
%             hog = str2num(res); 
%             T (k,:) = hog;
%             G (k,1) = 1;
%                       
%     end
  
%  disp('Extracting HOG from negatives...');
%      for j=1:length(neg_info)
%             %negatives
%             r = region(1)* neg_info(j).height;
%             c = region(2)* neg_info(j).width;
%             s = region(3)* neg_info(j).height;
%             path_to_rid_image = strcat(path_rid, neg_info(j).filename,'.rid');
%             myCommand = ['./goh_extractor ' path_to_rid_image ' ' int2str(r) ' ' int2str(c) ' ' int2str(s)];
%                             
%             if(plot) 
%                 imshow(strcat(path_negatives, neg_info(j).filename));
%                 %rectangle('Position',[(col-(size*0.4)/2), row-(size/2), size*0.4, size], 'LineWidth', 2, 'EdgeColor', 'b');
%                 rectangle('Position', [(c-(s/2)), r-s/2, s, s], 'LineWidth', 1, 'EdgeColor', 'r');
%                 pause()
%             end
%             
%             [status, res] = system(myCommand);
%             hog = str2num(res); 
%             T ((length(pos_info)+j),:) = hog;
%             G ((length(pos_info)+j),1) = 0;
%         end

end

