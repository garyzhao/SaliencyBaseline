function weightMatrix = Dist2WeightMatrix(distMatrix, distSigma, distIsSquared)
% Transform pair-wise distance to pair-wise weight using
% exp(-d^2/(2*sigma^2));

% Code Author: Wangjiang Zhu
% Email: wangjiang88119@gmail.com
% Date: 3/24/2014

if nargin < 3
    distIsSquared = false;
end

spNum = size(distMatrix, 1);

if distIsSquared
    distSigma2 = distSigma^2;
    distMatrix(distMatrix > 9 * distSigma2) = Inf;
    weightMatrix = exp(-distMatrix ./ (2 * distSigma2));    
else
    distMatrix(distMatrix > 3 * distSigma) = Inf;   %cut off > 3 * sigma distances
    weightMatrix = exp(-distMatrix.^2 ./ (2 * distSigma * distSigma));   
end

if any(1 ~= weightMatrix(1:spNum+1:end))
    error('Diagonal elements in the weight matrix should be 1');
end