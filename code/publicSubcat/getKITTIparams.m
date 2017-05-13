switch parammode
    case 'easy'
        minboxheight = 40; 
        occlusionLevel = [0]; % [0:2] 0 = fully visible, 1 = partly occlud 2 = largely occluded, 3 = unknown
        Maxtruncation = 0.15; % Percentage, from 0 to 1.
        labels = {'Car'}; %can do {'Car','Truck','Van'} for adding these to training 
    case 'medium'
        minboxheight = 25;
        occlusionLevel = [0:1]; % [0:2] 0 = fully visible, 1 = partly occlud 2 = largely occluded, 3 = unknown
        Maxtruncation = 0.3; % Percentage, from 0 to 1.
    case 'hard'
        minboxheight = 25;
        occlusionLevel = [0:2]; % [0:2] 0 = fully visible, 1 = partly occlud 2 = largely occluded, 3 = unknown
        Maxtruncation = 0.5; % Percentage, from 0 to 1.
        labels = {'Car','Truck','Van'}; %Should we take truck too? Taking for now...
        bRemoveDontCareFromImage = 1;
        bRemoveMISC = 1;
end