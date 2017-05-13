function [ mincenter,centers ] = spectralCluster( data,clusparams )
%data should be m by n where m is number of samples and n is number of
%features. 

sigma = clusparams.sigma; %wrong clusering means this may be too high. try 0.3. 2
num_clusters = clusparams.numclust; %number of clusters also effect ARPACK
[data, ~, ~] = rescaleData(data,0,1);
data(isnan(data))=0;

S1S2 =-2*squareform(pdist(data,'Euclidean')); %Can try LCSS and DTW like brendan
A = exp(- ((S1S2).^2) / (2 * sigma^2));
D = diag(1 ./ sqrt(sum(A, 2)));
Lap = D * A * D;

warning('off');
[X, D] = eigs(Lap, num_clusters);
warning('on');
Y = X ./ repmat(sqrt(sum(X.^2, 2)), 1, num_clusters);
[ mincenter, centers, ~ ] = kmeans2( Y, num_clusters); 
end


