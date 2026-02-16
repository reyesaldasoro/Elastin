function elastinLayers = regionGrowingElastin(watershedIntensity)
%%
maxIntensity        = max(watershedIntensity(:));
seed                = watershedIntensity>=(maxIntensity-10);
%%
for k=1:1999
    if mod(k,50)==1
        % Spur to remove branches that are going sideways   
        seed        = bwmorph(seed,'spur',5+floor(k/100));% 1+k/10);
        % seed_B1     = bwmorph(bwskel(seed),'branchpoints');
        % seed        = bwmorph(seed-seed_B1,'spur',5);% 1+k/10);
    end
    seed_E1         = bwmorph(seed,'endpoints');
    if mod(k,200)==0
        % dilation is normally ones(3) except every 100 to allow cases that have been broken by 1 pixel
        seed_d          = imdilate(seed_E1,ones(7));
        %seed_d          = imdilate(seed_E1,[0 1 1 1 0;1 1 1 1 1;1 1 1 1 1;1 1 1 1 1; 0 1 1 1 0]);

    elseif mod(k,900)==0
        seed_d          = imdilate(seed_E1,ones(15));
    else
        seed_d          = imdilate(seed_E1,[1 1 1;1 1 1;1 1 1]);
    end

    %   seed_d      = imdilate(seed_d1,[0 1 0;1 1 1;0 1 0]);
    % curr        = (a8==k);
    % curr_L      = bwlabel(curr);
    % curr_keep1  = unique(curr_L.*seed_d);
    % curr_keep   = ismember(curr_L,curr_keep1(2:end));

    if mod(k,100)==0
        imagesc(2*seed+seed_d)
        % axis([3700 4300 3800 4700])  % fig 4
        axis([2100 2700 2600 3600])    % fig 1
        %axis ([2100 2600 2700 3200])
        drawnow
        pause(0.0001)
    end
     %disp(k)
    n_seed = sum(sum(seed>0));
    seed            = seed|(seed_d.*(watershedIntensity>(250-floor(k/10))));
    n_seed2 = sum(sum(seed>0));

    disp([k -n_seed+n_seed2])
end
%% Once the main region growing is finished, join the layers, label and join one by one
% Then spur, remove small holes and then find points touching Y junctions
% and X junctions, H junctions



%% Post process, fill small holes
% Imfill holes may fill the lumen and everything else. It is necessary to check
% that it only fills small holes
seedFilled          = imfill(seed,'holes');
seedHoles           = bwlabel(seedFilled-seed);
seedHoles_P         = regionprops(seedHoles,'Area','MajorAxisLength','MinorAxisLength');

seed1               = seed|ismember(seedHoles,find([seedHoles_P.MinorAxisLength]<20));
seed2               = bwmorph(seed1,'thin','inf');
%imagesc(2*seed2+seed)
%% Connect layers that may be a few pixels away, but only on the end points

[q1,q2]=bwlabel(seed2);

for k=1:q2
    q3 = unique(q1.*imdilate(bwmorph(q1==k,'endpoints'),ones(9)));
    q3(q3==k)=[];
    q3(q3==0)=[];
    q4(k,1:1+numel(q3))=[k q3'];
end
q5=q4;

for k1=1:k
    currRow         = q4(k1,:);
    currRowHigher   = currRow>k1;
    q5(currRow(currRowHigher))=q5(k1,1);
end


elastinLayers = seed2;
return

%%
seed3               = bwmorph(seed2,'spur',10);
seed3_L             = bwlabel(seed3);
seed3_B             = bwmorph((seed3),'branchpoints');

seed3_B_L           = bwlabel(seed3_B);
seed3_B_P           = regionprops(seed3_B_L,'area','Centroid');

% discard branchpoints of area>1, these are spurious due to turns,

seed3_B_clean       = ismember(seed3_B_L,find([seed3_B_P.Area]==1));

% Cases where there are branch points:
% 1 small spurious branches arise
% 2 twists that are considered a branch, but are not
% 3 two main layers are close and connect
% 4 A junction of one layer with an edge of another

%%

[seed3_B_L,numBranchPoints]           = bwlabel(seed3_B_clean);

%seed3_B_P =regionprops(seed3_B_L,'area','Centroid');


finDist             = ones(numBranchPoints,1)*inf;
for k = 1:numBranchPoints
    %disp(k)
    currDistMap     = bwdist(seed3_B_L==k);
    currDist        = regionprops(seed3_B_L,currDistMap,'MaxIntensity');
    currDist(k).MaxIntensity = inf;
    [finDist,qq(:,k)]        = min([finDist,[currDist.MaxIntensity]'],[],2);
end

qq2                         = repmat([1:numBranchPoints],numBranchPoints,1).* (qq-1);
qq3                         = max(qq2,[],2);

currLabel                   = regionprops(seed3_B_L,seed3_L,'MaxIntensity');


finDist(:,2)                = qq3;
finDist(:,3)                = [currLabel.MaxIntensity];

finDist2                    = finDist;
finDist2(finDist2(:,1)>50,:)= [];

% iterate over the ridges/layers that have branchpoints

uniqueLayers                = unique(finDist2(:,3));
numUniqueLayers             = numel(uniqueLayers);

seed4                       = zeros(size(seed ));
seed4B                      = seed4;
for k = 1:numUniqueLayers
    currLayer                   = seed3_L==uniqueLayers(k);
    currLayerSegments           = bwlabel(currLayer.*(1-imdilate(seed3_B_clean,[0 1 0;1 1 1;0 1 0])));
    currLayerSegments_P         = regionprops(currLayerSegments,'Area');
    currLayerSegments2          = ismember(currLayerSegments,find([currLayerSegments_P.Area]>25));
    currLayerSegments3          = imdilate(bwmorph(currLayerSegments2,'endpoints'),[0 1 0;1 1 1;0 1 0]);
    seed4                       = seed4 + bwskel(currLayerSegments2|currLayerSegments3);
    seed4B                      = seed4B + (currLayer);
end

seed5                       = ((seed3_B_clean)|(seed3.*((seed4+seed4B)~=1)));
seed6                       = bwmorph(seed5,'bridge');

seed6_L                     = bwlabel(seed6);
seed6_P                     = regionprops(seed6_L,'area');
%%
elastinLayers               = ismember(seed6_L,find([seed6_P.Area]>21));
