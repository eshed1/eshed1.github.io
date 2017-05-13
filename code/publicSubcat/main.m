%If you find the code useful, please cite the associated CVPRW
%paper as well as Piotr's papers.
% @inproceedings{ohnbar14,
% title={Fast and Robust Object Detection Using Visual Subcategories},
% author={Eshed Ohn-Bar and Mohan M. Trivedi},
% booktitle={Computer Vision and Pattern Recognition Workshops-Mobile Vision},
% year={2014}
% }

%and/or

% @ARTICLE{vehicles_TITS15, 
%  author={E. Ohn-Bar and M. M. Trivedi}, 
%  journal={IEEE Transactions on Intelligent Transportation Systems}, 
%  title={Learning to Detect Vehicles by Clustering Appearance Patterns}, 
%  year={2015}, 
% }

%%
%Step 1: Set paths/training settings

% Call writePiotrFormat once to setup dataset.

globals

%% Step 3: get model dimensions from pre-collected object statistics
objlist = load('objlist.mat');
objlist = objlist.objlist; %format is alpha x y w h

[labelsquant,anglelist] = quantizeAngles(objlist(:,1),B);
clust_ar = [];
for i_clust =1:B
    aspectsr =objlist(labelsquant==i_clust,5)./objlist(labelsquant==i_clust,4);
    clust_ar(i_clust)=[median(aspectsr)];
end

%% Step 4: Train
 
resHgt = [26 32 48];

for res = 1:3
    xx=resHgt(res);
    for ori_i = 1:B
        yy = round(xx*clust_ar(ori_i));
        opts=acfTrain();
        
        opts.pBoost.discrete = 0;
        opts.name=[resDir '/model' sprintf('%02d',ori_i + (res-1)*B)];
        opts.posGtDir=[dataDir '/train/annotations'];
        opts.posImgDir=[dataDir '/train/images'];
        
        opts.modelDs=[xx yy];
        opts.modelDsPad = round(opts.modelDs+opts.modelDs/8);
        
        opts.nWeak=[32 128 512 2048]; opts.pBoost.pTree.fracFtrs=1/16;
        opts.pNms.overlap = 0.3;
        %%
        inclustlabels = [];
        for k=ori_i
            inclustlabels{end+1} = sprintf('car%02d',mod(k-1,B)+1);
        end

        allBs = 1:B;  allBs(ori_i) = [];
        outclustlabels = [];
        for j_B = 1:length(allBs); outclustlabels{j_B} = sprintf('car%02d',allBs(j_B)); end;
        outclustlabels{end+1} = 'ig';
        opts.pLoad={ 'lbls', inclustlabels,'ilbls',outclustlabels,'squarify',[]};
        %%
        opts.pJitter=struct('flip',0); opts.pNms.ovrDnm = 'union';
        opts.pPyramid.pChns.pGradHist.softBin=0;
        opts.pPyramid.pChns.pColor.smooth=0;
        opts.pBoost.pTree.maxDepth=2;
        opts.pPyramid.pChns.shrink=2; %2 or 4. 2 gives better accuracy. 4 is fast.
        opts.nNeg = 5000; opts.nAccNeg = 10000; opts.nPerNeg = 25;
        
        [gt,~] = bbGt('loadAll',opts.posGtDir,[],opts.pLoad);
        imgNms = bbGt('getFiles',{opts.posImgDir});
        
        detector = acfTrain_subcat(opts);

    end
end

%% Load trained detectors.
clear detector;
opts = []; opts.pNms.type  = 'maxg'; opts.pNms.ovrDnm  = 'union';  opts.pNms.overlap = 0.3;
for ori_i = 1:3*B
    currname=[resDir '/model' sprintf('%02d',ori_i)];
    currdet = load([currname 'Detector.mat']);
    currdet = acfModify(currdet.detector,'cascThr',-10,'pNms', opts.pNms);
    currdet.opts.pPyramid.nApprox = 9;
    currdet.opts.pPyramid.nPerOct=10;
    detector{ori_i} = currdet;
end
detName =[resDir 'subcat+Detector.mat'];
save(detName,'detector');
detName = [resDir 'subcat+'];


%% Run on validation set

testImgDir = fullfile(dataDir, 'test', 'images');
bbsNm=[detName 'Dets_all.txt'];
if(~exist(bbsNm,'file'))
    imgNms = bbGt('getFiles',{testImgDir});
    acfDetect( imgNms, detector, bbsNm );
end


%% Concat results from different detectors

detsAll = dlmread(bbsNm);
N=detsAll(end,1);
detsNew = cell(N,1);
pNms.overlap = 0.3;
pNms.ovrDnm = 'union';
pNms.type = 'maxg';
parfor i=1:N
    bbs = detsAll(detsAll(:,1)==i,2:end);
    orientIdx = mod((bbs(:,end)-1),B)+1;
    bbs(:,end) = anglelist(orientIdx);
    bbs = bbNms(bbs,pNms);
    bbs = [i*ones(size(bbs,1),1) bbs];
    detsNew{i} = bbs;
end
detsNew = cell2mat(detsNew(~cellfun(@isempty,detsNew)));
detFile = fullfile(resDir,'subcat+Dets.txt');
dlmwrite(detFile,detsNew);

%% ACF Eval Script
clear inclustlabels;
name = fullfile(resDir,'subcat+');
allBs = 1:B;
for j_B = 1:length(allBs); inclustlabels{j_B} = sprintf('car%02d',allBs(j_B)); end;
pLoad={'lbls',inclustlabels,'ilbls',{'ig'}};

acfTest('name',name,'imgDir',fullfile(dataDir,'test','images'),...
    'gtDir',fullfile(dataDir,'test','annotations'),'pLoad',[pLoad, 'hRng',[25 inf]],...
    'reapply',0,'show',2,'thr',.7);
