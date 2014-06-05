function [ped] = classify_region(row, col, size, img)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
disp('Classifying region... r c s');

region = zeros(1,3);
fv=36;
ped_ratio = 0.5;
h = size;
w = h*ped_ratio;
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
        
        %DESNORMALIZE BLOCK in relation to REGION
        region(1,1)=region(1,1)*h;
        region(1,2)=region(1,2)*w;
        region(1,3)=region(1,3)*w;
        
        if(size>128)
           if((region(1,3)/2) ~= 0)
               region(1,3) = region(1,3)-1;
           end
           region(1,2) = floor(region(1,2));
           region(1,1) = floor(region(1,1));
        elseif(size<128)
           if((region(1,3)/2) ~= 0)
               region(1,3) = region(1,3)-1;
           end
           region(1,2) = ceil(region(1,2));
           region(1,1) = ceil(region(1,1));
        end
        
        
        % Feature block coordinates: r, c, s.
        r = (row-1)+region(1,1);
        c = (col-1)+region(1,2);
        s = region(1,3);
 
        %Select only the image region / block we want to evaluate --> (r1:r2, c1:c2)
        I = img((r:(r+s-1)), (c:(round(c+s-1))));
                               
        plot=0;
        if(plot) 
            imshow(img);
            rectangle('Position',[col, row, size*ped_ratio, size], 'LineWidth', 1, 'EdgeColor', 'b');
            rectangle('Position', [c, r, s, s], 'LineWidth', 1, 'EdgeColor', 'r');
            pause()
            imshow(I)
            pause()
        end

        HOG = extractHOGFeatures(I, 'CellSize', [floor(length(I)/2) floor(length(I)/2)]); % 36-D vector
       %HOG = extractHOGFeatures(I, 'NumBins', 6, 'BlockSIze', [3 3], 'CellSize', [floor(length(I)/3) floor(length(I)/3)]

        weak_res = (svmclassify (structSVM.weak_svm, HOG))*a; 
        res = res + weak_res;

        aux = str2double(fscanf(file, '%s', 1));
        if(aux==999999)
            %disp('END OF STAGE');
            t = str2double(fscanf(file,'%s', 1));
            if (res < t) 
                
                neg=1; 
                break;
            else
                region(1,1) = str2double(fscanf(file,'%s', 1));
                res = 0;
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

