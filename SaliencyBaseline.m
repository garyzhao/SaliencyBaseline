function res = SaliencyBaseline(sp_graph_prop, clipVal, geoSigma, centSigma, useSigmoid)

% Code Author: Long Zhao
% Email: gary.zhao9012@gmail.com
% Date: 2014/11/25

if nargin < 5
    useSigmoid = false;
end

geoDistMatrix = AllShortestDistance(sp_graph_prop.adjcMatrix, sp_graph_prop.colDistM, clipVal);
WGeo = Dist2WeightMatrix(geoDistMatrix, geoSigma);

if useSigmoid % use the sigmoid function to enhance C_bnd, which achieves better performance but lower speed.
    alpha = 0.5; mu = 15;    
    sigmDistM = exp(alpha * (sp_graph_prop.colDistM - mu)) ./ (1 + exp(alpha * (sp_graph_prop.colDistM - mu))); 
    bndDistMatrix = AllShortestDistance(sp_graph_prop.adjcMatrix, sigmDistM, 0); % recompute sigmoid weighted distance matrix 
    nthr = 4;
    epsGeo = exp(alpha * (0 - mu)) ./ (1 + exp(alpha * (0 - mu)));
else
    bndDistMatrix = geoDistMatrix;
    nthr = 2;
    epsGeo = 0.1;
end

T_geo = min(bndDistMatrix(:, sp_graph_prop.topBdIds), [], 2) + epsGeo;
B_geo = min(bndDistMatrix(:, sp_graph_prop.botBdIds), [], 2) + epsGeo;
L_geo = min(bndDistMatrix(:, sp_graph_prop.lefBdIds), [], 2) + epsGeo;
R_geo = min(bndDistMatrix(:, sp_graph_prop.rigBdIds), [], 2) + epsGeo;
C_bnd = nthroot(T_geo .* B_geo .* L_geo .* R_geo, nthr);

centDist = sum((0.5 - sp_graph_prop.meanPos) .^ 2, 2);
C_gau = exp(-centDist ./ (2 * (centSigma ^ 2)));
SC_gau = WGeo * C_gau ./ sum(WGeo, 2);

Area = sum(WGeo, 2);

res = SC_gau .* C_bnd .* nthroot(Area, 2);

end