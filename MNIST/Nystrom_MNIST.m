%%
clear all
close all
clc


%% Identification Data

train_data = readtable('mnist_train.csv');
test_data  = readtable('mnist_test.csv');

%%Option 1: The input images to grayscale [0-1] by dividing by 255.
%X_p_all = train_data{:,2:end}/255;
%X_t_all = test_data{:,2:end}/255;

%%Option 2: The input images (rows) normalized
X_p_all = normalize(train_data{:,2:end},2);
X_t_all = normalize(test_data{:,2:end},2);


%The labels [0-9] 
Labels_p_all = train_data{:,1};
Labels_t_all = test_data{:,1};

bigger_5_p  = Labels_p_all(:,1) >= 5;  %label -1
smallereq_4_p = Labels_p_all(:,1) <= 4;  %label 1
Labels_p_all = bigger_5_p - smallereq_4_p;

bigger_5_t  = Labels_t_all(:,1) >= 5;  %label -1
smallereq_4_t = Labels_t_all(:,1) <= 4;  %label 1
Labels_t_all = bigger_5_t-smallereq_4_t;


%% Initialization

n_p = 3;
d_p = 10;

n_t = 3;
d_t = 8;

X_p = X_p_all(1:n_p^d_p,:);
Labels_p = Labels_p_all(1:n_p^d_p,:);



X_t = X_t_all(1:n_t^d_t,:); 
Labels_t = Labels_t_all(1:n_t^d_t,:);


%% initial values
%%% Here the initial values are

gam  = 0.05;                                          
sig2 = 5; 
nb = 10;

S = 3^4;
RandPermutation = randperm(length(X_p))
Subset = X_p(RandPermutation(1:S),:)
Subset_labels = Labels_p(RandPermutation(1:S),:)

tic
[V, D] = eign(Subset, 'RBF_kernel', sig2, nb);
toc 

diagD = diag(D);
alpha = gam*(Subset_labels - (V*inv((1/gam)*eye(length(D))+diagD*(V'*V)))*diagD*V'*Subset_labels);

b_p=0;
[Ylabels_training, Zp] = simlssvm({Subset,Subset_labels,'c',gam,sig2,'RBF_kernel','o'}, {alpha,b_p}, Subset);
[Ylabels_validation, Zp] = simlssvm({Subset,Subset_labels,'c',gam,sig2,'RBF_kernel','o'}, {alpha,b_p}, X_t);


num_correct      = sum(Ylabels_validation == Labels_t);
num_incorrect    = length(Ylabels_validation)-num_correct;
percentage_wrong = num_incorrect/length(Ylabels_validation)
percentage_right = num_correct/length(Ylabels_validation)


