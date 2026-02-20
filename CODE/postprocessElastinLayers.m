function elastinLayers_clean = postprocessElastinLayers (elastinLayers,red)

%% strong layers 
[elastinLayers_L,numLayers]     = bwlabel(elastinLayers);
elastinLayers_P                 = regionprops(elastinLayers_L,watershedIntensity,'area','MeanIntensity','MaxIntensity','MinIntensity');


%% remove small, not intense and spur 1
elastinLayers_1                 = ismember(elastinLayers_L,find([elastinLayers_P.MeanIntensity]>180));
elastinLayers_2                 = ismember(elastinLayers_L,find([elastinLayers_P.Area]>25));
elastinLayers_3                 = bwmorph(elastinLayers&elastinLayers_1&elastinLayers_2,"spur",4);

% remove not intense
% find edge points

elastinEndPoints                = bwmorph(elastinLayers_3,'endpoints');
sum(sum(elastinEndPoints))
imagesc(imdilate(elastinLayers_3+2*elastinEndPoints,ones(5)))


%% Connect layers that may be a few pixels away, but only on the end points



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

elastinLayers_L2=zeros(size(elastinLayers_L));
for k1 = 1:k
    elastinLayers_L2=elastinLayers_L2 + (q5(k1,1))*(elastinLayers_L==k1);
end

elastinLayers_L3=zeros(size(elastinLayers_L));

for k1=1:k
    elastinLayers_L3 = elastinLayers_L3 + k1*(elastinLayers_L2==k1)|(bwmorph(imdilate(bwmorph(elastinLayers_L2==k1,"endpoints"),ones(7)),'thin','inf'));
end





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