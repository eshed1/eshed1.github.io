function [labelout,quantrule] = quantizeAngles(label,B)
labelquant = label(:,1);
labelout = label(:,1);

%MAY NOT BE EFFICIENT CODE
classcount = 0;
quantvals = -pi+pi/B:2*pi/B:pi;
quantrule = quantvals+pi/B;
quantrule = [quantrule(end) quantrule(1:end-1)];
for ang_lim= quantvals;
    classcount = classcount+1;
    for k=1:length(labelquant)
        if labelquant(k)<ang_lim
            labelquant(k)=100; %Make sure next time around it will not be < anymore
            labelout(k) = classcount; %Add the magnitude, note there's no weight
        end
    end
end

%Last chunk of the circle
labelout(labelquant~=100)=1;


end