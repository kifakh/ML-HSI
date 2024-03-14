%% HyperSpectral Classification
clear memory;
close all;
clear all;
clc;
pause(1);

spectral_data=load('PaviaU.mat');%Hyperspectral
gt_data=load('PaviaU_gt.mat');%Groundtruth
% 
% spectral_data=load('Salinas.mat');
% gt_data=load('Salinas_gt.mat');


% spectral_data=load('Indian_pines_corrected.mat');
%gt_data=load('Indian_pines_gt.mat');
%%
%% Spectral Classi
addpath(genpath(pwd));
%%
class_dict={'asphalt','meadow','gravel','tree','metal sheet','bare soil',...
        'bitumen','brick','shadow'};
dataInfo=struct('data_name','PaviaUniv','num_class',9,'class_dict',{class_dict},...
       'spectral_data',spectral_data.paviaU,'gt_data',gt_data.paviaU_gt);
   
%% 
%figure;subplot(1,2,1);imagesc(dataInfo.gt_data);

dataInfo.splitInfo=SplitData(dataInfo.gt_data,'fix_num',100,true);

train_feat=VectorIndexing3D(dataInfo.spectral_data,dataInfo.splitInfo.train_idx);
test_feat=VectorIndexing3D(dataInfo.spectral_data,dataInfo.splitInfo.test_idx);
train_feat=train_feat/1000;
test_feat=test_feat/1000;
train_label=dataInfo.splitInfo.train_label;
test_label=dataInfo.splitInfo.test_label;
%%

sigma_rbf=3;

%%
disp('Perform classification.');
%% MLR Sparse Multinomial Logistic Regression 
% Implements a block Gauss Seidel  algorithm for fast solution of 
%  the SMLR
[w,val_loss] = MLRTrainAL(train_feat',train_label', 0.1,0.0001,100);
[pred_label,pred_prob]=MLREval(test_feat,dataInfo.num_class, w);


%%
[clsStat,mat_conf]=GetAccuracy(test_label,pred_label);
disp(['Overall Accuracy:',num2str(clsStat.OA),', Kappa Coeffcient:', num2str(clsStat.Kappa)]);
color_map=GetColorMap(16);
mat_pred_label=zeros(size(dataInfo.gt_data));
mat_pred_label(dataInfo.splitInfo.test_idx)=pred_label;
class_map=GetClassMap(mat_pred_label,color_map);
class_map_gt=GetClassMap(dataInfo.gt_data,color_map);

figure('Name','MLR Without PCA');
subplot(1,3,1);imagesc(dataInfo.gt_data);  title('Original gt');
subplot(1,3,2);imagesc(class_map_gt);title('class map gt');
subplot(1,3,3);imagesc(class_map);title('Result');


