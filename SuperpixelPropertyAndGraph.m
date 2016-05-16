function sp_graph_prop = SuperpixelPropertyAndGraph(img, useSP, pixNumInSP, minSPNum)
% compute superpixel properties and the graph
if nargin < 3
    pixNumInSP = 600; % pixels in each superpixel (200 for 300*400 resolution image)
end

if nargin < 4
    minSPNum = 0; % minimum superpixel number for each image
end

[sp_graph_prop.height, sp_graph_prop.width, chn] = size(img);

%% Segment input rgb image into patches (SP/Grid)
spnumber = round(sp_graph_prop.height * sp_graph_prop.width / pixNumInSP); % super-pixel number for current image
spnumber = max(spnumber, minSPNum);
if useSP
    [sp_graph_prop.idxImg, sp_graph_prop.adjcMatrix, sp_graph_prop.pixelList] = SLIC_Split(img, spnumber);
else
    [sp_graph_prop.idxImg, sp_graph_prop.adjcMatrix, sp_graph_prop.pixelList] = Grid_Split(img, spnumber);
end

[sp_graph_prop.bdIds, sp_graph_prop.topBdIds, sp_graph_prop.botBdIds, sp_graph_prop.lefBdIds, sp_graph_prop.rigBdIds] = GetBndPatchIds(sp_graph_prop.idxImg);

%% Get super-pixel color distances
sp_graph_prop.meanRgbCol = GetMeanColor(img, sp_graph_prop.pixelList);
sp_graph_prop.meanLabCol = colorspace('Lab<-', double(sp_graph_prop.meanRgbCol) / 255);
sp_graph_prop.colDistM = GetDistanceMatrix(sp_graph_prop.meanLabCol);

%% mean pos
sp_graph_prop.meanPos = GetNormedMeanPos(sp_graph_prop.pixelList, sp_graph_prop.height, sp_graph_prop.width);