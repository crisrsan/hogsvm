
function [T, G] = feature_extraction(fv, region, pos_info, neg_info, plot)
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
        r = (row-1)+region(1,1);
        c = (col-1)+region(1,2);
        s1 = region(1,3);
        s2 = region(1,3)*region(1,4);
        img = pos_info(k).pixels;
        I = img(r:(r+s1-1), c:(round(c+s2-1)));
        
        if(plot) 
            imshow(img);
            rectangle('Position',[col, row, size*ped_ratio, size], 'LineWidth', 1, 'EdgeColor', 'b');
            rectangle('Position', [c, r, s2, s1], 'LineWidth', 1, 'EdgeColor', 'r');
            pause()
            imshow(I)
            pause()
        end
        

        switch (region(1,4))
            case 1
                hog = extractHOGFeatures(I, 'CellSize', [floor(length(I)/2) floor(length(I)/2)]);
            case 0.5
  
                hog = extractHOGFeatures(I, 'CellSize', [floor(length(I)/2) floor(length(I)/4)]);
            case 2
                hog = extractHOGFeatures(I, 'CellSize', [floor(length(I)/4) floor(length(I)/2)]);
            otherwise
                disp('WRONG ASPECT RATIO!');
        end

        %hog = extractHOGFeatures(I, 'CellSize', [round(length(I)/2) round(length(I)/2)]);
        
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
        % Boundary box coordinates (pedestrian): row, col, size.
        row = neg_info(k).row;
        col = neg_info(k).col;
        size = neg_info(k).size;

        % Feature block coordinates: r, c, s.
        r = (row-1)+region(1,1);
        c = (col-1)+region(1,2);
        s1 = region(1,3);
        s2 = region(1,3)*region(1,4);
        img = neg_info(k).pixels;
        I = img(r:(r+s1-1), c:(round(c+s2-1)));
        
        if(plot) 
            imshow(img);
            rectangle('Position',[col, row, size*ped_ratio, size], 'LineWidth', 1, 'EdgeColor', 'b');
            rectangle('Position', [c, r, s2, s1], 'LineWidth', 1, 'EdgeColor', 'r');
            pause()
            imshow(I)
            pause()
        end
        
        switch (region(1,4))
            case 1
                hog = extractHOGFeatures(I, 'CellSize', [floor(length(I)/2) floor(length(I)/2)]);
            case 0.5
                hog = extractHOGFeatures(I, 'CellSize', [floor(length(I)/2) floor(length(I)/4)]);
            case 2
                hog = extractHOGFeatures(I, 'CellSize', [floor(length(I)/4) floor(length(I)/2)]);
            otherwise
                disp('WRONG ASPECT RATIO!')
        end
        
              
        %hog = extractHOGFeatures(I, 'CellSize', [round(length(I)/2) round(length(I)/2)]);
        
%         path_to_rid_image = strcat(path_rid, neg_info(k).filename,'.rid');
%         myCommand = ['./goh_extractor ' path_to_rid_image ' ' int2str(r) ' ' int2str(c) ' ' int2str(s)];
%         [~ , res] = system(myCommand);
%         hog = str2num(res);
        
        T ((length(pos_info)+k),:) = hog;
        G ((length(pos_info)+k),1) = 0;
     end
    
end

