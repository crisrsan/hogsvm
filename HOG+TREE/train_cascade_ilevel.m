
function [f, d, f_class, f_track] = train_cascade_ilevel (i, f_class, f_track, fmax, dmin, fv, N, rect, pos_info, neg_info)
	% TRAIN CASCADE LEVEL i %
	
	% i LEVEL STRONG CLASSIFIER HELPER FILE %
	%f_write = fopen('classifiers/ilevel_classifier.txt','w');
		
	% VARIABLES INITIALIZATION %
	k = 0; %Number of weak_classifers
	f = 1.0; % FPR cascade level initialization
    d=0;
	total_samples = length(neg_info)+length(pos_info); % Total number of samples used in the training level
	res = zeros(total_samples, 1);   
    a=0;
    W = zeros(total_samples, 1); %Weight vector: samples adaboost weigths
    for j=1:length(pos_info)
        W(j,1) = 1/(2*length(pos_info));
    end
    for j=(length(pos_info)+1):total_samples
        W(j,1) = 1/(2*length(neg_info));
    end 
        
    % BUILD STRONG CLASSIFIER %
    disp('Building cascade level ');
    disp(i);
   	while (f > fmax)
        k=k+1;
		
        fprintf(f_track, '%s', strcat('WEAK CLASSIFIER NUMBER', num2str(k)));
        fprintf(f_track, '\n');
        disp('Building strong classifier... weak classifier number ');
        disp(k)
        
        % SELECT WEAK CLASSIFIER%
        train = cputime;
		[weak_tree, weak_region, error, weak_alpha, W, weak_res, G] = select_tree (fv, N, rect, neg_info, pos_info, W);
        train = cputime-train;
        fprintf(f_track, '%s', strcat('CPUTIME', num2str(train)));
        fprintf(f_track, '\n');
        if (weak_region == 0) % Not convergence found
            k= k-1;
            continue
        end
        fprintf(f_track, '%s', strcat('Region: ', num2str(weak_region(1)), num2str(weak_region(2)), num2str(weak_region(3)), num2str(weak_region(4))));
        fprintf(f_track, '\n');
        fprintf(f_track, '%s', strcat('Error: ', num2str(error)));
        fprintf(f_track, '\n');
        fprintf(f_track, '%s', strcat('Alpha: ', num2str(weak_alpha)));
        fprintf(f_track, '\n');
        
		% SAVE NEW WEAK CLASSIFIER %
        matfile = strcat('classifiers/weak_tree_', num2str(i), num2str(k),'.mat');
        save (matfile, 'weak_tree');
		
		% ADD NEW WEAK CLASSIFIER TO THE CASCADE %
		fprintf(f_class, '%d', weak_region(1));
        fprintf(f_class, ' ');
        fprintf(f_class, '%d', weak_region(2));
        fprintf(f_class, ' ');
        fprintf(f_class, '%d', weak_region(3));
        fprintf(f_class, ' ');
        fprintf(f_class, '%d', weak_region(4));
        fprintf(f_class, ' ');
        fprintf(f_class, '%s', matfile);
        fprintf(f_class, ' ');
        fprintf(f_class, '%d', weak_alpha);
        fprintf(f_class, ' ');

        % EVALUATE current POS&NEG samples with i level strong classifier %
        if(weak_alpha < 0)
            disp(weak_alpha);
            break;
        end
        res = res + (weak_res.*weak_alpha);
        a = a + weak_alpha;
        
        % GET THRESHOLD %
        th = (0.5*a)+0.01; % Classification Threshold initialization
        TPR = 0; 
        while (TPR < dmin)
            tp =0; fn = 0; fp = 0; tn = 0;
            count = zeros(total_samples,1);
			th = th-0.01;
            if(th<0)
                th=0;
            end
            disp('Evaluating results with threshold...');
            disp(th);             
            
            for j=1:total_samples
                if(res(j,1)<th) count(j,1)=0;
                else count(j,1)=1;
                end
            end
            
            for j=1:length(count)
                if(G(j,1) == 1 && count(j,1) == 1) tp = tp+1;
                elseif (G(j,1) == 1 && count(j,1) == 0) fn = fn+1;
                elseif (G(j,1) == 0 && count(j,1) == 1) fp = fp+1;
                else tn = tn+1;
                end
            end
            
            TPR = tp / (tp+fn);
            FPR = fp / (fp+tn);
            disp('True positive rate - false positive rate...');
            disp(TPR);
            disp(FPR);
            
        end
		
		

        fprintf(f_track, '%s', strcat('Threshold: ',num2str(th)));
        fprintf(f_track, '\n');
        fprintf(f_track, '%s', strcat('TPR: ', num2str(TPR)));
        fprintf(f_track, '\n');
        fprintf(f_track, '%s', strcat('FPR: ', num2str(FPR)));
        fprintf(f_track, '\n');
  
        f = FPR;
        d = TPR;
    end
   
    disp('Weak classifier - False Positive Rate - True Positive Rate')
    k
    f
    d
    
	% ADD i level THRESHOLD and END MARKER (999999) TO THE CASCADE %
    fprintf(f_class, '%d', 999999);
    fprintf(f_class, '\n');
    fprintf(f_class, '%d', th);
    fprintf(f_class, '\n');
	
    fprintf(f_track, '%s', strcat('Final stage threshold: ', num2str(th)));
    fprintf(f_track, '\n');
	%fclose(f_write);
end