



function zci=SSP(ci,ci_boot,sigma)
% This function do multiple regression between DV  Smooth, Standardize and padd a classification image from
% a single bootstrap
%
%   the 2D original classification image matrix (ci).
%   Size is the same as your bubble or noise mask, usually a
%   128x128 matrix.
%
%
%   ARG 2: the randomly permuted classification image, or
%   bootstrap (ci_boot), same size as ci. Use
%
%   inputArg2: A string that specifies the name of the noise function
%   that was used to generate the bubbles masks.
%
%   outputArg1: The classification image.
%
%   outputArg1: A happy sentence to cheer you up.
%
%
%
%   EXAMPLE:
%
%       % If you are kind enough, you could give an example of how to use your function
%       N = 1000;
%       M = 128*128;
%       mask = rand(N,M);
%       [outputArg1, outputArg2] = headerTemplate(mask, 'noiseFunction.m')
%
%
%   TAGS: CIs, CI, classification images, build CI, bubbles,
%   experiment, etc.
%
%
%
%   Author:     Nicolas Dupuis-Roy
%   Date:       25 septembre 2015
%   Version:    1
%   Tested by:  Frederic Gosselin
%
%
%   See also other_related_function_1 other_related_function_2 headerTemplate


b= y * X ;
b_2D = reshape(b, sizeX, sizeX);

% Bootstrapping the accuracry vector.
index = ceil(size(y,2)*rand(size(y))); % with replacement
b_boot = y(index) * X;
b_boot_2D = reshape(b_boot, sizeX, sizeX);


temp = mean(b_boot_2D(:));
sb_boot_2D = SmoothCi(b_boot_2D-temp, sigma)+temp;
temp = mean(b_2D(:));
sb_2D = SmoothCi(b_2D-temp, sigma)+temp;
zsb_2D = (sb_2D-mean(sb_boot_2D(masque==1)))/std(sb_boot_2D(masque==1));




%  Smooth, Standardize & Padd Cis
i= load('images.mat');

sci=SmoothCi(ci,sigma);
sci_boot=SmoothCi(ci_boot,sigma);

zci = (sci - mean(sci_boot(i.masque==1))) / std(sci_boot(i.masque==1));

% zci= padarray(zci,[128 128], 'symmetric');
% zci= zci(128:255,128:255);



end