% CRISTINA RUIZ SANCHO
% HOG + SVM

% VARIABLES INITIALIZATION %
% Some of them can be asked as input arguments.

F_target = 1e-6; % FPR global target
fmax = 0.7; % FPR cascade level target
dmin = 0.9975; % TPR cascade level target
th = 100; % Classification Threshold - Is it different for every level?
fv = 54;

path_negatives='/nobackup/server/users/criru691/Dataset/INRIA/negatives/';
path_positives='/nobackup/server/users/criru691/Dataset/INRIA/positives/inria/Train/';
path_rid = '/nobackup/server/users/criru691/Dataset/INRIA/rid/';
%HERE WE CAN CALL A FUNCTION TO CREATE THE LIST.TXT

 %PREPARE LEVEL SAMPLES and auxiliar VARIABLES
    [neg_info, pos_info]=prepare_samples (path_negatives, path_positives, path_rid);
    total_samples = length(neg_info)+length(pos_info);
    res = zeros(total_samples,1);
    T = zeros(total_samples, fv); %Training matrix: samples features
    G = zeros(total_samples, 1); %Group vector: samples annotation




i = 0; % Number of stages/levels of the cascade 
D = 1.0;  F = 1.0; 
k = 0; % Number of weak_classifiers per stage
%svm = zeros(1,2);



TPR = 0;
tp = 0; fn = 0; fp = 0; tn = 0;
f_out = fopen('strong_svm_classifier.txt','w');
while (F > F_target)
	i=i+1;
	f=1.0;
	
    
   

    % VECTOR OF WEIGTHS INITIALIZATION!!
    W = zeros(total_samples, 1); %Weight vector: samples adaboost weigths

    for i=1:length(neg_info)
        W(i,1) = 1/(2*length(neg_info));
    end
    for i=(length(neg_info)+1):total_samples
        W(i,1) = 1/(2*length(pos_info));
    end

    
        
    %TRAIN LEVEL i --> Return variables: f
   	while (f > fmax)
        k=k+1;
        % COMPUTE linear SVM
		[weak_svm, weak_region, weak_alpha, W] = select_svm (neg_info, pos_info, path_rid, W);
        weak_svm
		% COMPUTE STRONG CLASSIFIER - ADD NEW SVM
        % I should create here a file with the INFO - But I still don't
        % know how to store structs. 
        region (i,k) = weak_region;
        svm (i,k) = weak_svm;
        alpha (i,k) = weak_alpha;
        
        
        while (TPR < dmin)
            th = th / 1.05;
            for j=1:k
                % EVALUATE POS&NEG with strong classifier --> TPR / FPR (svmclassify)
                %NOW WE USE TRAINING SAMPLES, WE CAN USE TEST AFTER
                [T, G]=feature_extraction(region(i,j), pos_info, neg_info, path_rid);
                weak_res = (svmclassify (svm (i,j), T))*(alpha(i,j));
                res = res + weak_res;
            end
            
            for j=1:total_samples
                if(res(j,1)<th) res(j,1)=0;
                else res(j,1)=1;
                end
            end
            
            for j=1:length(res)
                if(G(j,1) == 1 && res(j,1) == 1) tp = tp+1;
                elseif (G(j,1) == 1 && res(j,1) == 0) fn = fn+1;
                elseif (G(j,1) == 0 && res(j,1) == 1) fp = fp+1;
                else tn = tn+1;
                end
                TPR = tp / (tp+fn);
                FPR = fp / (fp+tn);
            end
        end
        
		% GET THRESHOLD
		% EVALUATE POS&NEG --> f (svmclassify)
        f = FPR;
        D = TPR;
	end
	F = F * f;
	D = D * dmin; %% AQUÍ NO SERIA PER D* TPR??
	
	% EMPTY SET NEG
	% GENERATE NEW NEGATIVES
    % Run the cascade on background images (negatives) and get false
    % positives - use them as negatives for the next stage.
    
   
    
end
