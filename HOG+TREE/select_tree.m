
function [tree_weak, feature, error, alpha_weak, W_out, res_out, G_out] = select_tree(fv, N, rect, neg_info, pos_info, W_in)
%select_svm Selects the SVM/classifer from a set of N SVMs/classifiers that best (low error) 
%separates the binary dataset (neg_info and pos_info).
%   [svm_weak, feature, alpha, W_out, T_out, G_out] = select_svm(NEG_INFO,
%   POS_INFO, PATH_TO_RID, PATH_TO_POSITIVES, PATH_TO_NEGATIVES, WEIGTHS)
  

    % VARIABLES INITIALIZATION %
    error=inf;
    total_samples = length(neg_info)+length(pos_info);
    W_out = zeros(total_samples, 1);
    %T_out = zeros(total_samples, fv); %Training matrix: samples features
    G_out = zeros(total_samples, 1); %Group vector: samples annotation
    res_out = zeros(total_samples, 1);
    e = zeros(total_samples, 1);
    feature = zeros(1,4);
    
    % NORMALIZE WEIGTHS %
    W_in = W_in/sum(W_in);
    
    % REGION GENERATION PARAMETERS%
    ped_ratio = 0.5;
    if(rect)
        block_ratio = [0.5 1 2]; % block width/height
    else
        block_ratio = 1;
    end
    h = 128;
    w = h*ped_ratio;  
    
	for i=1:N     
        % GENERATE NORMALIZED REGION - BLOCK RANDOMLY % 
        % The size of the blocks is picked randomly among a fixed set 
        % (from 12x12 to 64x64)... and then generate random position,
        % row and column according to image boundaries. 
        
        region = zeros(1,4);
        region(1,4)=randsample(block_ratio,1);
 
        switch (region(1,4))
            case 1
                block_size = 12:2:64;
                region(1,3)=randsample(block_size,1);

            case 0.5
                block_size = 12:2:128;
                region(1,3)=randsample(block_size,1);
                
            case 2
                block_size = 12:2:32;
                region(1,3)=randsample(block_size,1);
        end
        row_pos=1:8:(h-region(1,3)+1);
        region(1,1)=randsample(row_pos,1);
        col_pos=1:8:(w-(region(1,3)*region(1,4))+1);
        region(1,2)=randsample(col_pos,1);
     
                    
        
        % HOG EXTRACTION %
        [T, G]=feature_extraction(fv, region, pos_info, neg_info, 0);
           
        
    	% TRAIN SVM (svmtrain) %
        disp('Training decision tree..');

        try
            tree = fitctree (T,G);

        catch
            disp('ERROR: Not possible to find convergence.');
            continue
        end
        
   		% ERROR CALCULATION (svmclassify) - AdaBoost algorithm %
		res = predict (tree, T);
        tmp_error=0;
        tmp_e = zeros (total_samples, 1);
        for l=1:total_samples
            tmp_e(l,1) = abs(res(l,1) - G(l,1));
            tmp_error = tmp_error + W_in(l,1)*tmp_e(l,1);
        end

        
        if (tmp_error >= 0.5)
            continue
        end
        
		% BEST SVM SELECTION - Comparison with previous SVMs/store results %
        if (tmp_error <= error) 
            error = tmp_error;
            e = tmp_e;
            tree_weak = tree; 
            % RETURN NORMALIZED REGION    
            feature(1,1) = region(1,1)/h;
            feature(1,2) = region(1,2)/w;
            feature(1,3) = region(1,3)/w;
            feature(1,4) = region(1,4);
            G_out=G;
            res_out=res;
        end
        if(error == 0)
            break;
        end
    end
        
    % UPDATE WEIGHTS %
    switch error
        case inf % No SVM converged
            feature = 0;
            tree_weak = 0;
            alpha_weak = 0;
            beta_weak = 0;
            G_out = 0;
            W_out = W_in;
            res_out=0;
        case 0 % Ideal classification - special case.
            beta_weak = 0;
            alpha_weak = 1;
            W_out = W_in;
        otherwise
            beta_weak = error/(1-error);
            alpha_weak = log(1/beta_weak);
            for i=1:total_samples
                W_out(i,1) = W_in(i,1) * (beta_weak^(1-e(i,1)));
            end
    end
end
