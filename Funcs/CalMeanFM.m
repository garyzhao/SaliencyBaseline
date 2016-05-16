function [meanFM, meanPRECISION, meanRECALL] = CalMeanFM(SRC, srcSuffix, GT, gtSuffix, K)

files = dir(fullfile(SRC, strcat('*', srcSuffix)));
if nargin < 5, K = 2; end
% if nargin < 5, K = 1.5; end
if isempty(files)
    error('No saliency maps are found: %s\n', fullfile(SRC, strcat('*', srcSuffix)));
end

ALLFM = zeros(length(files), 1);
ALLPRECISION = zeros(length(files), 1);
ALLRECALL = zeros(length(files), 1);

parfor k = 1:length(files)
    srcName = files(k).name;
    srcImg = imread(fullfile(SRC, srcName));
    
    gtName = strrep(srcName, srcSuffix, gtSuffix);
    gtImg = imread(fullfile(GT, gtName));
    
    [h, w, ~] = size(srcImg);
    th = K .* sum(srcImg(:)) ./ (h * w);
    th = min(256, round(th) + 1);
    
    [F, P, R] = CalFM(srcImg, gtImg);
    
    ALLFM(k) = F(th);
    ALLPRECISION(k) = P(th);
    ALLRECALL(k) = R(th);
end

meanFM = mean(ALLFM);
meanPRECISION = mean(ALLPRECISION);
meanRECALL = mean(ALLRECALL);

fprintf('FM for %s: P/R/F - %f/%f/%f\n', srcSuffix, meanPRECISION, meanRECALL, meanFM);