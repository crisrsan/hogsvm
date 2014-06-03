
function [f, d, f_class, f_track] = train_cascade_ilevel (i, f_class, f_track, fmax, dmin, fv, N, pos_info, neg_info, path_positives, path_negatives)
	% TRAIN CASCADE LEVEL i %
	
	% i LEVEL STRONG CLASSIFIER HELPER FILE %
	%f_write = fopen('classifiers/ilevel_classifier.txt','w');
		
	% VARIABLES INITIALIZATION %
	k = 0; %Number of weak_classifers
	f = 1.0; % FPR cascade level initialization
    max = 2^i;
    d=0;
	total_samples = length(neg_info)+length(pos_info); % Total number of samples used in the training level
    reg = zeros(1,3);
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
   	while (f > fmax || d < dmin)
        k=k+1;
		
        fprintf(f_track, '%s', strcat('WEAK CLASSIFIER NUMBER', num2str(k)));
        fprintf(f_track, '\n');
        disp('Building strong classifier... weak classifier number ');
        disp(k)
        
        % SELECT WEAK CLASSIFIER%
        train = cputime;
		[weak_svm, weak_region, weak_alpha, W, weak_res, T, G] = select_svm (fv, N, neg_info, pos_info, path_positives, path_negatives, W);
        train = train - cputime;
        fprintf(f_track, '%s', strcat('CPUTIME', num2str(train)));
        fprintf(f_track, '\n');
        if (weak_region == 0) % Not convergence found
            k= k-1;
            continue
        end
        fprintf(f_track, '%s', strcat('Region: ', num2str(weak_region(1)), num2str(weak_region(2)), num2str(weak_region(3))));
        fprintf(f_track, '\n');
        fprintf(f_track, '%s', strcat('Alpha: ', num2str(weak_alpha)));
        fprintf(f_track, '\n');
        
		% SAVE NEW WEAK CLASSIFIER %
        matfile = strcat('classifiers/weak_svm_', num2str(i), num2str(k),'.mat');
        save (matfile, 'weak_svm');
		
		% ADD NEW WEAK CLASSIFIER TO THE CASCADE %
		fprintf(f_class, '%d', weak_region(1));
        fprintf(f_class, ' ');
        fprintf(f_class, '%d', weak_region(2));
        fprintf(f_class, ' ');
        fprintf(f_class, '%d', weak_region(3));
        fprintf(f_class, ' ');
        %fprintf(f_class, '%d', total_samples);
        %fprintf(f_class, ' ');
        fprintf(f_class, '%s', matfile);
        fprintf(f_class, ' ');
        fprintf(f_class, '%d', weak_alpha);
        fprintf(f_class, ' ');
		
%         % ADD NEW WEAK CLASSIFIER TO THE i LEVEL STRONG CLASSIFIER%
%         fprintf(f_write, '%d', weak_region(1));
%         fprintf(f_write, ' ');
%         fprintf(f_write, '%d', weak_region(2));
%         fprintf(f_write, ' ');
%         fprintf(f_write, '%d', weak_region(3));
%         fprintf(f_write, ' ');
%         %fprintf(f_write, '%d', total_samples);
%         %fprintf(f_write, ' ');
%         for m=1:total_samples
%             for n=1:fv
%                 fprintf(f_write, '%d', T(m,n));
%                 fprintf(f_write, ' ');
%             end
%         end
%         fprintf(f_write, '%s', matfile);
%         fprintf(f_write, ' ');
%         fprintf(f_write, '%d', weak_alpha);
%         fprintf(f_write, ' ');
%         
%         % EVALUATE current POS&NEG samples with i level strong classifier %
%         disp('Evaluating strong classifier...');
%         alpha = 0;
%         res = zeros(total_samples,1);
%         f_read = fopen('classifiers/ilevel_classifier.txt', 'r');
%         
%         for j=1:k
% 			reg(1,1) = str2double(fscanf(f_read,'%s', 1));
%             reg(1,2) = str2double(fscanf(f_read,'%s', 1));
%             reg(1,3) = str2double(fscanf(f_read,'%s', 1));
%             %samples = str2double(fscanf(f_read,'%s', 1));
%             %if (res == 0) 
%                 %res = zeros (samples,1);
%             %end
%             HOG = zeros(total_samples, fv);
%           
%             for m=1:total_samples
%                 for n=1:fv
%                      HOG(m,n) = str2double(fscanf(f_read, '%s', 1));
%                 end
%             end
%             SVM_name = fscanf(f_read, '%s', 1);
%             a = str2double(fscanf(f_read, '%s', 1));
%        
%             structSVM = load (SVM_name);
%             %[HOG, G]=feature_extraction(reg, pos_info, neg_info, path_positives, path_negatives, 0);
%             
%             weak_res = (svmclassify (structSVM.weak_svm, HOG))*a; 
%             res = res + weak_res;
%             alpha = alpha + a;           
%         end
%         fclose(f_read);
        


        % EVALUATE current POS&NEG samples with i level strong classifier %
        if(weak_alpha < 0)
            disp(weak_alpha);
            break;
        end
        res = res + (weak_res.*weak_alpha);
        res
        a = a + weak_alpha;



        
        % GET THRESHOLD %
        th = 0.5*a; % Classification Threshold initialization
        TPR = 0; 
        while (TPR < dmin)
            tp =0; fn = 0; fp = 0; tn = 0;
            count = zeros(total_samples,1);
			
            disp('Evaluating results with threshold...');
            disp(th);             
            
            for j=1:total_samples
                if(res(j,1)<=th) count(j,1)=0;
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
            
            if (th>0)
                th = th-0.01;
                if(th<0) 
                    th=0;
                end
            elseif(th==0)
                break;
            end
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