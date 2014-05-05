% CRISTINA RUIZ SANCHO
% HOG + SVM


% RESULT TRACKING DOCUMENT %
file = fopen ('training_results.txt','w');

% RESULTANT CLASSIFIER %
mkdir('classifiers');
f_out = fopen('classifiers/svm_classifier.txt','w');

% PARAMETERS DEFINITION %
% Some of them can be asked as input argument!!!!!!!!!.
F_target = 1e-6;    % FPR global target
fmax = 0.7;         % FPR cascade level target
dmin = 0.9975;      % TPR cascade level target
th = 0;           % Classification Threshold - Is it different for every level?

path_negatives='/nobackup/server/users/criru691/Dataset/INRIA/negatives/';
path_positives='/nobackup/server/users/criru691/Dataset/INRIA/positives/inria/Train/';
path_rid = '/nobackup/server/users/criru691/Dataset/INRIA/rid/';

% SAMPLES INITIZALIZATION % 
% Create the helper file list.txt, get information from all samples and
% convert them to rid images for a successful feature extraction. 
[neg_info, pos_info]=prepare_samples (path_negatives, path_positives, path_rid);


% VARIABLES INITIALIZATION %
i = 0; % Number of stages/levels of the cascade 
D = 1.0; % Final accuracy: TPR 
F = 1.0; % Final accuracy: FPR
%svm = zeros(1,2);
TPR = 0;
tp = 0; fn = 0; fp = 0; tn = 0;
reg = zeros(1,3);


while (F > F_target)
	i=i+1;
    k = 0; % Number of weak_classifiers per stage
	f=1.0;
	
   
    fprintf(file, '%s', strcat('CASCADE LEVEL  ', num2str(i)));
    fprintf(file, '\n');
   
    total_samples = length(neg_info)+length(pos_info);
    res = zeros(total_samples,1);
    fprintf(file, '%s', strcat(num2str(total_samples), ' samples: ', num2str(length(pos_info)), 'positives & ', num2str(length(neg_info)), ' negatives.'));
    fprintf(file, '\n');
    
    % VECTOR OF WEIGTHS INITIALIZATION!!
    W = zeros(total_samples, 1); %Weight vector: samples adaboost weigths

    for j=1:length(pos_info)
        W(j,1) = 1/(2*length(pos_info));
    end
    for j=(length(pos_info)+1):total_samples
        W(j,1) = 1/(2*length(neg_info));
    end 
        
    %TRAIN LEVEL i --> Return variables: f
    disp('Building cascade level ');
    disp(i);
   	while (f > fmax)
        k=k+1;
       
        fprintf(file, '%s', strcat('WEAK CLASSIFIER NUMBER  ', num2str(k)));
        fprintf(file, '\n');
        disp('Building strong classifier... weak classifier number ');
        disp(k)
        
        % COMPUTE linear SVM classifier
		[weak_svm, weak_region, weak_alpha, W, T, G] = select_svm (neg_info, pos_info, path_rid, path_positives, path_negatives, W);
        %[weak_svm, weak_region, weak_alpha, W] = select_svm (neg_info, pos_info, path_rid, W);
        fprintf(file, '%s', strcat('Region: ', num2str(weak_region(1)), ' ', num2str(weak_region(2)), ' ', num2str(weak_region(3))));
        fprintf(file, '\n');
        fprintf(file, '%s', strcat('Alpha: ', num2str(weak_alpha)));
        fprintf(file, '\n');
        
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
    
        th = th+(0.5*weak_alpha); % Classification Threshold - Is it different for every level?
        TPR = 0; % Empty every round?
        while (TPR < dmin)
            
            disp('Evaluating strong classifier, with threshold...');
            disp(th);
            
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
                %[T, G]=feature_extraction(reg, pos_info, neg_info, path_rid);
                weak_res = (svmclassify (structSVM.weak_svm, T))*a;
                res = res + weak_res;
                res
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
            
            tp
            fn
            fp
            tn
            disp('True positive rate - false positive rate...');
            disp(TPR);
            disp(FPR)
            th = th- 0.01;
            tp =0; fn = 0; fp = 0; tn = 0;
        end
        fprintf(file, '%s', strcat('TPR: ', num2str(TPR)));
        fprintf(file, '\n');
        fprintf(file, '%s', strcat('FPR: ', num2str(FPR)));
        fprintf(file, '\n');
        
		% GET THRESHOLD
        fprintf(f_out, '%d', th);
        fprintf(f_out, '\n');
        
		% EVALUATE POS&NEG --> f (svmclassify)
        f = FPR;
        %D = TPR;
        disp('Weak classifier - False Positive Rate - True Positive Rate')
        k
        f
        TPR
    end
       
    
	F = F * f;
	%D = D * dmin; %% AQUÍ NO SERIA PER D* TPR??
    D = D * TPR;
	
    fprintf(file, '%s', strcat('Final stage threshold: ', num2str(th)));
    fprintf(file, '\n');
    fprintf(file, '%s', strcat('Final stage F: ', num2str(F)));
    fprintf(file, '\n');
    fprintf(file, '%s', strcat('Final stage D: ', num2str(D)));
    fprintf(file, '\n');
    fprintf(file, '\n');
    
    disp('Stage - False Positive Rate - True Positive Rate')
    i
    F
    D
   
	% EMPTY SET NEG
	% GENERATE NEW NEGATIVES
    % Run the cascade on background images (negatives) and get false
    % positives - use them as negatives for the next stage.
    %f_neg = fopen(strcat(path_negatives, 'list.txt'), 'w');
    f_neg = fopen(strcat(path_negatives, 'prova.txt'), 'w');
    for j=1:length(neg_info)
        if(G((length(pos_info)+j),1) == 0 && res((length(pos_info)+j),1)==1)       
            fprintf(f_neg, '%s', neg_info(j).filename);
            fprintf(f, '\n');
        end
    end
    fclose(f_neg);
   
    [neg_info] = prepare_negative_samples(path_negatives);
end
fclose(f_out);
fclose(file);