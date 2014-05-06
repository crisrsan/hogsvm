% CRISTINA RUIZ SANCHO
% HOG + SVM


function [svm_weak, feature, alpha, W_out, T_out, G_out] = select_svm(neg_info, pos_info, path_rid, path_positives, path_negatives, W_in)
    
    % PARÀMETRES A TENIR EN COMPTE!!!
    fv = 54; % Number of D-feature vector HOG
    n = 5; % Number of trained SVMs to get a weak classifier 
    error=inf;
    total_samples = length(neg_info)+length(pos_info);
    T_out = zeros(total_samples, fv); %Training matrix: samples features
    G_out = zeros(total_samples, 1); %Group vector: samples annotation
    
   
    %T = zeros(total_samples, fv); %Training matrix: samples features
    %G = zeros(total_samples, 1); %Group vector: samples annotation
    e= zeros(total_samples, 1);
    feature = zeros(1,3);
    
    %NORMALIZE WEIGTHS
    W_in = W_in/sum(W_in);
    
	for i=1:n
        
         % GENERATE REGION - BLOCK RANDOMLY  
        region = zeros(1,3); % Maybe the size of the blocks should be always the same??
        region(1,1) = rand; %ROW
        region(1,2) = rand; %COLUMN
 
        if ((region(1)<0.5) && (region(2) <0.5)) %2n quadrant
            b= min(region(1),region(2));
        elseif ((region(1)<0.5) && (region(2)>0.5)) %1r quadrant
            b = min(region(1),(1-region(2)));
        elseif ((region(1)>0.5) && (region(2)<0.5)) % 3r quadrant
            b = min((1-region(1)),region(2));
        else %4rt quadrant
            b = min((1-region(1)),(1-region(2)));
        end
        a = 0;
        region(1,3) = a + (b-a)*rand;
        
        % PREPARE TRAINING --> HOG EXTRACTION
        [T, G]=feature_extraction(region, pos_info,neg_info,path_rid, path_positives, path_negatives, 0);
                           
    	% TRAIN SVM (svmtrain)
        disp('Training linear SVM..');
        %options.MaxIter = 100;
        try
            %svm = svmtrain(T,G, 'Options', options);
            svm = svmtrain(T,G);
        catch
            disp('ERROR: Not possible to find convergence.');
            continue
        end
   		% COMPUTE ERROR
        % Group = svmclassify (SVMStruct, Sample)
        % !!!! SHOULD THIS BE COMPUTED WITH THE SAME T ? IS THE SAME RES
        % THAT I NEED FOR STRONG CLASSIFIER!
		res = svmclassify (svm, T);
        res
        tmp_error=0;
        tmp_e = zeros (total_samples, 1);
        for l=1:total_samples
            tmp_e(l,1) = abs(res(l,1) - G(l,1));
            %tmp_e(l,1)
            %W_in(l,1)
            tmp_error = tmp_error + W_in(l,1)*tmp_e(l,1);
        end
        tmp_error
        error
		% COMPARISON WITH PREVIOUS SVM - SELECT THE BEST / STORE RESULTS
		if (tmp_error <= error) 
            disp('hoolaaaaa');
            error = tmp_error;
            e = tmp_e;
            svm_weak = svm; 
            %res = tmp_res;
            feature = region;
            T_out=T;
            G_out=G;
        end
        if(error == 0)
            break;
        end
	end
	feature
    error
    
    % UPDATE WEIGHTS!!!
    switch error
        case inf
            feature = 0;
            svm_weak = 0;
            alpha = 0;
            T_out = 0;
            G_out = 0;
            W_out = W_in;
        case 0
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
    
   
    alpha
  
%

end
