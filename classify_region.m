function [ped] = classify_region( row, col, size, path_to_image, image)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
path_rid = '/nobackup/server/users/criru691/Dataset/INRIA/rid/';
img2rid(image, path_to_image, path_rid); 
region = zeros(1,3);
fv=54;
f = fopen('classifiers/svm_classifier.txt', 'r');
ped = 0;
res = 0;
neg = 0;

region(1,1) = str2double(fscanf(f_read,'%s', 1));

    while (~feof(f) || neg==1)
       
        region(1,2) = str2double(fscanf(f_read,'%s', 1));
        region(1,3) = str2double(fscanf(f_read,'%s', 1));
        total_samples= str2double(fscanf(f_read,'%s', 1));
        for m=1:total_samples
          for n=1:fv
                HOG(m,n) = str2double(fscanf(f_read, '%s', 1));
          end
        end
        SVM_name = fscanf(f_read, '%s', 1);
        a = str2double(fscanf(f_read, '%s', 1));
        %t = str2double(fscanf(f_read, '%s', 1));
        structSVM = load (SVM_name);
                 
        r = (row-size*0.5)+(region(1)*size);
        c = (col-size*0.2)+(region(2)*(size*0.4));
        s = region(3)*(size);
            
        path_to_rid_image = strcat(path_rid, pos_info(k).filename,'.rid');
        myCommand = ['./goh_extractor ' path_to_rid_image ' ' int2str(r) ' ' int2str(c) ' ' int2str(s)];
         
        [status, res] = system(myCommand);
        HOG = str2num(res);      
            
        weak_res = (svmclassify (structSVM.weak_svm, HOG))*a; %!!!!!!! ojuuuuuu la T varia per cada SVM - només actual ?
        res = res + weak_res;
        
        aux = str2double(fscanf(f_read, '%s', 1));
        if(aux==0)
            t = str2double(fscanf(f_read,'%s', 1));
            if (res < t) neg=1; 
            end
        else 
            region(1,1) = aux;
        end
        
    end
     
    if(neg == 0 ) ped =1;
    end
    fclose(f);
end

