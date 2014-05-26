function [ped] = classify_region( row, col, size, img)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
disp('Classifying region... r c s');

region = zeros(1,3);
fv=36;
ped_ratio = 0.5;

file = fopen('classifiers/svm_classifier.txt', 'r');
ped = 0;
res = 0;
neg = 0;

region(1,1) = str2double(fscanf(file,'%s', 1));

    while (~feof(file) && neg==0)
       
        region(1,2) = str2double(fscanf(file,'%s', 1));
        region(1,3) = str2double(fscanf(file,'%s', 1));
        %total_samples= str2double(fscanf(file,'%s', 1));

        SVM_name = fscanf(file, '%s', 1);
        a = str2double(fscanf(file, '%s', 1));
        structSVM = load (SVM_name);
        
        % Feature block coordinates: r, c, s.
        r = round(row-(size/2))+round(region(1,1)*size);
        c = round(col-(size*ped_ratio/2))+round(region(1,2)*(size*ped_ratio));
        s = round(region(1,3)*(size*ped_ratio));
        
     
        %Select only the image region / block we want to evaluate --> (r1:r2, c1:c2)
        I = img(round(r-round(s/2)+1):round(r+floor(s/2)), round(c-round(s/2)+1):round(c+floor(s/2)));
                
        plot=0;
        if(plot) 
            imshow(img);
            rectangle('Position',[(col-(size*ped_ratio)/2), row-(size/2), size*ped_ratio, size], 'LineWidth', 2, 'EdgeColor', 'b');
            rectangle('Position', [(c-round(s/2)+1), r-round(s/2)+1, s, s], 'LineWidth', 1, 'EdgeColor', 'r');
            pause()
            imshow(I)
            pause()
        end
    
             
     
        HOG = extractHOGFeatures(I, 'CellSize', [floor(length(I)/2) floor(length(I)/2)]); % 36-D vector
       %HOG = extractHOGFeatures(I, 'NumBins', 6, 'BlockSIze', [3 3], 'CellSize', [floor(length(I)/3) floor(length(I)/3)]);
        
        
        weak_res = (svmclassify (structSVM.weak_svm, HOG))*a; 
        res = res + weak_res;

        aux = str2double(fscanf(file, '%s', 1));
        if(aux==999999)
            disp('END OF STAGE');
            t = str2double(fscanf(file,'%s', 1));
            if (res < t) 
                
                neg=1; 
            else
                region(1,1) = str2double(fscanf(file,'%s', 1));
            end
        else 
            region(1,1) = aux;
        end
        
    end
     
    if(neg == 0 ) 
        
        ped = 1;
    end
    fclose(file);
end
