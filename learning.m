% CRISTINA RUIZ SANCHO
% HOG + SVM

% VARIABLES INITIALIZATION %
% Some of them can be asked as input arguments.

F_target = 1e-6; % FPR global target
fmax = 0.7; % FPR cascade level target
dmin = 0.9975; % TPR cascade level target
th = 100; % Classification Threshold - Is it different for every level?


path_negatives='/nobackup/server/users/criru691/Dataset/INRIA/negatives/';
path_positives='/nobackup/server/users/criru691/Dataset/INRIA/positives/inria/Train/';
path_rid = '/nobackup/server/users/criru691/Dataset/INRIA/rid/';

%CREATE THE LIST FOR NEGATIVES/POSITIVES IF IT DOESN'T EXIST (ONLY THE FIRST TIME)
% neg_dir = dir(path_negatives);
% f_init = fopen(strcat(path_negatives, 'list.txt'), 'w');
% for i=3:length(neg_dir)
%     if(~strcmp(neg_dir(i).name,'list.txt')) 
%             fprintf(f_init, '%s', neg_dir(i).name);
%             fprintf(f_init, '\n');
%     end
%  end
%  fclose(f_init);


i = 0; % Number of stages/levels of the cascade 
D = 1.0;  F = 1.0; 
k = 0; % Number of weak_classifiers per stage
%svm = zeros(1,2);
 


TPR = 0;
tp = 0; fn = 0; fp = 0; tn = 0;
mkdir('classifiers')
f_out = fopen('classifiers/svm_classifier.txt','w');
reg = zeros(1,3);
res = zeros(total_samples,1);
while (F > F_target)
	i=i+1;
	f=1.0;
	th = 100; % Classification Threshold - Is it different for every level?
    
   
    %PREPARE LEVEL SAMPLES and auxiliar VARIABLES
    [neg_info, pos_info]=prepare_samples (path_negatives, path_positives, path_rid);
    total_samples = length(neg_info)+length(pos_info);
     
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
        matfile = strcat('classifiers/weak_svm_', num2str(i), num2str(k),'.mat');
        save (matfile, 'weak_svm');
        
        fprintf(f_out, '%d', weak_region(1));
        fprintf(f_out, ' ');
        fprintf(f_out, '%d', weak_region(2));
        fprintf(f_out, ' ');
        fprintf(f_out, '%d', weak_region(3));
        fprintf(f_out, ' ');
        fprintf(f_out, '%s', matfile);
        fprintf(f_out, ' ');
        fprintf(f_out, '%d', weak_alpha);
        fprintf(f_out, ' ');
        %region (i,k) = weak_region;
        %svm (i,k) = weak_svm;
        %alpha (i,k) = weak_alpha;
      
        
        while (TPR < dmin)
            th = th / 1.05;
            f_read = fopen('classifiers/svm_classifier.txt', 'r');
            for j=1:k
                % EVALUATE POS&NEG with strong classifier --> TPR / FPR (svmclassify)
                %NOW WE USE TRAINING SAMPLES, WE CAN USE TEST AFTER
                reg(1,1) = str2double(fscanf(f_read,'%s', 1));
                reg(1,2) = str2double(fscanf(f_read,'%s', 1));
                reg(1,3) = str2double(fscanf(f_read,'%s', 1));
                SVM_name = fscanf(f_read, '%s', 1);
                a = str2double(fscanf(f_read, '%s', 1));
                structSVM = load (SVM_name);
                [T, G]=feature_extraction(reg, pos_info, neg_info, path_rid);
                weak_res = (svmclassify (structSVM.weak_svm, T))*a;
                res = res + weak_res;
            end
            fclose(f_read);
            
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
        fprintf(f_out, '%d', th);
        fprintf(f_out, '\n');
        
		% EVALUATE POS&NEG --> f (svmclassify)
        f = FPR;
        D = TPR;
    end
    disp('Stage - False Positive Rate - True Positive Rate')
    k
    f
    D
    
	F = F * f;
	D = D * dmin; %% AQUÍ NO SERIA PER D* TPR??
	
   
	% EMPTY SET NEG
	% GENERATE NEW NEGATIVES
    % Run the cascade on background images (negatives) and get false
    % positives - use them as negatives for the next stage.
    for j=1:length(neg_info)
        if(G((length(pos_info)+j),1) == 0 && res((length(pos_info)+j),1)==1)
            %f_neg = fopen(strcat(path_negatives, 'list.txt'), 'w');
            f_neg = fopen(strcat(path_negatives, 'prova.txt'), 'w');
            fprintfneg_info(j).filename
            fprintf(f_neg, '%s', neg_info(j).filename);
            fprintf(f, '\n');
        end
    end
    fclose(f_neg);
end
fclose(f_out)