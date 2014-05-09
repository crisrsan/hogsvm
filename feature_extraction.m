
function [T, G] = feature_extraction(region, pos_info, neg_info, path_rid, path_positives, path_negatives, plot)
%feature_extraction Extracts HOG from the predifined region in all dataset
%samples and create the vector of sample annotations.
%   Detailed explanation goes here

    % PARAMETERS DEFINITION %
    fv = 54; % Number of D-feature vector HOG
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
        r = (row-(size/2))+(region(1)*size*ped_ratio);
        c = (col-(size*ped_ratio/2))+(region(2)*(size*ped_ratio));
        s = region(3)*(size*ped_ratio);

        if(plot) 
            imshow(strcat(path_positives, pos_info(k).filename));
            rectangle('Position',[(col-(size*ped_ratio)/2), row-(size/2), size*ped_ratio, size], 'LineWidth', 2, 'EdgeColor', 'b');
            rectangle('Position', [(c-(s/2)), r-(s/2), s, s], 'LineWidth', 1, 'EdgeColor', 'r');
            pause()
        end

        path_to_rid_image = strcat(path_rid, pos_info(k).filename,'.rid');
        myCommand = ['./goh_extractor ' path_to_rid_image ' ' int2str(r) ' ' int2str(c) ' ' int2str(s)];

        [~ , res] = system(myCommand);
        hog = str2num(res); 
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
        r = (row-(size/2))+(region(1)*size);
        c = (col-(size*ped_ratio/2))+(region(2)*(size*ped_ratio));
        s = region(3)*(size*ped_ratio);

        if(plot) 
            imshow(strcat(path_negatives, neg_info(k).filename));
            rectangle('Position',[(col-(size*ped_ratio)/2), row-(size/2), size*ped_ratio, size], 'LineWidth', 2, 'EdgeColor', 'b');
            rectangle('Position', [(c-(s/2)), r-s/2, s, s], 'LineWidth', 1, 'EdgeColor', 'r');
            pause()
        end

        path_to_rid_image = strcat(path_rid, neg_info(k).filename,'.rid');
        myCommand = ['./goh_extractor ' path_to_rid_image ' ' int2str(r) ' ' int2str(c) ' ' int2str(s)];

        [~ , res] = system(myCommand);
        hog = str2num(res); 
        T ((length(pos_info)+k),:) = hog;
        G ((length(pos_info)+k),1) = 0;
     end
    
end

