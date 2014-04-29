function [ T, G ] = feature_extraction( region, pos_info, neg_info, path_rid )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
 fv = 54; % Number of D-feature vector HOG
 total_samples = length(neg_info)+length(pos_info);
 T = zeros(total_samples, fv); %Training matrix: samples features
 G = zeros(total_samples, 1); %Group vector: samples annotation
 
    for k=1:length(pos_info)
            %positives
            row = str2double(pos_info(k).row);
            col = str2double(pos_info(k).col);
            size = str2double(pos_info(k).size);
            r = (row-size*0.5)+(region(1)*size);
            c = (col-size*0.2)+(region(2)*(size*0.4));
            s = region(3)*size;
            path_to_rid_image = strcat(path_rid, pos_info(k).filename,'.rid');
            pos_info(k).filename
            myCommand = ['./goh_extractor ' path_to_rid_image ' ' int2str(r) ' ' int2str(c) ' ' int2str(s)];
            [status, res] = system(myCommand);
            hog = str2num(res); 
            T (k,:) = hog;
            G (k,1) = 1;
                      
     end
        
     for j=1:length(neg_info)
            %negatives
                
            r = region(1)* neg_info(j).height;
            c = region(2)* neg_info(j).width;
            s = region(3)* neg_info(j).height;
            path_to_rid_image = strcat(path_rid, neg_info(j).filename,'.rid');
        
            myCommand = ['./goh_extractor ' path_to_rid_image ' ' int2str(r) ' ' int2str(c) ' ' int2str(s)];
            myCommand
            [status, res] = system(myCommand);
            hog = str2num(res); 
            T ((length(pos_info)+j),:) = hog;
            G ((length(pos_info)+j),1) = 0;
        end

end

