                function [Cluster_matrix, Lambda_array,Feature_Value ]=Laplas_MI_MRMR_DP(TSData,Region_Number,Neighbor_index, input_struct_H,input_struct_A)



                Covered_voxels=0;

                fn{1}=strcat('a',num2str(1));
                X=input_struct_H.(fn{1});
                N=size(X,1);

                S=zeros(N,1);
                red=zeros(N,1);
                blue=zeros(N,1);
                S_Denom=zeros(N,1);
                S_Nom=zeros(N,1);

                k=1;
                for i=1:370
                k=k+1;
                fn{k}=strcat('a',num2str(i));
                Xz=input_struct_H.(fn{k});

                for j=1:N
                X_mean(j,:)=mean(Xz(j,:));
                end


                X_mean_Total_H(i,:)=X_mean;
                end



                %%%disp(size(X_mean_Total_H));




                k=1;
                for i=1:313
                k=k+1;
                fn{k}=strcat('a',num2str(i));
                X=input_struct_A.(fn{k});

                for j=1:N
                X_mean(j,:)= mean(X(j,:));
                end

                X_mean_Total_A(i,:)=X_mean;

                end








                % rand=randi(size(X_mean_Total_H,2));
                % if rand>0
                % start=rand;
                % end
                % kk=1;
                % Start_array(1)=start;

                start=1;


                X_mean_Total(1:370,:)=X_mean_Total_H;
                X_mean_Total(371:683,:)=X_mean_Total_A;




                Class=zeros(683,1);
                Class(1:370)=1;
                X_mean_Total(:,size(X_mean_Total,2)+1)=Class;
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                shuffledArray = X_mean_Total(randperm(size(X_mean_Total,1)),:);



                Train=shuffledArray(1:547,:);
                Test=shuffledArray(548:683,:);

                Data_Total=shuffledArray;

                %disp('size of Data_Total')

                %disp(size(Data_Total))

                Data_Total(:,size(Data_Total,2))=[];
                Vs=1;
                 Cluster(1)=start;



                X1=Train(:,start);
                X2=Test(:,start);
                Cluster_index=0;


                 Big_Accuracies=0;
                 Cluster_size=1;
                 Cluster_voxels(1)=start;



                Region_Number=num2str(Region_Number);
                Region_Number=strcat('Region_',Region_Number);
                x=TSData.(Region_Number).vox_loc;


                Cluster_matrix=zeros(size(x,1));
                %%disp(size(Cluster_matrix))


                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


                Y_train=Class;

                step=0;
                 X_train=Data_Total(:,start);% whole cluster->X_train->X_train+new voxel
                        [n_t, n_f] = size(X_train);
                numFeatures=size(X_train,2);
                % calculate the scatter matrices


                Data_Total_quantized=quantize(Data_Total,'levels',256);




                temp_Cluster_matrix=zeros(size(Data_Total,1),size(Data_Total,2));
                L=0;





                for i1=1: size(Data_Total,1)
                for j1=1: size(Data_Total,1)
                if Class(i1)==Class(j1) && Class(i1)==1
                WW_w(i1,j1)= (1/370);
                WW_b(i1,j1)= (1/683)-(1/370);
                end
                if Class(i1)==Class(j1) && Class(i1)==0
                WW_w(i1,j1)=(1/313);
                WW_b(i1,j1)=(1/683)-(1/313);
                end
                if Class(i1)~=Class(j1)
                WW_w(i1,j1)=0;
                WW_b(i1,j1)=(1/683);
                end
                end
                end




                %A_w = WW_w.*WW_w';
                %A_b = WW_b.*WW_b';

                %A_w = spones(WW_w+WW_w');
                %A_b = spones(WW_b+WW_b');
                WW_w1=WW_w+WW_w';
                WW_b1=WW_b+WW_b';
                WW_w1=WW_w1~=0;
                WW_b1=WW_b1~=0;
                A_w=WW_w1;
                A_b=WW_b1;
                AA_w = (A_w+A_w')/2;
                %spdiags

                for i2=1:n_t
                D_w(i2,i2)=sum(AA_w(i2,:));
                end
                L_w = D_w - AA_w;
                AA_b = (A_b+A_b')/2;
                %D_b = spdiags(sum(AA_b,2),0,n_t,n_t);
                for i2=1:n_t
                D_b(i2,i2)=sum(AA_b(i2,:));
                end
                L_b = D_b - AA_b;
                L_w = (L_w + L_w')/2;
                L_b = (L_b + L_b')/2;
                Sw = X_train'*L_w*X_train;
                Sb = X_train'*L_b*X_train;
                Sw = (Sw + Sw')/2;
                Sb = (Sb + Sb')/2;



                [evec_Sw eval_Sw] = eig(Sw);  % Sw*evec_Sw = evec_Sw*eval_Sw, eval->diagonal eignevalues
                eval_Sw = abs(diag(eval_Sw)); % n*1 matrix of aigenvalues
                nzero_Sw = length(find(eval_Sw<=1e-6)); %number of zeros in eval_Sw diagonal eigenvalues
                [evec_Sb eval_Sb] = eig(Sb); 
                eval_Sb = sort(diag(eval_Sb), 'descend'); %sort eigs of Sb descending
                %%disp(size(eval_Sb));
                max_numerator = sum(eval_Sb(1:numFeatures)); % 
                [evec_Sw eval_Sw] = eig(Sw);
                eval_Sw = sort(diag(eval_Sw));
                min_denominator = sum(abs(eval_Sw(1:numFeatures)));
                lamda_sup = max_numerator/min_denominator;
                lamda_inf = trace(Sb)/trace(Sw);
                lamda = (lamda_inf+lamda_sup)/2; 
                lamda=lamda_sup;
                lamda_sup_start = lamda;



                %%%%%General Matrices


                %disp('General Matrices')

                [n_t, n_f] = size(Data_Total );

                %disp(size(Data_Total))

                WW_w1=WW_w+WW_w';
                WW_b1=WW_b+WW_b';
                WW_w1=WW_w1~=0;
                WW_b1=WW_b1~=0;
                A_w=WW_w1;
                A_b=WW_b1;
                AA_w = (A_w+A_w')/2;
                AA_b = (A_b+A_b')/2;
                %D_w = spdiags(sum(AA_w,2),0,n_t,n_t);
                for i2=1:n_t
                D_w(i2,i2)=sum(AA_w(i2,:));
                end
                for i2=1:n_t
                D_b(i2,i2)=sum(AA_b(i2,:));
                end


                L_W=D_w(1:n_t,1:n_t)-AA_w;
                L_b=D_b(1:n_t,1:n_t)- AA_b;
                L_w = (L_w + L_w')/2;
                L_b = (L_b + L_b')/2;
                Sw = Data_Total'*L_w*Data_Total;
                Sb = Data_Total'*L_b*Data_Total;
                Sw = (Sw + Sw')/2;
                Sb = (Sb + Sb')/2;



                %disp('General Matrices finished')


                %disp('sw size');

                %disp(size(Sw));



                Y_train=Class;
                Sw1=0;
                Sb1=0;
                Newly_added=0;
                Newly_removed=0;













                for i=1:size(Data_Total,2)

                CountsMat(:,1)=Class;
                CountsMat(:,2)=Data_Total(:,i);
                nS = size(CountsMat);
                % Obtain the number of X variables
                N = length(nS) - 1;
                % Convert the CountsMat to a joint probability distribution. (Note, this
                Pxy = CountsMat/sum(CountsMat(:));
                % Find the joint probabilities for the Y and {X1,...XN} variables
                Px = repmat(sum(Pxy,1),[nS(1),ones([1,N])]);
                Py = repmat(sum(Pxy(:,:),2),[1,nS(2:end)]);
                % Calculate the mutual information
                temp = Pxy.*log2(Pxy./(Px.*Py));
                % Matlab incorrectly gives states with Pxy = 0 a non-finite value. 
                temp(~isfinite(temp)) = 0;
                % Sum over the terms to get the mutual information
                MI = sum(temp(:));
                I_I1= MI; %Mutual information of each feature and the target
                I_I(i)=I_I1;

                end








                index=zeros((size(Data_Total,2)),(size(Data_Total,2)));
                I_CI=zeros((size(Data_Total,2)),(size(Data_Total,2)));
                I_MA=zeros((size(Data_Total,2)),(size(Data_Total,2)));







                %%disp('prelim done');



                while  Vs<size(Data_Total,2)% is notvoxels covered the size of search space


                  disp('Vs');
                  disp(Vs);





                %Start the search




                Chosen_index=zeros(1,27);
                Nieghbor_array=zeros(1,27);

                for v=1:Cluster_size


                 for i=1:27

                    if Neighbor_index(Cluster_voxels(v),i) ~=0

                        if ~ismember(Cluster_voxels,Neighbor_index(Cluster_voxels(v),i))  %v=1-> Neighbor_index(137,1), Neighbor_index(137,2),..., v=2->Neighbor_index(151,1), Neighbor_index(151,2),...    
                        X1_neighbor=Data_Total(:,Neighbor_index(Cluster_voxels(v),i)); % neighbor=152-> X1_neighbor=Data_total(:,152)
                        X_train(:,size(X_train,2)+1)=Data_Total(:,Neighbor_index(Cluster_voxels(v),i));% whole cluster->X_train->X_train+new voxel

                        [n_t, n_f] = size(X_train);
                        numFeatures=size(X_train,2);
                % calculate the scatter matrices

                Cluster_voxels(size(Cluster_voxels,2)+1)=Neighbor_index(Cluster_voxels(v),i);
                Cluster_size=Cluster_size+1;



                %disp('cluster size');
                %disp(Cluster_size);

                %disp('Cluster_voxels');
                %disp(Cluster_voxels);

                %disp('Sw size');
                %disp(size(Sw))

                for kk=1:Cluster_size
                for mm=1:Cluster_size
                Sw1(kk,mm)=Sw(Cluster_voxels(kk),Cluster_voxels(mm));
                end
                end

                for kk=1:Cluster_size
                for mm=1:Cluster_size
                Sb1(kk,mm)=Sb(Cluster_voxels(kk),Cluster_voxels(mm));
                end
                end




                [evec_Sw eval_Sw] = eig(Sw1);  % Sw*evec_Sw = evec_Sw*eval_Sw, eval->diagonal eignevalues
                eval_Sw = abs(diag(eval_Sw)); % n*1 matrix of aigenvalues
                [evec_Sb eval_Sb] = eig(Sb1); 
                eval_Sb = sort(diag(eval_Sb), 'descend'); %sort eigs of Sb descending
                max_numerator = sum(eval_Sb(1:numFeatures)); % 
                [evec_Sw eval_Sw] = eig(Sw1);
                eval_Sw = sort(diag(eval_Sw));
                min_denominator = sum(abs(eval_Sw(1:numFeatures)));
                lamda_sup = max_numerator/min_denominator;
                lamda_inf = trace(Sb1)/trace(Sw1);
                lamda = (lamda_inf+lamda_sup)/2; 
                lamda=lamda_sup;
                Nieghbor_array(i)=lamda;
                Chosen_index(i)=Neighbor_index(Cluster_voxels(v),i); 
                X_train(:,size(X_train,2))=[];
                Cluster_voxels(size(Cluster_voxels,2))=[];
                Cluster_size=Cluster_size-1;
                Sw1=0;
                Sb1=0;
                    end

                 end


                end

                end



                k=0;




                for i=1:size(Nieghbor_array,2)
                if  Nieghbor_array(i)>lamda_sup_start

                %%%disp('good neighbor')
                %%disp(Chosen_index(i))
                if ~ismember(Cluster_voxels,Chosen_index(i))
                if ~ismember(Newly_removed,Chosen_index(i))  %don't add the just removed feature



                k=k+1;
                X_train(:,size(X_train,2)+1)=Data_Total(:,Chosen_index(i));
                Cluster_voxels(size(Cluster_voxels,2)+1)=Chosen_index(i);
                Cluster_size=Cluster_size+1;
                Newly_added(k)=Chosen_index(i);
                end
                end
                end
                end

                step=step+1;

                %disp('Newly_added')
                %disp(Newly_added)


                if step>1  %%%%%%%%%%%%% check if this cluster is being repeated and help it get out of the loop

                for kk=1:size(temp_Cluster_matrix,1)
                z1=nonzeros(temp_Cluster_matrix(kk,:));

                if size(z1',2)==size(Cluster_voxels,2)
                rem=Cluster_voxels-z1';
                B=all(rem);
                if B==0
                k=0;
                break;
                end
                end
                end

                end


                L=L+1;
                temp_Cluster_matrix(L,1:size(Cluster_voxels,2))=Cluster_voxels;


                %%disp('cluster size after relevance');
                %%disp(Cluster_size);










                CountsMat=zeros(size(X_train,1),size(X_train,2)+1);



                CountsMat(:,1)=Class;
                CountsMat(:,2:(size(X_train,2)+1))=X_train;
                %nS = size(CountsMat);
                % Obtain the number of X variables
                %N = length(nS) - 1;
                % Convert the CountsMat to a joint probability distribution. (Note, this
                % will have no effect if the CountsMat is already the joint probability
                % distribution.)
                %Pxy = CountsMat/sum(CountsMat(:));
                % Find the joint probabilities for the Y and {X1,...XN} variables
                %Px = repmat(sum(Pxy,1),[nS(1),ones([1,N])]);
                %Py = repmat(sum(Pxy(:,:),2),[1,nS(2:end)]);
                % Calculate the mutual information
                %temp = Pxy.*log2(Pxy./(Px.*Py));
                % Matlab incorrectly gives states with Pxy = 0 a non-finite value. 
                %temp(~isfinite(temp)) = 0;
                % Sum over the terms to get the mutual information
                %dep_start = sum(temp(:));






                Newly_removed=0;
                removals1=0;
                removals3=0;

                % 
                 if k>0 && step>1 %%%%%%%%%%%%%%%redundancy analysis%%%%%%%%%%%%%



                MI_array=zeros(3,size(X_train,2));

                MI_array(1,1)=0;
                MI_array(2,1)=0;
                MI_array(3,1)=0;

                CountsMat(:,1)=Class;
                CountsMat(:,2:(size(X_train,2)+1))=X_train;
                %%disp('size(MI_array,2) before loop')
                %size(MI_array,2)
                %%disp('cluster voxels')
                %%disp(Cluster_voxels)


                for i=2:(size(X_train,2)+1)

                %CountsMat without column 1 

                CountsMat1=CountsMat;
                CountsMat1(:,i)=[];




                MI_array(1,i)=i;
                MI_array(2,i)=MI;
                MI_array(3,i)=Cluster_voxels(i-1);

                end

                MI_array(:,1)=[];


                MI_array(1,:)=MI_array(1,:)-1;
                %%disp('MI_array')
                %%disp(MI_array)





                 %%disp('dep start' );
                 %%disp(dep_start);
                 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%      %removing redundant columns but taking
                 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%care of matrix index

                 M=0;







                 %%%%%%%%%%%%%%%%%%%%%%Redundancy Analysis)












                for i=1:size(Cluster_voxels,2)
                temp_I_MA=0;
                temp_I_CI=0;
                for j=1:size(Cluster_voxels,2)




                if index(Cluster_voxels(i),Cluster_voxels(j))==1
                temp_I_MA(j)=I_MA(Cluster_voxels(i),Cluster_voxels(j));
                temp_I_CI(j)=I_CI(Cluster_voxels(i),Cluster_voxels(j));
                else


                p_zxy = dimensionalize( [Class Data_Total_quantized(:, [Cluster_voxels(i) Cluster_voxels(j)])]); % convert to freq table
                p_zxy = p_zxy ./ sum(p_zxy(:)); % normalize

                dim=[0 1 1];

                sz  = size(p_zxy);
                mrg = p_zxy;
                idx=find(dim<=0);
                for k=1:length(idx)
                    mrg=sum(mrg,idx(k));
                end
                 mrg=squeeze(mrg);
                p_xy=mrg;
                temp_I_MA(j) = interaction_info(p_xy, 'prior', 0);%Mutual interactions between each feature and the rest of them
                temp_I_CI(j)=interaction_info(p_zxy, 1, 'prior', 0);%Conditional Mutual information with the target


                I_MA(Cluster_voxels(i),Cluster_voxels(j))=temp_I_MA(j);
                I_CI(Cluster_voxels(i),Cluster_voxels(j))=temp_I_CI(j);
                index(Cluster_voxels(i),Cluster_voxels(j))=1;

                end


                end


                I_MA_array(i)=sum(temp_I_MA);
                I_CI_array(i)=sum(temp_I_CI);




                end  

                Feature_Value =I_I(Cluster_voxels)- I_MA_array +I_CI_array; %Each feature's value 










                 %for i=1:size(Cluster_voxels,2)
                 %I_CI_array(i)=sum(I_CI(Cluster_voxels(i),Cluster_voxels));
                 %I_MA_array(i)=sum(I_MA(Cluster_voxels(i),Cluster_voxels));
                 %end


                %Feature_Value=I_I(Cluster_voxels)-I_MA_array+I_CI_array;
                %disp(Cluster_voxels);
                %disp('size(Feature_Value)');
                %disp(size(Feature_Value));

                for i=1:((size(X_train,2))-k)  
                if Feature_Value(i)< 0.25*max(Feature_Value)
                M=M+1;
                removals1(M)=Cluster_voxels(i);
                Cluster_size=Cluster_size-1;
                Newly_removed(M)=Cluster_voxels(i); 

                end
                end








                end
                M=0;



                if removals1>0
                X_train(:,removals1)=[];
                Cluster_voxels(removals1)=[]; 
                end
                %disp('newly removed')
                %disp(Newly_removed)

                %%disp('cluster size after redundancy removal');
                %%disp(Cluster_size);


                Nieghbor_array=0;
                Newly_added=0;
                MI_array=0;
                I_MA_array=0;
                I_CI_array=0;
                Feature_Value=0;






























                numFeatures=size(X_train,2);

                [n_t, n_f] = size(X_train);





                for kk=1:Cluster_size
                for mm=1:Cluster_size
                Sw2(kk,mm)=Sw(Cluster_voxels(kk),Cluster_voxels(mm));
                end
                end

                for kk=1:Cluster_size
                for mm=1:Cluster_size
                Sb2(kk,mm)=Sb(Cluster_voxels(kk),Cluster_voxels(mm));
                end
                end




                Sw2 = (Sw2 + Sw2')/2;
                Sb2 = (Sb2 + Sb2')/2;





                [evec_Sw2 eval_Sw2] = eig(Sw2);  % Sw*evec_Sw = evec_Sw*eval_Sw, eval->diagonal eignevalues
                eval_Sw2 = abs(diag(eval_Sw2)); % n*1 matrix of aigenvalues
                [evec_Sb2 eval_Sb2] = eig(Sb2); 
                eval_Sb2 = sort(diag(eval_Sb2), 'descend'); %sort eigs of Sb descending
                max_numerator = sum(eval_Sb2(1:numFeatures)); % 
                [evec_Sw2 eval_Sw2] = eig(Sw2);
                eval_Sw2 = sort(diag(eval_Sw2));
                min_denominator = sum(abs(eval_Sw2(1:numFeatures)));
                lamda_sup = max_numerator/min_denominator;
                lamda_inf = trace(Sb2)/trace(Sw2);
                lamda = (lamda_inf+lamda_sup)/2; 
                lamda=lamda_sup;
                lamda_sup_start = lamda;


                %%disp('number of good neighbors');
                %%disp(k);

                Sw2=0;
                Sb2=0;




                if k==0
                %save cluster so far
                for i=1:size(Cluster_voxels,2)
                Cluster_matrix(Vs,i)=Cluster_voxels(i);
                end
                Lambda_array(Vs)=lamda_sup_start;
                %start new cluster
                lamda_sup_start=0;
                Cluster_voxels=0;
                Cluster_size=0;
                Nieghbor_array=0;
                X_train=0;
                Vs=Vs+1;
                X_train=Data_Total(:,Vs);
                Cluster_size=1;
                Cluster_voxels(1)=Vs;
                step=0;
                temp_Cluster_matrix=0;
                L=0;
                end





                %%disp('Cluster_size');
                %%disp(Cluster_size);



                end  %end while




                end
