
function [T, G] = feature_extraction(fv, region, pos_info, neg_info, path_positives, path_negatives, plot)
%feature_extraction Extracts HOG from the predifined region in all dataset
%samples and create the vector of sample annotations.
%   Detailed explanation goes here

    % PARAMETERS DEFINITION %
    ped_ratio = 0.5; % Pedestrian aspect ratio: width = ped_ratio*height
    
    % VARIABLES INITIALIZATION %
    total_samples = length(neg_info)+length(pos_info);
    T = zeros(total_samples, fv); %Training matrix: samples features
    G = zeros(total_samples, 1); %Group vector: samples annotation
 
    region
    % --------------- POSITIVES--------------- %
    disp('Extracting HOG from positives...');

    for k=1:length(pos_info)
        % ORIGINAL IMAGES - conversion from string to double must be done: %
        %row = str2double(pos_info(k).row);
        %col = str2double(pos_info(k).col);
        %size = str2double(pos_info(k).size);
       
        % Boundary box coordinates (pedestrian): row, col, size.
        row = pos_info(k).row;
        col = pos_info(k).col;
        size = pos_info(k).size;

        % Feature block coordinates: r, c, s.
        r = round(row-(size/2))+round(region(1,1)*size);
        c = round(col-(size*ped_ratio/2))+round(region(1,2)*(size*ped_ratio));
        s = round(region(1,3)*(size*ped_ratio));
        
                                          
        img = imread(pos_info(k).filename);
        I = img(round(r-round(s/2)+1):round(r+floor(s/2)), round(c-round(s/2)+1):round(c+floor(s/2)));
        
        if(plot) 
            imshow(image);
            rectangle('Position',[(col-(size*ped_ratio)/2), row-(size/2), size*ped_ratio, size], 'LineWidth', 2, 'EdgeColor', 'b');
            rectangle('Position', [(c-round(s/2)+1), r-round(s/2)+1, s, s], 'LineWidth', 1, 'EdgeColor', 'r');
            pause()
        end
        
        
     
        hog = extractHOGFeatures(I, 'CellSize', [floor(length(I)/2) floor(length(I)/2)]);
        
%         path_to_rid_image = strcat(path_rid, pos_info(k).filename,'.rid');
%         myCommand = ['./goh_extractor ' path_to_rid_image ' ' int2str(r) ' ' int2str(c) ' ' int2str(s)];
%         [~ , res] = system(myCommand);
%         hog = str2num(res); 
          
        T (k,:) = hog;
        G (k,1) = 1;
    end
    
    % --------------- NEGATIVES --------------- %
    disp('Extracting HOG from negatives...');
    for k=1:length(neg_info) 
        % Boundary box coordinates (negative region): row, col, size.
        row = neg_info(k).row;
        col = neg_info(k).col;
        size = neg_info(k).size;
       
       
        % Feature block coordinates: r, c, s.
        r = round(row-(size/2))+round(region(1,1)*size);
        c = round(col-(size*ped_ratio/2))+round(region(1,2)*(size*ped_ratio));
        s = round(region(1,3)*(size*ped_ratio));
        
                                          
        img = imread(neg_info(k).filename);
        I = img(round(r-round(s/2)+1):round(r+floor(s/2)), round(c-round(s/2)+1):round(c+floor(s/2)));
        
        if(plot) 
            imshow(image);
            rectangle('Position',[(col-(size*ped_ratio)/2), row-(size/2), size*ped_ratio, size], 'LineWidth', 2, 'EdgeColor', 'b');
            rectangle('Position', [(c-round(s/2)+1), r-round(s/2)+1, s, s], 'LineWidth', 1, 'EdgeColor', 'r');
            pause()
        end
        
              
        hog = extractHOGFeatures(I, 'CellSize', [floor(length(I)/2) floor(length(I)/2)]);
        
%         path_to_rid_image = strcat(path_rid, neg_info(k).filename,'.rid');
%         myCommand = ['./goh_extractor ' path_to_rid_image ' ' int2str(r) ' ' int2str(c) ' ' int2str(s)];
%         [~ , res] = system(myCommand);
%         hog = str2num(res);
        
        T ((length(pos_info)+k),:) = hog;
        G ((length(pos_info)+k),1) = 0;
     end
    
end

