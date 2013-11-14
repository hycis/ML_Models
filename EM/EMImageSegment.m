

function [miu, maskOut] = EMImageSegment(imageDataIn, startMiu, segmentMode)
% This function finds the segmentation for an image
% An image is segmented using EA algorithm
% n_c : number of components
epsilon = 1E-1;

[rows, numOfKernel] = size(startMiu);

imageDataOut = appendRC(imageDataIn);


% imageData(5, i, j), 5 = [R G B r c], i,j is the position
imageData = changeIndex(imageDataOut);

%% initialize weight
% dimension: numOfKernel by 1
weight = ones(numOfKernel, 1) / numOfKernel;


%% dimension: N * M * numOfKernel
[dim,N,M] = size(imageData);
imageData(1:3,:,:) = imageData(1:3,:,:) / 255;
imageData(4,:,:) = imageData(4,:,:) / N;
imageData(5,:,:) = imageData(5,:,:) / M;

% initialize miu
% randMiu = zeros(dim, numOfKernel);
% for c = 1:numOfKernel
%     randMiu(:,c) = imageData(:,randi(20,[1,1]));
% end
% 
% miu = randMiu;

  miu = startMiu / 20;

%% initialize var
var = ones(dim, numOfKernel);


%% while loop
while (true)
    % matrix p_ijc dim: 20 * 20 * numOfKernel
    p = pMatrix(weight, miu, var, imageData, numOfKernel);
    
    % vector n_i dim: numOfKernel * 1
    n = nVector(p, numOfKernel);
    
    % new miu matrix dim: 5 * numOfKernel
    newMiu = miuMatrix(p, imageData, n, numOfKernel);
    
    % new covar dim: 5 * 5 * numOfKernel
    newVar = varMatrix(newMiu, p, imageData, n, numOfKernel);
    
    % new weight dim: numOfKernel * 1
    newWeight = n / (N*M);
    
    
    % use to check the difference between the parameters
    energy = absSumDiff(miu, newMiu, var, newVar, weight, newWeight);
    
    if (energy < epsilon || prod(sum(newVar,1)) == 0)
        energy
        break;
    end
    ,
    miu = newMiu;
    var = newVar;
    weight = newWeight;
end
if segmentMode == 1
    p = segment(p);
end

maskOut = outputMask(p, numOfKernel, miu, N, M);
% randMiu = 20 * randMiu;
miu = 20 * miu;
end

% Segment the image
function p = segment(p)
[N,M,nK] = size(p);

for i = 1:N
    for j = 1:M
        max = 0;
        for c = 1:nK
            if p(i,j,c) > max
                max = p(i,j,c);
            end
        end
        total = 0;
        for c = 1:nK
            if p(i,j,c) < max
                p(i,j,c) = 0;
            end
            total = total + p(i,j,c); 
        end
        p(i,j,:) = p(i,j,:) / total;
    end
end
end



%% matrix p_ijc dim: 20 * 20 * numOfKernel
function p = pMatrix(weight, miu, var, imageData, numOfKernel)
[dim,N,M] = size(imageData);
p = zeros(N, M, numOfKernel);
for i = 1:N
    for j = 1:M
        for c = 1:numOfKernel
            p(i,j,c) = gaussian(imageData(:,i,j), miu(:,c),...
                var(:,c)) * weight(c);
            
        end
    end
end
sumCompEle = sum(p,3);
for c = 1:numOfKernel
    p(:,:,c) = p(:,:,c) ./ sumCompEle;
end
end

%% output the probability of x for a multivariate gaussian
% distribution with x = (R, G, B, row, col) and miu(:,c) and
% covar(:,:,c)
function px = gaussian(x, miu_c, var_c)
v = x - miu_c;
varSum = sum(var_c)/length(x);
px = 1/sqrt(2*pi()*varSum)*exp(-0.5*(v'*v)/varSum);
end

%% vector n_i dim: numOfKernel * 1
function n = nVector(p, numOfKernel)
n = zeros(numOfKernel, 1);
for c = 1:numOfKernel
    temp = p(:,:,c);
    n(c) = sum(temp(:));
end
end

%% new miu matrix dim: 5 * numOfKernel
function miu = miuMatrix(p, imageData, n, numOfKernel)
[dim, N, M] = size(imageData);
miu = zeros(dim, numOfKernel);
for c = 1:numOfKernel
    for i = 1:N
        for j = 1:M
            miu(:,c) = miu(:,c) + p(i,j,c) * imageData(:,i,j);
        end
    end
    miu(:,c) = miu(:,c) / n(c);
end
end

%% new covar dim: 5 * numOfKernel
function var = varMatrix(miu, p, imageData, n, numOfKernel)
[dim, N, M] = size(imageData);
var = zeros(dim, numOfKernel);
for c = 1:numOfKernel
    for i = 1:N
        for j = 1:M
            var(:,c) = var(:,c) + p(i,j,c) * (imageData(:,i,j)-miu(:,c)).^2;
        end
    end
    var(:,c) = var(:,c) / n(c);
end

end

%% find the absolute difference for two matrix or vector
% then sum all the elements
function total = absSumDiff(miu, newMiu, var, newVar, weight, newWeight)
d1 = miu - newMiu;
d2 = var - newVar;
d3 = weight - newWeight;
total = sum(abs(d1(:))) + sum(abs(d2(:))) + sum(abs(d3(:)));
end

%% append row and col value to the vector value R, G, B
% to make it x = (R, G, B, row, col)
function imageDataOut = appendRC(imageDataIn)
for i=1:20
    for j=1:20
        imageDataIn(i,j,4) = i;
        imageDataIn(i,j,5) = j;
    end
end
imageDataOut = imageDataIn;
end

%% change index of imageData(i, j, 5) to imageData(5, i, j)
function output = changeIndex(imageData)
[N,M,dim] = size(imageData);
output = zeros(dim, N, M);
for i = 1:N
    for j = 1:M
        for k = 1:dim
            output(k,i,j) = imageData(i,j,k);
        end
    end
end
end

function maskOut = outputMask(p, numOfKernel, miu, N, M)
maskOut = zeros(N,M,3);
for i = 1:N
    for j = 1:M
        for c = 1:numOfKernel
            maskOut(i,j,1) = maskOut(i,j,1) + p(i,j,c)*miu(1,c);
            maskOut(i,j,2) = maskOut(i,j,2) + p(i,j,c)*miu(2,c);
            maskOut(i,j,3) = maskOut(i,j,3) + p(i,j,c)*miu(3,c);
            
        end
    end
end
end

