function [F, P, R] = CalMeanWFb(SRC, srcSuffix, GT, gtSuffix)

files = dir(fullfile(SRC, strcat('*', srcSuffix)));

if isempty(files)
    error('No saliency maps are found: %s\n', fullfile(SRC, strcat('*', srcSuffix)));
end

F = zeros(length(files), 1);
P = zeros(length(files), 1);
R = zeros(length(files), 1);

parfor k = 1:length(files)
    srcName = files(k).name;
    srcImg = imread(fullfile(SRC, srcName));
    
    gtName = strrep(srcName, srcSuffix, gtSuffix);
    gtImg = imread(fullfile(GT, gtName));
    
    [Fw, Pw, Rw] = CalWFb(srcImg, gtImg);
    
    F(k) = Fw; P(k) = Pw; R(k) = Rw; 
end

F = mean(F); P = mean(P); R = mean(R);

fprintf('WFb for %s: F/P/R - %f/%f/%f\n', srcSuffix, F, P, R);