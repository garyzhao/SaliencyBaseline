function geo_prop = GeodesicDistProperty(adjcMatrix, weightMatrix, bdIds, clipVal, geo_sigma, link_boundary)
% Compute geodesic distance related properties for a superpixel graph
% [geo_prop] = GeodesicDistProperty(adjcMatrix, weightMatrix, bdIds, clipVal, geo_sigma, link_boundary)
%
% Input
% adjcMatrix, weightMatrix: the superpixel graph
% bdIds: superpixel on image boundary
% clipVal: threshold for clipping the weightMatrix
% geo_sigma: convert geodesic distance to geodesic similarity
% link_boundary: if 1, link all superpixels on the image boundary, otherwise not
%
% Output: a struct geo_prop with all properties
% geoDistM: superpixel pair-wise geodesic distances
% geoSimM: converted from geoDistM
% bdCon, Len_bnd, Area: soft area, length on boundary, and boundary connectivity values for superpixels

if (nargin < 6)
    link_boundary = false;
end

if link_boundary
    geo_prop.geoDistM = AllShortestDistance(adjcMatrix, weightMatrix, clipVal, bdIds);
else
    geo_prop.geoDistM = AllShortestDistance(adjcMatrix, weightMatrix, clipVal);
end

geo_prop.geoSimM = Dist2WeightMatrix(geo_prop.geoDistM, geo_sigma);

geo_prop.Len_bnd = sum(geo_prop.geoSimM(:, bdIds), 2); %length of perimeters on boundary
geo_prop.Area = sum(geo_prop.geoSimM, 2);    % soft area
geo_prop.bdCon = geo_prop.Len_bnd ./ sqrt(geo_prop.Area);