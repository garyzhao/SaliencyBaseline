function [geoDistMatrix] = AllShortestDistance(adjcMatrix, weightMatrix, clipVal, bdIds)

if (nargin >= 4)
    adjcMatrix = LinkBoundarySPs(adjcMatrix, bdIds);
end

adjcMatrix = tril(adjcMatrix, -1);
edgeWeight = weightMatrix(adjcMatrix > 0);
edgeWeight = max(0, edgeWeight - clipVal);

% Cal pair-wise shortest path cost (geodesic distance)
geoDistMatrix = graphallshortestpaths(sparse(adjcMatrix), 'directed', false, 'Weights', edgeWeight);