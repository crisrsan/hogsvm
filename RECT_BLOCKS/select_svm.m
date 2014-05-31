
function [svm_weak, feature, alpha, W_out, T_out, G_out] = select_svm(fv, N, neg_info, pos_info, path_positives, path_negatives, W_in)
%select_svm Selects the SVM/classifer from a set of N SVMs/classifiers that best (low error) 
%separates the binary dataset (neg_info and pos_info).
%   [svm_weak, feature, alpha, W_out, T_out, G_out] = select_svm(NEG_INFO,
%   POS_INFO, PATH_TO_RID, PATH_TO_POSITIVES, PATH_TO_NEGATIVES, WEIGTHS)
  

    % VARIABLES INITIALIZATION %
    error=inf;
    total_samples = length(neg_info)+length(pos_info);
    W_out = zeros(total_samples, 1);
    T_out = zeros(total_samples, fv); %Training matrix: samples features
    G_out = zeros(total_samples, 1); %Group vector: samples annotation
    e = zeros(total_samples, 1);
    feature = zeros(1,3);
    
    % NORMALIZE WEIGTHS %
    W_in = W_in/sum(W_in);
    
    % REGION GENERATION PARAMETERS%
    ped_ratio = 0.5;
    height = 128;
    width = height*ped_ratio;  
    
    block_ratio =  [1, 0.5, 2];
    
	for i=1:N
        
        % GENERATE NORMALIZED REGION - BLOCK RANDOMLY % 
        % The size of the blocks is picked randomly among a fixed set 
        % (from 12x12 to 64x64)... and then generate random position,
        % row and column according to image boundaries. 
        region = zeros(1,4); 
        region(1,4) = block_ratio(round(1 + (3-1)*rand)); % Select block aspect ratio
        
        switch (region(1,4))
            case 1
                a = 12;
                b = width; %64
            case 0.5
                a = 12;
                b = height; %128
            case 2
                a = 12;
                b = width/2; %32
            otherwise
        end
     
        region(1,3) = round(a + (b-a)*rand);
        
         %COL
        min = region(1,3)*region(1,4)/2;
        max = width - (region(1,3)*region(1,4)/2);
        region(1,2) = round(min + (max-min)*rand);
        %ROW
        min = region(1,3)/2;
        max = height - (region(1,3)/2);
        region(1,1) = round(min + (max-min)*rand);
        
        region(1,3) = region(1,3)/(height);
        region(1,1) = region(1,1)/(height);
        region(1,2) = region(1,2)/(width);
        
  
        
        % HOG EXTRACTION %
        [T, G]=feature_extraction(fv, region, pos_info, neg_info, path_positives, path_negatives, 0);
           
        
    	% TRAIN SVM (svmtrain) %
        disp('Training linear SVM..');
        options.MaxIter = inf;
        try
            svm = svmtrain(T,G, 'Options', options);
            %svm = svmtrain(T,G);
        catch
            disp('ERROR: Not possible to find convergence.');
            continue
        end
        cputime
   		% ERROR CALCULATION (svmclassify) - AdaBoost algorithm %
		res = svmclassify (svm, T);
        tmp_error=0;
        tmp_e = zeros (total_samples, 1);
        for l=1:total_samples
            tmp_e(l,1) = abs(res(l,1) - G(l,1));
            tmp_error = tmp_error + W_in(l,1)*tmp_e(l,1);
        end
        tmp_error
        error
		% BEST SVM SELECTION - Comparison with previous SVMs/store results %
		if (tmp_error <= error) 
            error = tmp_error;
            e = tmp_e;
            svm_weak = svm; 
            feature = region;
            T_out=T;
            G_out=G;
        end
        if(error == 0)
            break;
        end
	end
	feature
        
    % UPDATE WEIGHTS %
    switch error
        case inf % No SVM converged
            feature = 0;
            svm_weak = 0;
            alpha = 0;
            T_out = 0;
            G_out = 0;
            W_out = W_in;
        case 0 % Ideal classification - special case.
            beta = 0;
            alpha = 1;
            W_out = W_in;
        otherwise
            beta = error/(1-error);
            alpha = log(1/beta);
            for i=1:total_samples
                W_out(i,1) = W_in(i,1) * (beta^(1-e(i,1)));
            end
    end
       
end