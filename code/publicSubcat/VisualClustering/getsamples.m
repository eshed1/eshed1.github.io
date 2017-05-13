%Collect positive samples
%Feature extraction params
ftsopts.color.enabled = 1;
ftsopts.grad.enabled = 1;
defts = chnsCompute;
defts.pColor.colorSpace = 'luv'; 

X = [];

%Make sure to pad

%Obtrain resize parameters
rszdim = [];
objlist = load('objlist.mat');
objlist = objlist.objlist; %format is alpha x y w h
clust_ar = [];
rszdim = [mean(objlist(:,5)) mean(objlist(:,4))];
%%
s_f = 0; e_f = 7480; 
allidx = s_f:e_f; 

disp('Not parfored!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!')
for i=allidx
    disp([num2str(i) ' Out of ' num2str(length(allidx))]);
    train_objects = readLabels(rootlabels,i); 

    I = imread(sprintf('%s/%06d.png',rootims,i));
 
    %For each object in the image, determine ignore or not and orientation cluster
    Ilabs = []; Ibbs = [];
    for obj_i = 1:length(train_objects);
        currbb = [train_objects(obj_i).x1 train_objects(obj_i).y1 train_objects(obj_i).x2 train_objects(obj_i).y2];
        currbb(currbb<1)=1;
        currbb = bbox_to_xywh(currbb); 
        
        if(sum(strcmp(train_objects(obj_i).type,labels))>0 ...
                && currbb(1,4)>minboxheight ...
                && sum(train_objects(obj_i).occlusion==occlusionLevel)>0 ...
                && train_objects(obj_i).truncation <= Maxtruncation)
            
            %Extract sample
            %imshow(I);bbApply('draw',currbb);
            
            %Pad image
            
            Ic = bbApply('crop',I,currbb);
            
            %Determine label cluster
            %[labelsquant,~] = quantizeAngles(double(train_objects(obj_i).alpha),B);
            % Ilabs{obj_i} = sprintf('car%02d',labelsquant);
        else
            %Ignore label
            Ilabs{obj_i} = 'ig';
        end
        Ibbs(obj_i,:) = currbb;
    end
    %%
end