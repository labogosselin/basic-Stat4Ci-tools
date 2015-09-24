function zci=SSP(ci,ci_boot,sigma)
%  Smooth, Standardize & Padd Cis
i= load('images.mat');

sci=SmoothCi(ci,sigma);
sci_boot=SmoothCi(ci_boot,sigma);

zci = (sci - mean(sci_boot(i.masque==1))) / std(sci_boot(i.masque==1));

zci= padarray(zci,[128 128], 'symmetric');
zci= zci(128:255,128:255);



end