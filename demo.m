%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This code is for [1], and can only be used for non-comercial purpose. If
% you use our code, please cite [1].
% 
% Code Author: Long Zhao
% Email: gary.zhao9012@gmail.com
% Date: 2014/11/25
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% This demo shows how to use Saliency Baseline [1], as well as
% Saliency Optimization [2], Saliency Filter [3], Geodesic Saliency [4],
% and Manifold Ranking [5].

% [1] Long Zhao, Shuang Liang, Yichen Wei, and Jinyuan Jia. Size 
% and Location Matter: a New Baseline for Salient Object Detection.
% In ACCV, 2014.

% [2] Wangjiang Zhu, Shuang Liang, Yichen Wei, and Jian Sun. Saliency
% Optimization from Robust Background Detection. In CVPR, 2014.

% [3] F. Perazzi, P. Krahenbuhl, Y. Pritch, and A. Hornung. Saliency
% filters: Contrast based filtering for salient region detection.
% In CVPR, 2012.

% [4] Y.Wei, F.Wen,W. Zhu, and J. Sun. Geodesic saliency using
% background priors. In ECCV, 2012.

% [5] C. Yang, L. Zhang, H. Lu, X. Ruan, and M.-H. Yang. Saliency
% detection via graph-based manifold ranking. In CVPR, 2013.

%%
clear, clc, 
close all
addpath('Funcs');

%% 1. Parameter Settings
doFrameRemoving = true;
useSP = true;	% You can set useSP = false to use regular grid for speed consideration
useGuidedfilter = true; % You can set useGuidedfilter = true to smooth the image
doMAEEval = true;       % Evaluate MAE measure after saliency map calculation
doPRCEval = true;       % Evaluate PR Curves after saliency map calculation

SRC = fullfile('Data', 'SRC');	% Path of input images
GT  = fullfile('Data', 'GT');   % Path of ground truth
RES = fullfile('Data', 'RES');	% Path for saving saliency maps

srcSuffix = '.jpg';	% suffix for input images
gtSuffix  = '.bmp'; % suffix for ground truth

if ~exist(RES, 'dir'), mkdir(RES); end

%% 2. Saliency Map Calculation
files = dir(fullfile(SRC, strcat('*', srcSuffix)));
% if isempty(gcp)
% 	parpool;
% end

parfor k = 1:length(files)
% for k = 1:length(files)
    disp(k);
    srcName = files(k).name;
    noSuffixName = srcName(1:end - length(srcSuffix));
    
    %% Pre-Processing: Remove Image Frames
    srcImg = imread(fullfile(SRC, srcName));
    if doFrameRemoving
        [noFrameImg, frameRecord] = removeframe(srcImg, 'sobel');
        [h, w, chn] = size(noFrameImg);
    else
        noFrameImg = srcImg;
        [h, w, chn] = size(noFrameImg);
        frameRecord = [h, w, 1, h, 1, w];
    end
    
    if useGuidedfilter
        noFrameImg = imguidedfilter(noFrameImg);
    end
    
    %% create superpixel and graph
    sp_graph_prop = SuperpixelPropertyAndGraph(noFrameImg, useSP, 600, 250);    
    [clipVal, geoSigma, neiSigma] = EstimateDynamicParas(sp_graph_prop.adjcMatrix, sp_graph_prop.colDistM);    
    
    %% Saliency Baseline
    centSigma = min(h, w) / 1000;
	% use the sigmoid function to enhance C_bnd, which achieves better performance but lower speed in large datasets.
	% set useSigmoid = true to achieve the same result as reported in ACCV 2014.
	useSigmoid = false;
    
    baseline = SaliencyBaseline(sp_graph_prop, clipVal, geoSigma, centSigma, useSigmoid);
    smapName = fullfile(RES, strcat(noSuffixName, '_base.png'));
    SaveSaliencyMap(baseline, sp_graph_prop.pixelList, frameRecord, smapName, true);
    
    %% Saliency Optimization    
    geo_prop = GeodesicDistProperty(sp_graph_prop.adjcMatrix, sp_graph_prop.colDistM, sp_graph_prop.bdIds, clipVal, geoSigma, true);
    
    bdConSigma = 1; % sigma for converting bdCon value to background probability
    bgProb = 1 - exp(-geo_prop.bdCon.^2 / (2 * bdConSigma * bdConSigma)); % in [0, 1)
    
    posDistM = GetDistanceMatrix(sp_graph_prop.meanPos);
    wCtr = CalWeightedContrast(sp_graph_prop.colDistM, posDistM, bgProb); % foreground prob
    
    highThresh = 3;
    if 1 % use large weight for very confident bg sps is slightly better
        bgProb(geo_prop.bdCon > highThresh) = 1000;
    end
    optwCtr = SaliencyOptimization(sp_graph_prop.adjcMatrix, sp_graph_prop.bdIds, sp_graph_prop.colDistM, neiSigma, bgProb, wCtr);    
    
    smapName = fullfile(RES, strcat(noSuffixName, '_optwCtr.png'));
    SaveSaliencyMap(optwCtr, sp_graph_prop.pixelList, frameRecord, smapName, true);
    
%     %Uncomment the following lines to save more intermediate results.
%     smapName=fullfile(RES, strcat(noSuffixName, '_wCtr.png'));
%     SaveSaliencyMap(wCtr, sp_graph_prop.pixelList, frameRecord, smapName, true);
%     smapName=fullfile(RES, strcat(noSuffixName,'_bgProb.png'));
%     SaveSaliencyMap(bgProb, sp_graph_prop.pixelList, frameRecord, smapName, false, 1);
% 
%     %Visualize BdCon, for each pixel in the saved image, divide its
%     %intensity by 30 to get its real bdCon value
%     smapName=fullfile(BDCON, strcat(noSuffixName, '_bdCon_toDiv30.png'));
%     SaveSaliencyMap(bdCon * 30 / 255, sp_graph_prop.pixelList, frameRecord, smapName, false);

    %% Saliency Filter
    [cmbVal, contrast, distribution] = SaliencyFilter(sp_graph_prop.colDistM, posDistM, sp_graph_prop.meanPos);
    smapName = fullfile(RES, strcat(noSuffixName, '_SF.png'));
    SaveSaliencyMap(cmbVal, sp_graph_prop.pixelList, frameRecord, smapName, true);    
    % smapName = fullfile(RES, strcat(noSuffixName, '_SF_Distribution.png'));
    % SaveSaliencyMap(distribution, sp_graph_prop.pixelList, frameRecord, smapName, true);    
    % smapName = fullfile(RES, strcat(noSuffixName, '_SF_Contrast.png'));
    % SaveSaliencyMap(contrast, sp_graph_prop.pixelList, frameRecord, smapName, true);
    
    %% Geodesic Saliency
    geoDist = GeodesicSaliency(sp_graph_prop.adjcMatrix, sp_graph_prop.bdIds, sp_graph_prop.colDistM, posDistM, clipVal);
    smapName = fullfile(RES, strcat(noSuffixName, '_GS.png'));
    SaveSaliencyMap(geoDist, sp_graph_prop.pixelList, frameRecord, smapName, true);
    
    %% Manifold Ranking
    [stage2, stage1, bsalt, bsalb, bsall, bsalr] = ManifoldRanking(sp_graph_prop.adjcMatrix, sp_graph_prop.idxImg, sp_graph_prop.bdIds, sp_graph_prop.colDistM);
    smapName = fullfile(RES, strcat(noSuffixName, '_MR_stage2.png'));
    SaveSaliencyMap(stage2, sp_graph_prop.pixelList, frameRecord, smapName, true);
    % smapName = fullfile(RES, strcat(noSuffixName, '_MR_stage1.png'));
    % SaveSaliencyMap(stage1, sp_graph_prop.pixelList, frameRecord, smapName, true);
end

%% 3. Evaluate MAE
if doMAEEval
    CalMeanMAE(RES, '_base.png', GT, gtSuffix);
    CalMeanMAE(RES, '_optwCtr.png', GT, gtSuffix);
    CalMeanMAE(RES, '_SF.png', GT, gtSuffix);
    CalMeanMAE(RES, '_GS.png', GT, gtSuffix);
    CalMeanMAE(RES, '_MR_stage2.png', GT, gtSuffix);
end

%% 4. Evaluate PR Curve
if doPRCEval
    figure, hold on;
    DrawPRCurve(RES, '_base.png', GT, gtSuffix, true, true, 'r');
    DrawPRCurve(RES, '_optwCtr.png', GT, gtSuffix, true, true, 'm');
    DrawPRCurve(RES, '_SF.png', GT, gtSuffix, true, true, 'g');
    DrawPRCurve(RES, '_GS.png', GT, gtSuffix, true, true, 'b');
    DrawPRCurve(RES, '_MR_stage2.png', GT, gtSuffix, true, true, 'k');
    hold off;
    grid on;
    lg = legend({'base'; 'optwCtr'; 'SF'; 'GS'; 'MR'});
    set(lg, 'location', 'southwest');
end