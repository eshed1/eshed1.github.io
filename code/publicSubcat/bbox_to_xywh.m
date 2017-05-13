function xywh = bbox_to_xywh(bbox)
xywh = [bbox(:,1) bbox(:,2) bbox(:,3)-bbox(:,1)+1 bbox(:,4)-bbox(:,2)+1];
%xywh = [bbox(:,1) bbox(:,2) bbox(:,3)-bbox(:,1) bbox(:,4)-bbox(:,2)];
