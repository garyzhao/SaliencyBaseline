function [bdIds, topBdIds, botBdIds, lefBdIds, rigBdIds] = GetBndPatchIds(idxImg, thickness)
% Get super-pixels on four sides of image boundary
% idxImg is an integer image, values in [1..spNum]
% thickness means boundary band width

% Code Author: Long Zhao
% Email: gary.zhao9012@gmail.com
% Date: 2014/4/5

if nargin < 2
    thickness = 8;
end

topBdIds = unique(idxImg(1:thickness, :));
botBdIds = unique(idxImg(end - thickness + 1:end, :));
lefBdIds = unique(idxImg(:, 1:thickness));
rigBdIds = unique(idxImg(:, end - thickness + 1:end));

bdIds = unique([topBdIds; botBdIds; lefBdIds; rigBdIds]);