globals;

minboxheight = 25;
occlusionLevel = [0:1]; % [0:2] 0 = fully visible, 1 = partly occlud 2 = largely occluded, 3 = unknown
Maxtruncation = 0.3; % Percentage, from 0 to 1.
labels = {'Car'}; %can do {'Car','Truck','Van'} for adding these to training, but not needed for KITTI evaluation
B = 25; %Number of orientation clusters. Up to 20-25 should increase performance.

%Validation split taken from 
% @InProceedings{xiang_cvpr15, 
% author = {Yu Xiang and Wongun Choi and 
% Yuanqing Lin and Silvio Savarese}, 
% title = {Data-Driven 3D Voxel Patterns 
% for Object Category Recognition}, 
% booktitle = {IEEE Conference on Computer 
% Vision and Pattern Recognition}, 
% year = {2015}, 
% }
trainIdx=dlmread('ids_train.txt');
testIdx=dlmread('ids_val.txt');

mkdir(fullfile(dataRoot,'train','images'));
mkdir(fullfile(dataRoot,'train','annotations'));
mkdir(fullfile(dataRoot,'test','images'));
mkdir(fullfile(dataRoot,'test','annotations'));

%% Construct training set
N = length(trainIdx);

parfor i=1:N
    
    objects = readLabels(fullfile(kittiRoot,'label_2'),trainIdx(i));
 
    %For each object in the image, determine ignore or not and orientation cluster
    Ilabs = []; Ibbs = [];
    for obj_i = 1:length(objects);
        currbb = [objects(obj_i).x1 objects(obj_i).y1 objects(obj_i).x2 objects(obj_i).y2];
        currbb(currbb<1)=1;
        currbb = bbox_to_xywh(currbb); 
        
        if(sum(strcmp(objects(obj_i).type,labels))>0 ...
                && currbb(1,4)>minboxheight ...
                && sum(objects(obj_i).occlusion==occlusionLevel)>0 ...
                &&  objects(obj_i).truncation <= Maxtruncation)
            
            %Determine label cluster
            alpha = double(objects(obj_i).alpha);
            while alpha <= -pi, alpha = alpha + 2*pi;end
            while alpha > pi, alpha = alpha - 2*pi;end
            [labelsquant,~] = quantizeAngles(alpha,B);
             Ilabs{obj_i} = sprintf('car%02d',labelsquant);
        else
            %Ignore label
            Ilabs{obj_i} = 'ig';
        end
        Ibbs(obj_i,:) = currbb;
    end
    
    %Link Image
    inImg = fullfile(kittiRoot,'image_2',sprintf('%06d.png',trainIdx(i)));
    outImg = fullfile(dataRoot,'train','images',sprintf('%06d.png',trainIdx(i)));
    if ispc()
        system(['mklink', ' ', '"', outImg, '"', ' ', '"', inImg, '"' ' >NUL 2>NUL']);
    elseif isunix()
        system(sprintf('ln -s %s %s',inImg,outImg));
    end
    
    %Write Annotation
    fileID = fopen(fullfile(dataRoot,'train','annotations',sprintf('%06d.txt',trainIdx(i))),'w+');
    fprintf(fileID, '%% bbGt version=3\n');
    for j_a = 1:size(Ibbs,1)
        if(isempty(Ilabs{j_a}))
            disp('warning: empty label'); pause
        else
        fprintf(fileID, '%s %d %d %d %d 0 0 0 0 0 0 0\n',Ilabs{j_a},Ibbs(j_a,1),Ibbs(j_a,2),Ibbs(j_a,3),Ibbs(j_a,4));
        end
    end
    fclose(fileID);
end

%% Add flipped image to training set 
N = length(trainIdx);
parfor i=1:N
    
    objects = readLabels(fullfile(kittiRoot,'label_2'),trainIdx(i));
 
    %For each object in the image, determine ignore or not and orientation cluster
    Ilabs = []; Ibbs = [];
    inImg = fullfile(kittiRoot,'image_2_f',sprintf('%06d.png',trainIdx(i)));
    imgInfo = imfinfo(inImg); W = imgInfo.Width;
    for obj_i = 1:length(objects);
        currbb = [W - objects(obj_i).x2, objects(obj_i).y1, W - objects(obj_i).x1, objects(obj_i).y2];
        currbb(currbb<1)=1;
        currbb = bbox_to_xywh(currbb); 
        
        if(sum(strcmp(objects(obj_i).type,labels))>0 ...
                && currbb(1,4)>minboxheight ...
                && sum(objects(obj_i).occlusion==occlusionLevel)>0 ...
                &&  objects(obj_i).truncation <= Maxtruncation)
            
            %Determine label cluster
            alpha = double(objects(obj_i).alpha);
            alpha = pi - alpha;
            while alpha <= -pi, alpha = alpha + 2*pi;end
            while alpha > pi, alpha = alpha - 2*pi;end
            [labelsquant,~] = quantizeAngles(alpha,B);
             Ilabs{obj_i} = sprintf('car%02d',labelsquant);
        else
            %Ignore label
            Ilabs{obj_i} = 'ig';
        end
        Ibbs(obj_i,:) = currbb;
    end
    
    %Link Image
    outImg = fullfile(dataRoot,'train','images',sprintf('f_%06d.png',trainIdx(i)));
    if ispc()
        system(['mklink', ' ', '"', outImg, '"', ' ', '"', inImg, '"' ' >NUL 2>NUL']);
    elseif isunix()
        system(sprintf('ln -s %s %s',inImg,outImg));
    end
    
    %Write Annotation
    fileID = fopen(fullfile(dataRoot,'train','annotations',sprintf('f_%06d.txt',trainIdx(i))),'w+');
    fprintf(fileID, '%% bbGt version=3\n');
    for j_a = 1:size(Ibbs,1)
        if(isempty(Ilabs{j_a}))
            disp('warning: empty label'); pause
        else
        fprintf(fileID, '%s %d %d %d %d 0 0 0 0 0 0 0\n',Ilabs{j_a},Ibbs(j_a,1),Ibbs(j_a,2),Ibbs(j_a,3),Ibbs(j_a,4));
        end
    end
    fclose(fileID);
end

%% Construct validation set 
N = length(testIdx);
parfor i=1:N
    
    objects = readLabels(fullfile(kittiRoot,'label_2'),testIdx(i));
 
    %For each object in the image, determine ignore or not and orientation cluster
    Ilabs = []; Ibbs = [];
    for obj_i = 1:length(objects);
        currbb = [objects(obj_i).x1 objects(obj_i).y1 objects(obj_i).x2 objects(obj_i).y2];
        currbb(currbb<1)=1;
        currbb = bbox_to_xywh(currbb); 
        
        if(sum(strcmp(objects(obj_i).type,labels))>0 ...
                && currbb(1,4)>minboxheight ...
                && sum(objects(obj_i).occlusion==occlusionLevel)>0 ...
                &&  objects(obj_i).truncation <= Maxtruncation)
            
            %Determine label cluster
            alpha = double(objects(obj_i).alpha);
            while alpha <= -pi, alpha = alpha + 2*pi;end
            while alpha > pi, alpha = alpha - 2*pi;end
            [labelsquant,~] = quantizeAngles(alpha,B);
             Ilabs{obj_i} = sprintf('car%02d',labelsquant);
        else
            %Ignore label
            Ilabs{obj_i} = 'ig';
        end
        Ibbs(obj_i,:) = currbb;
    end
    
    %Link Image
    inImg = fullfile(kittiRoot,'image_2',sprintf('%06d.png',testIdx(i)));
    outImg = fullfile(dataRoot,'test','images',sprintf('%06d.png',testIdx(i)));
    if ispc()
        system(['mklink', ' ', '"', outImg, '"', ' ', '"', inImg, '"' ' >NUL 2>NUL']);
    elseif isunix()
        system(sprintf('ln -s %s %s',inImg,outImg));
    end
    
    %Write Annotation
    fileID = fopen(fullfile(dataRoot,'test','annotations',sprintf('%06d.txt',testIdx(i))),'w+');
    fprintf(fileID, '%% bbGt version=3\n');
    for j_a = 1:size(Ibbs,1)
        if(isempty(Ilabs{j_a}))
            disp('warning: empty label'); pause
        else
        fprintf(fileID, '%s %d %d %d %d 0 0 0 0 0 0 0\n',Ilabs{j_a},Ibbs(j_a,1),Ibbs(j_a,2),Ibbs(j_a,3),Ibbs(j_a,4));
        end
    end
    fclose(fileID);
end