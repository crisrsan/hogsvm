% CRISTINA RUIZ SANCHO
% HOG + SVM

t_inici = cputime;
% TRAINING PARAMETERS DEFINITION %
% Some of them could be asked as input arguments.
F_target = 1e-6;    % FPR global target
fmax = 0.65;         % FPR cascade level target
dmin = 0.995;        % TPR cascade level target
fv = 36;            % Feature vector HOG - defined according to goh_extractor parameters.
neg_w = 3;          % Number of windows per negative image
N = 5;				% Number of training blocks/svm per weak classifier selection.
rect = 0;           % Allow rectangular blocks evaluation.


path_negatives='/nobackup/server/users/criru691/Dataset/INRIA/train/train_negatives/';
path_positives='/nobackup/server/users/criru691/Dataset/INRIA/train/train_pos_crop/';
%path_positives='/nobackup/server/users/criru691/Dataset/INRIA/train/train_positives/';

% RESULTANT CLASSIFIER %
mkdir('classifiers');
f_class = fopen('classifiers/svm_classifier.txt','w');

% RESULTS TRACKING FILE %
f_track = fopen ('classifiers/training_results.txt','w');

% DATASET INITIZALIZATION % 
% Create the helper file namelist.txt, get information from all samples required in feature extraction.
[neg_info, pos_info]=prepare_samples (path_negatives, path_positives, neg_w);
aux_neg_info = struct('filename', {}, 'width', {}, 'height', {}, 'row', {}, 'col', {}, 'size', {});
aux_neg_info= neg_info;

% VARIABLES INITIALIZATION %
i = 0;   % Number of stages/levels of the cascade 
D = 1.0; % Final accuracy: TPR 
F = 1.0; % Final accuracy: FPR

first = 1; %Boolean variable to indicate if it is the first level of the cascade.

while (F > F_target)
	i=i+1;
   	
    if(~first)
        % GENERATE NEW NEGATIVES
		% Run the whole cascade on background images (negatives) and get false
		% positives - use them as negatives for the next stage.
		neg_info = sample_negatives(neg_info);
    end
    first = 0;
	total_samples = length(neg_info)+length(pos_info); % Total number of samples used in the training level
	fprintf(f_track, '%s', strcat('CASCADE LEVEL', num2str(i)));
    fprintf(f_track, '\n');
    fprintf(f_track, '%s', strcat(num2str(total_samples),'samples:', num2str(length(pos_info)), 'positives &', num2str(length(neg_info)), ' negatives.'));
    fprintf(f_track, '\n');
	 
    t_stage_inici=cputime;
	[f,d, f_class, f_track]=train_cascade_ilevel(i, f_class, f_track, fmax, dmin, fv, N, rect, pos_info, neg_info);
	t_stage=cputime-t_stage_inici;
	% Computation of global accuracy rates: FPR = F and TPR = D.
	F = F * f;
    D = D * d;
	
    t_final = cputime-t_inici;
    fprintf(f_track, '%s', strcat('Computation time STAGE: ', num2str(t_stage)));
    fprintf(f_track, '\n');
    fprintf(f_track, '%s', strcat('Computation time TOTAL: ', num2str(t_final)));
    fprintf(f_track, '\n');
    fprintf(f_track, '%s', strcat('Final stage F: ', num2str(F)));
    fprintf(f_track, '\n');
    fprintf(f_track, '%s', strcat('Final stage D: ', num2str(D)));
    fprintf(f_track, '\n');
    fprintf(f_track, '\n');
    
    disp('Stage - False Positive Rate - True Positive Rate')
    i
    F
    D
   
end
fclose(f_class);
fprintf(f_track, '%s', strcat('Time consumption: ', num2str(cputime-t_inici)));
fclose(f_track);
