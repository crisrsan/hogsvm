function [ped] = classify_region( row, col, size, path_to_image, image_name, img)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
disp('Classifying region... r c s');

path_rid = '/nobackup/server/users/criru691/Dataset/INRIA/rid/';
img2rid(image_name, path_to_image, path_rid); 
region = zeros(1,3);
fv=36;
ped_ratio = 0.5;

f = fopen('/nobackup/server/users/criru691/HOG+SVM/runtime/classifiers/svm_classifier2.txt', 'r');
ped = 0;
res = 0;
neg = 0;

region(1,1) = str2double(fscanf(f,'%s', 1));

    while (~feof(f) && neg==0)
       
        region(1,2) = str2double(fscanf(f,'%s', 1));
        region(1,3) = str2double(fscanf(f,'%s', 1));
        total_samples= str2double(fscanf(f,'%s', 1));

        %HOG = zeros(total_samples, fv);

%          for m=1:total_samples
%            for n=1:fv
%                  HOG(m,n) = str2double(fscanf(f, '%s', 1));
%            end
%          end

        SVM_name = fscanf(f, '%s', 1);
        SVM_name
        a = str2double(fscanf(f, '%s', 1));
        structSVM = load (SVM_name);
                 
        r = floor((row-(size/2))+(region(1)*size));
        c = floor((col-(size*ped_ratio/2))+(region(2)*(size*ped_ratio)));
        s = floor(region(3)*(size*ped_ratio));
       
        %Select only the image region / block we want to evaluate --> (r1:r2, c1:c2)
        I = img(round(r-s/2):round(r+s/2),round(c-s/2):round(c+s/2));
        
        plot=0;
        if(plot) 
            imshow(img);
            rectangle('Position',[(col-(size*ped_ratio)/2), row-(size/2), size*ped_ratio, size], 'LineWidth', 2, 'EdgeColor', 'b');
            rectangle('Position', [(c-(s/2)), r-(s/2), s, s], 'LineWidth', 1, 'EdgeColor', 'r');
            pause()
            imshow(I)
            pause()
        end
%         path_to_rid_image = strcat(path_rid, image_name,'.rid');
%         myCommand = ['./goh_extractor ' path_to_rid_image ' ' int2str(r) ' ' int2str(c) ' ' int2str(s)];
%           
%         [status, hog] = system(myCommand);
%         HOG = str2num(hog);      
               
     
        HOG = extractHOGFeatures(I, 'CellSize', [floor(length(I)/2) floor(length(I)/2)]); % 36-D vector
       %HOG = extractHOGFeatures(I, 'NumBins', 6, 'BlockSIze', [3 3], 'CellSize', [floor(length(I)/3) floor(length(I)/3)]);
        
        
        weak_res = (svmclassify (structSVM.weak_svm, HOG))*a; 
        weak_res
      
        res = res + weak_res;
        res
        aux = str2double(fscanf(f, '%s', 1));
        if(aux==999999)
            disp('END OF STAGE');
            t = str2double(fscanf(f,'%s', 1));
            t
            if (res < t) 
                
                neg=1; 
            else
                region(1,1) = str2double(fscanf(f,'%s', 1));
            end
        else 
            region(1,1) = aux;
        end
        
    end
     
    if(neg == 0 ) 
        
        ped = 1;
    end
    neg
    ped
    fclose(f);
end

