function Ci = buildCi4(cid, predVarT, incCriteria)
% BUILDCI Performs least-square multiple linear regression on the sampling noise
% 	(explanatory variable) rebuilt using the function contained in the noise input
% 	string and saved in a temporary M-file named MAKETHENOISE; and the elements of
% 	the data input matrix (i.e., trials) satisfying two conditions (predictive
% 	variable): (1) belonging to a column identified in the predVar vector (e.g.,
% 	predVar = [8, 10]) and (2) verifying the Boolean inclusion criterias specified
% 	in the cell of strings incCriteria. In incCriteria, the expression 'data(n,:)'
% 	refers to the nth data column.
% 		E.g., [data, origins, info, noise, dataLabels] = readCid('AGBTSD04.cid');
% 			  incCriteria{1} = 'C2==1'; %2nd data columns = 1
% 			  incCriteria{2} = '(C2==1)&(C3==1)'; %2nd and 3rd data columns = 1
%	 		  predVar = [8, 10];

%             change predVar to make it perfectly harmonious with incCriteria

% 			  [Ci, nbIncluded] = buildCi3(cid, predVar, incCriteria);
%
%	BUILDCI goes through all of the data input matrix. Therefore, you should only pass to
% 	this function the portion of the data input matrix that satisfies to the union of all
% 	inclusion criteria. Both NOISE and data are outputs of the READCID function. If predVar
% 	has m elements and incCriteria contains n elements, m * n classification images are computed.
% 	The Ci output matrix contains them all; it has a size of d_1 * ... * d_z * m * n, where
% 	d_x give the number of elements in dimension x, z is the number of dimensions of the
% 	sampling noise, m is the number of elements in the predVar vector and n the number of
% 	strings in the incCriteria input cell. The number of trials used to build Ci is outputed
% 	in the scalar nbIncluded. The elements of the Ci are Z-scores.
%

%   It Z-scores everything as follows: xxx...

%	Importantly, it is assumed that the sampling noise is uncorrelated between trials.
%	This is true if the sampling noise is random. Least-square multiple regression then
%	becomes Ci = ky'X, where Ci is a vectorized classification image, k is a scalar, y
%	is a predictive variable vector, and X is a explanatory variable matrix. Up to the
% 	k factor, this amounts to summing all sampling noise matrices multiplied by their
% 	predictive variable values.
%
% See also READCID, DEMO4CI
%
% The Stat4Ci toolbox is free (http://mapageweb.umontreal.ca/gosselif/stat4ci.html); if you use
% it in your research, please, cite us:
%	Chauvin, A., Worsley, K. J., Schyns, P. G., Arguin, M. & Gosselin, F. (2004).  A sensitive
%	statistical test for smooth classification images.
%
% Fr�d�ric Gosselin (frederic.gosselin@umontreal.ca), 10/03/2007

% to do: test of z-scoring with noise + something already analyzed
% to do: rewrite the help section (requires bwlabel from the image processing toolbox)

% Inits
noise = cid.noise;
constants = cid.constants;
eval(constants);
data = cid.data;
dataLabels = cid.dataLabels;
[nbColumns, nbTrials] = size(data);
nbPredVar = length(predVarT);
[nothing, nbIncCriteria] = size(incCriteria);

%%%%%%%
eval(sprintf('makeTheNoise = @%s;', noise)); % N. Dupuis changed to handle function
% %%%%%%
% id = fopen('makeTheNoise.m', 'w');
% fprintf(id, '%s', noise);
% fclose(id);





adfsljhsdgvoailsfhueiq;




% Constructs the criteriaMet matrix
criteriaMet = zeros(nbIncCriteria, nbTrials);
for whichIncCriteria = 1:nbIncCriteria,
    outputStr = incCriteria{whichIncCriteria};
    for ii = nbColumns:-1:1,
        outputStr = replaceStr(outputStr, sprintf('C%d',ii), sprintf('data(%d,:)',ii));
        outputStr = replaceStr(outputStr, dataLabels{ii}, sprintf('data(%d,:)',ii));
    end
    criteriaMet(whichIncCriteria, :) = eval(outputStr);
end
sum(criteriaMet)


% Constructs the predictive variables' vector
predVar = zeros(1, nbPredVar);
for whichPredVar = 1:nbPredVar,
    outputStr = predVarT{whichPredVar};
    for ii = nbColumns:-1:1,
        outputStr = replaceStr(outputStr, sprintf('C%d',ii), sprintf('%d',ii));
        outputStr = replaceStr(outputStr, dataLabels{ii}, sprintf('%d',ii));
    end
    predVar(whichPredVar) = eval(outputStr);
end

% Selects all the trials needed for the computations
index = ge(sum(criteriaMet, 1), 1);
lIndex = bwlabel(index);
nbSeg = max(lIndex);
newIndex = index;
collapsed = ge(sum(eq(data, -99), 1), 1);
for ii = 1:nbSeg,
    temp = eq(lIndex, ii);
    toto = find(temp);
    ind = toto(1);
    for ind = ind:-1:1,
        if collapsed(ind) == 1,
            newIndex(ind) = 1;
        elseif collapsed(ind) == 0,
            newIndex(ind) = 1;
            break;
        end
        if ind == 1,
            error('No seed provided.')
        end
    end
end
data = data(:, eq(newIndex, 1));
nbTrials = size(data, 2);
criteriaMet = criteriaMet(:, eq(newIndex, 1));

% Inits the Ci cell
whichTrial = 1;
oneTrial = data(:,whichTrial);
theNoise = makeTheNoise(oneTrial);
nbCi = length(theNoise);
Ci = cell(nbCi, nbPredVar, nbIncCriteria);
for whichCi = 1:nbCi,
    for whichPredVar = 1:nbPredVar,
        for whichIncCriteria = 1:nbIncCriteria,
            Ci{whichCi, whichPredVar, whichIncCriteria} = zeros(size(theNoise{whichCi}));
        end
    end
end
grandMeans = zeros(nbCi, nbPredVar, nbIncCriteria);
grandVars = zeros(nbCi, nbPredVar, nbIncCriteria);


% Computes the independent Ci's
fprintf('\n0%%');
for whichTrial = 1:nbTrials,
    back = '\b';
    nbBack = length(num2str(round(100*(whichTrial-1)/nbTrials)));
    for ii = 1:nbBack, back = [back, '\b']; end
    eval(sprintf('fprintf(''%s%d%s'');', back, round(100*whichTrial/nbTrials),'%%'));
    oneTrial = data(:,whichTrial);
    theNoise = makeTheNoise(oneTrial);
    for whichIncCriteria = 1:nbIncCriteria,
        if(criteriaMet(whichIncCriteria, whichTrial))
            for whichPredVar = 1:nbPredVar,
                for whichCi = 1:nbCi,
                    Ci{whichCi, whichPredVar, whichIncCriteria} = Ci{whichCi, whichPredVar, whichIncCriteria} + oneTrial(predVar(whichPredVar)) * theNoise{whichCi};
                    grandMeans(whichCi, whichPredVar, whichIncCriteria) = grandMeans(whichCi, whichPredVar, whichIncCriteria) + oneTrial(predVar(whichPredVar)) * mean(theNoise{whichCi}(:));
                    grandVars(whichCi, whichPredVar, whichIncCriteria) = grandVars(whichCi, whichPredVar, whichIncCriteria) + (oneTrial(predVar(whichPredVar)) * std(theNoise{whichCi}(:)))^2;
                end
            end
        end
    end
end

% Z-scores the independent Ci's
for whichIncCriteria = 1:nbIncCriteria,
    for whichPredVar = 1:nbPredVar,
        for whichCi = 1:nbCi,
            Ci{whichCi, whichPredVar, whichIncCriteria}	= (Ci{whichCi, whichPredVar, whichIncCriteria} - grandMeans(whichCi,whichPredVar,whichIncCriteria)) / sqrt(grandVars(whichCi,whichPredVar,whichIncCriteria));
        end
    end
end




%---------------------------------------------------------------
%---------------------------------------------------------------
function outputStr = replaceStr(inputStr, findThis, changeFor)
index = findstr(findThis, inputStr);
NN = length(index);
m1 = length(findThis);
m2 = length(changeFor);
inSize = length(inputStr);
index(NN+1) = inSize+1;
if(index(1)~=1)
    outputStr(1:index(1)-1) = inputStr(1:index(1)-1);
end
for ii = 1:NN,
    jj1 = index(ii);
    jj2 = index(ii+1);
    temp = inputStr(jj1+m1:jj2-1);
    pp = length(temp);
    kk = (ii-1) * m2 + (jj1 - (ii - 1) * m1);
    outputStr(kk:kk+m2-1) = changeFor;
    outputStr(kk+m2:kk+m2+pp-1) = temp;
end
