%I suggest to always look at the t-sne output (color coded with 3D
%orientation) and the centroid images (average of all images in the cluster)
%in order to check if clustering parameters give reasonable clustering
%as orientation provides much of the variation in appearance. 

globals
%%
%Next, go through each sample, resize, collect, extract features.
%Next implment the above in one step, so don't need to collect samples?
padszx = 10; padszy = 10;
ftsopts.color.enabled = 1;
ftsopts.grad.enabled = 1;
ftsopts.grad.bsize = 6;
defts = chnsCompute;
defts.pColor.colorSpace = 'luv';
X = [];

%Obtrain resize parameters
rszdim = [];
objlist = load('objlist.mat');
objlist = objlist.objlist; %format is alpha x y w h
clust_ar = [];
rszdim = [mean(objlist(:,4)) mean(objlist(:,5))]./2;

s_f = 0; e_f = 7480; %Train on the entire training dataset
allidx = s_f:e_f;

posfts = cell(1,length(allidx));

parfor i=allidx
    disp([num2str(i) ' Out of ' num2str(length(allidx))]);
    
    currfts = []; sample_c=1; %Hold samples in current image
    
    train_objects = readLabels(rootlabels,i);
    
    I = imread(sprintf('%s/%06d.png',rootims,i));
    Ipad = padarray(I, [padszy padszx],'replicate');
    %%
    for obj_i = 1:length(train_objects);
        %%
        currbb = [train_objects(obj_i).x1 train_objects(obj_i).y1 train_objects(obj_i).x2 train_objects(obj_i).y2];
        currbb(currbb<1)=1;
        currbb = round(currbb);
        
        if(sum(strcmp(train_objects(obj_i).type,labels))>0 ...
                && currbb(1,4)>minboxheight ...
                && sum(train_objects(obj_i).occlusion==occlusionLevel)>0 ...
                &&  train_objects(obj_i).truncation <= Maxtruncation)
            
            %Get sample
            Icurr = Ipad(currbb(2):currbb(4)+2*padszy,currbb(1):currbb(3)+2*padszx,:);
            
            %Resize
            Icurr = imResample(Icurr,rszdim);
            Icurr = rgbConvert(Icurr,defts.pColor.colorSpace); Icurr=convTri(Icurr,defts.pColor.smooth);

            currft = [];
            if(ftsopts.color.enabled)
                currft = [currft Icurr(:)'];
            end
            
            if(ftsopts.grad.enabled)
                [M,O]=gradientMag(Icurr,defts.pGradMag.colorChn,defts.pGradMag.normRad,defts.pGradMag.normConst,defts.pGradMag.full);
                h=gradientHist(M,O,ftsopts.grad.bsize,defts.pGradHist.nOrients,defts.pGradHist.softBin,defts.pGradHist.useHog,defts.pGradHist.clipHog,defts.pGradMag.full);
                currft = [currft M(:)' h(:)'];
            end
            
            currfts(sample_c,:)=currft;sample_c=sample_c+1;
            
        else
            %Ignore
        end
    end
    
    posfts{i+1} = currfts;
end
%%
%Feature matrix
X = cat(1,posfts{:}); clear posfts
%%
%Cluster either using k-means or spectral clustering. Spectral clustering
%gives significant improvement when parameters are carefully tuned.

%[X]= rescaleData(X,0,1);
%PCA may make things quicker
X = [preprocessPCA(rescaleData([X],0,1),50)]; %[preprocessPCA(rescaleData([d_tr(:,:)],0,1),50,0.98)];
%%
clustnum = 20; 
prm.minCl = 20; %minimum cluster size
rand('state',0) %For reproducibility
tic
[ clustlabels, centers, ~ ] = kmeans2( X, clustnum, prm);
toc
%%
%Warning, slower and requires a lot of memory - but better performance than kmeans. 
rand('state',0)
clusparams = []; clusparams.numclust = clustnum;  
clusparams.sigma = 1; %try to increase/decrease if there's an error with ARPACK
tic
[ clustlabels , centers ] = spectralCluster(X , clusparams);
toc
%%
%TODO NEXT:
%It's up to you to write a routine for assigning cluster labels in the
%dataset construction (current example uses alpha orientation).
%You can write each sample cluster ID to file, and read appropriately in the
%writePiotrFormat.m script (i.e. by sample number or frame number) instead
%of 3D orientation.

