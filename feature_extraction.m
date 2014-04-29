function [ T, G ] = feature_extraction( region, pos_info, neg_info, path_rid )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    for k=1:length(pos_info)
            %positives
            row = str2double(pos_info(k).row);
            col = str2double(pos_info(k).col);
            size = str2double(pos_info(k).size);
            r = (row-size*0.5)+(region(1)*size);
            c = (col-size*0.2)+(region(2)*(size*0.4));
            s = region(3)*size;
            path_to_rid_image = strcat(path_rid, pos_info(k).filename,'.rid');
            
            myCommand = ['./goh_extractor ' path_to_rid_image ' ' int2str(r) ' ' int2str(c) ' ' int2str(s)];
            [status, res] = system(myCommand);
            hog = str2num(res); 
            T (k,:) = hog;
            G (k,1) = 1;
                      
     end
        
     for j=1:length(neg_info)
            %negatives
            height = str2double(neg_info(j).height);
            width = str2double(neg_info(j).width);
            
            r = region(1)* height;
            c = region(2)* width;
            s = region(3)* height;
            path_to_rid_image = strcat(path_rid, neg_info(j).filename,'.rid');
            
            myCommand = ['./goh_extractor ' path_to_rid_image ' ' int2str(r) ' ' int2str(c) ' ' int2str(s)];
            [status, res] = system(myCommand);
            hog = str2num(res); 
            T ((length(neg_info)+j),:) = hog;
            G ((length(neg_info)+j),1) = 0;
        end

end

