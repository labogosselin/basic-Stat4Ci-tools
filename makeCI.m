function paddedZci = makeCI(y,X,sigma)


% Create a zscored Classification Image (CI) by performing multiple regression between an explanatory variable (y) and a noise matrix (X).
% The CI is Smoothed , Standardized and Padded.
%
%   ARG1: Explanatory variable for the multiple regression, usually accuracy
%   vector. Size is the number of trials.
%
%   ARG 2: Dependant variable for multiple regression, here the pixels
%   revealed at a given trial (multiplicative noise) by a bubbled mask,
%   usually a 128x128 matrix.
% 
% 
% 
% 

%%%%%%%%%%%%%%%%%

% %Load masque
i= load ('images.mat');

sizeX= sqrt(size(X,2));

%standardize the EV vector
y  = (y - mean(y)) / std(y);


% Multiple linear regression between EV and DV
b = y * X ;
b_2D = reshape(b, sizeX, sizeX);


% Bootstrapping the accuracry vector.
index = ceil(size(y,2)*rand(size(y))); % with replacement
b_boot = y(index) * X;
b_boot_2D = reshape(b_boot, sizeX, sizeX);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Smooth, Standardize & Padd Ci
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Substract mean to counter the smoothing effect ci's values.
temp = mean(b_boot_2D(:));
sb_boot_2D = SmoothCi(b_boot_2D-temp, sigma)+temp;

temp = mean(b_2D(:));
sb_2D = SmoothCi(b_2D-temp, sigma)+temp;

% Standardize smoothed CI
zci = (sb_2D-mean(sb_boot_2D(i.masque==1)))/std(sb_boot_2D(i.masque==1));

%Padding zci.
zci= padarray(zci,[128 128], 'symmetric');
paddedZci= zci(128:255,128:255);


end





