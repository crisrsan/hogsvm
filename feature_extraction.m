function [ T, G, region ] = feature_extraction(pos_info, neg_info, path_rid, path_positives, path_negatives, plot)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
 fv = 54; % Number of D-feature vector HOG
 total_samples = length(neg_info)+length(pos_info);
 T = zeros(total_samples, fv); %Training matrix: samples features
 G = zeros(total_samples, 1); %Group vector: samples annotation
 
 
 % GENERATE REGION - BLOCK RANDOMLY  
 region = zeros(1,3); % Maybe the size of the blocks should be always the same??
 region(1,1) = rand; %ROW
 region(1,2) = rand; %COLUMN
 
 
 if ((region(1)<0.5) && (region(2) <0.5)) %2n quadrant
    b= min(region(1),region(2));
    
 elseif ((region(1)<0.5) && (region(2)>0.5)) %1r quadrant
    b = min(region(1),(1-region(2)));
    
 elseif ((region(1)>0.5) && (region(2)<0.5)) % 3r quadrant
    b = min((1-region(1)),region(2));
    
 else %4rt quadrant
    b = min((1-region(1)),(1-region(2)));
 end
 a = 0.1;
 region(1,3) = a + (b-a)*rand;
 
 region
 disp('Extracting HOG from positives...');
    for k=1:length(pos_info)
            %positives
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
     for j=1:length(neg_info)
            %negatives
            r = region(1)* neg_info(j).height;
            c = region(2)* neg_info(j).width;
            s = region(3)* neg_info(j).height;
            path_to_rid_image = strcat(path_rid, neg_info(j).filename,'.rid');
            myCommand = ['./goh_extractor ' path_to_rid_image ' ' int2str(r) ' ' int2str(c) ' ' int2str(s)];
                            
            if(plot) 
                imshow(strcat(path_negatives, neg_info(j).filename));
                %rectangle('Position',[(col-(size*0.4)/2), row-(size/2), size*0.4, size], 'LineWidth', 2, 'EdgeColor', 'b');
                rectangle('Position', [(c-(s/2)), r-s/2, s, s], 'LineWidth', 1, 'EdgeColor', 'r');
                pause()
            end
            
            [status, res] = system(myCommand);
            hog = str2num(res); 
            T ((length(pos_info)+j),:) = hog;
            G ((length(pos_info)+j),1) = 0;
        end

end

