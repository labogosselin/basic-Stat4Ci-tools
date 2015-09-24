function zci=SSP(ci,ci_boot,sigma)
%  Smooth, Standardize & Padd Cis
i= load('images.mat');

zci=SmoothCi(ci,sigma);

zci = (ci - mean(ci_boot(i.masque==1))) / std(ci_boot(i.masque==1));

zci= padarray(zci,[128 128], 'symmetric');
zci= zci(128:255,128:255);



end