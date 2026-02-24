function [elastinEndPoints_3_L,elastinLayers_3] = postprocessElastinLayers (elastinLayers,redInverted)

%% strong layers 
% First skeletonise and keep only the larger branches, spur to remove the
% last branch points that are detected as endpoints 
elastinLayers_0                 = bwskel(elastinLayers,'minbranch',30);
elastinLayers_0                 = bwmorph(elastinLayers_0,"spur",3);

% remove not intense and small
% small and not very intense segments are removed
[elastinLayers_L,numLayers]     = bwlabel(elastinLayers_0);
elastinLayers_P                 = regionprops(elastinLayers_L,redInverted,'area','MeanIntensity','MaxIntensity','MinIntensity');

elastinLayers_1                 = ismember(elastinLayers_L,find([elastinLayers_P.MeanIntensity]>210));
elastinLayers_2                 = ismember(elastinLayers_L,find([elastinLayers_P.Area]>90));
elastinLayers_3                 = elastinLayers_0&elastinLayers_1&elastinLayers_2;
%[elastinLayers_L3,numLayers_3]  = bwlabel(elastinLayers_3);
% now calculate end points and branch points
elastinEndPoints_3              = bwmorph(elastinLayers_3,'endpoints');
elastinBranchPoints_3           = bwmorph(elastinLayers_3,'branchpoints');

% endpoints very close to branch points are discarded 
elastinEndPoints_3              = elastinEndPoints_3 .* imerode((1-elastinBranchPoints_3),ones(15));

% Detect end of layer when endpoint is far from another endpoint
[elastinEndPoints_3_L,numEndPoints] = bwlabel(elastinEndPoints_3);
%%
imagesc(imdilate(elastinLayers_3*50,ones(3)) + imdilate(elastinEndPoints_3_L,ones(25)))
axis ([1100 2750 920 3570 ])

%% Iterate over the endpoints to determine how close they are to other points
pointsTooClose =[];
for k=1:numEndPoints
    p=unique(imdilate(elastinEndPoints_3_L==k,ones(25)).*(elastinEndPoints_3_L));
    if numel(p)>2
        pointsTooClose = [pointsTooClose;p];
    end
end


pointsTooClose = unique(pointsTooClose);
pointsTooClose (pointsTooClose==0)=[];

elastinEndPoints_3_L(ismember(elastinEndPoints_3_L,pointsTooClose))=0;


%% Connect layers that may be a few pixels away, but only on the end points
% 
% [q1,q2]=bwlabel(elastinLayers_1);
% for k=1:q2
%     q3 = unique(q1.*imdilate(bwmorph(q1==k,'endpoints'),ones(9)));
%     q3(q3==k)=[];
%     q3(q3==0)=[];
%     q4(k,1:1+numel(q3))=[k q3'];
% end
% q5=q4;
% 
% for k1=1:k
%     currRow         = q4(k1,:);
%     currRowHigher   = currRow>k1;
%     q5(currRow(currRowHigher))=q5(k1,1);
% end
% 
% elastinLayers_L2=zeros(size(elastinLayers_L));
% for k1 = 1:k
%     elastinLayers_L2=elastinLayers_L2 + (q5(k1,1))*(q1==k1);
% end
% 
% elastinLayers_L3=zeros(size(elastinLayers_L));
% 
% for k1=1:k
%     elastinLayers_L3 = elastinLayers_L3 + k1*((elastinLayers_L2==k1)|(bwmorph(imdilate(bwmorph(elastinLayers_L2==k1,"endpoints"),ones(7)),'thin','inf')));
% end
% %%
% 
% elastinLayers_P3                 = regionprops(elastinLayers_L3,elastinLayers_L3,'area','MeanIntensity','MaxIntensity','MinIntensity');
% 
% 
% elastinLayers_L2                 = ismember(elastinLayers_L,find([elastinLayers_P3.Area]>90));
% %elastinLayers_3                 = bwmorph(elastinLayers&elastinLayers_1&elastinLayers_2,"spur",+27);
% %elastinEndPoints                = bwmorph(elastinLayers_3,'endpoints');
% %imagesc(imdilate(elastinLayers+elastinLayers_1+2*elastinEndPoints,ones(9)))
% imagesc(imdilate(elastinLayers+elastinLayers_2,ones(9)))
% 
% %%
% 
% 
% % remove not intense
% % find edge points
% 
% 
% sum(sum(elastinEndPoints))
% imagesc(imdilate(elastinLayers+2*elastinEndPoints,ones(9)))
% 
% 
% 
% 
% 
% 
% %%
% seed3               = bwmorph(seed2,'spur',10);
% seed3_L             = bwlabel(seed3);
% seed3_B             = bwmorph((seed3),'branchpoints');
% 
% seed3_B_L           = bwlabel(seed3_B);
% seed3_B_P           = regionprops(seed3_B_L,'area','Centroid');
% 
% % discard branchpoints of area>1, these are spurious due to turns,
% 
% seed3_B_clean       = ismember(seed3_B_L,find([seed3_B_P.Area]==1));
% 
% % Cases where there are branch points:
% % 1 small spurious branches arise
% % 2 twists that are considered a branch, but are not
% % 3 two main layers are close and connect
% % 4 A junction of one layer with an edge of another
% 
% %%
% 
% [seed3_B_L,numBranchPoints]           = bwlabel(seed3_B_clean);
% 
% %seed3_B_P =regionprops(seed3_B_L,'area','Centroid');
% 
% 
% finDist             = ones(numBranchPoints,1)*inf;
% for k = 1:numBranchPoints
%     %disp(k)
%     currDistMap     = bwdist(seed3_B_L==k);
%     currDist        = regionprops(seed3_B_L,currDistMap,'MaxIntensity');
%     currDist(k).MaxIntensity = inf;
%     [finDist,qq(:,k)]        = min([finDist,[currDist.MaxIntensity]'],[],2);
% end
% 
% qq2                         = repmat([1:numBranchPoints],numBranchPoints,1).* (qq-1);
% qq3                         = max(qq2,[],2);
% 
% currLabel                   = regionprops(seed3_B_L,seed3_L,'MaxIntensity');
% 
% 
% finDist(:,2)                = qq3;
% finDist(:,3)                = [currLabel.MaxIntensity];
% 
% finDist2                    = finDist;
% finDist2(finDist2(:,1)>50,:)= [];
% 
% % iterate over the ridges/layers that have branchpoints
% 
% uniqueLayers                = unique(finDist2(:,3));
% numUniqueLayers             = numel(uniqueLayers);
% 
% seed4                       = zeros(size(seed ));
% seed4B                      = seed4;
% for k = 1:numUniqueLayers
%     currLayer                   = seed3_L==uniqueLayers(k);
%     currLayerSegments           = bwlabel(currLayer.*(1-imdilate(seed3_B_clean,[0 1 0;1 1 1;0 1 0])));
%     currLayerSegments_P         = regionprops(currLayerSegments,'Area');
%     currLayerSegments2          = ismember(currLayerSegments,find([currLayerSegments_P.Area]>25));
%     currLayerSegments3          = imdilate(bwmorph(currLayerSegments2,'endpoints'),[0 1 0;1 1 1;0 1 0]);
%     seed4                       = seed4 + bwskel(currLayerSegments2|currLayerSegments3);
%     seed4B                      = seed4B + (currLayer);
% end
% 
% seed5                       = ((seed3_B_clean)|(seed3.*((seed4+seed4B)~=1)));
% seed6                       = bwmorph(seed5,'bridge');
% 
% seed6_L                     = bwlabel(seed6);
% seed6_P                     = regionprops(seed6_L,'area');
% %%
%elastinLayers               = ismember(seed6_L,find([seed6_P.Area]>21));