function [img] = imguidedfilter(img)

I = double(img) / 255;
r = 2;          % try r = 2, 4, or 8
eps = 0.1^2;	% try eps = 0.1^2, 0.2^2, 0.4^2

[h, w, chn] = size(I);
q = zeros([h, w, chn]);
if chn == 1
    q(:, :, 1) = guidedfilter(I(:, :, 1), I(:, :, 1), r, eps);
else
    q(:, :, 1) = guidedfilter(I(:, :, 1), I(:, :, 1), r, eps);
    q(:, :, 2) = guidedfilter(I(:, :, 2), I(:, :, 2), r, eps);
    q(:, :, 3) = guidedfilter(I(:, :, 3), I(:, :, 3), r, eps);
end
img = im2uint8(q);

