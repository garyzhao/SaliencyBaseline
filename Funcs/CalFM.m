function [fm, prec, rec] = CalFM(smapImg, gtImg, beta_2)

smapImg = smapImg(:, :, 1);
if nargin < 3, beta_2 = 0.3; end
if ~islogical(gtImg), gtImg = gtImg(:, :, 1) > 128; end

if any(size(smapImg) ~= size(gtImg))
    error('saliency map and ground truth mask have different size');
end

gtPxlNum = sum(gtImg(:));
if 0 == gtPxlNum
    error('no foreground region is labeled');
end

targetHist = histc(smapImg(gtImg), 0:255);
nontargetHist = histc(smapImg(~gtImg), 0:255);

targetHist = flipud(targetHist);
nontargetHist = flipud(nontargetHist);

targetHist = cumsum( targetHist );
nontargetHist = cumsum( nontargetHist );

prec = targetHist ./ (targetHist + nontargetHist);
rec = targetHist / gtPxlNum;
fm = (1 + beta_2) .* prec .* rec ./ (beta_2 .* prec + rec);

fm(~isfinite(fm)) = 0; fm = flipud(fm);
prec(~isfinite(prec)) = 0; prec = flipud(prec);
rec(~isfinite(rec)) = 0; rec = flipud(rec);