function  elastinMetrics  = calculateElastinMetrics(currImage,redInverted,elastinLayers2, elastinEndPoints,lumen)
% layers and interlayers
LayersFilled            = (1-lumen).*imclose(uint8(elastinLayers2),strel('disk',128));

%imagesc(currImage.*(repmat(LayersFilled,[1 1 3])))

%imagesc(currImage.*(uint8(repmat(1-lumen,[1 1 3]))))
avWidthVessel           = 2*sum(sum(LayersFilled))/sum(sum(edge(LayersFilled)));
avWidthLayers           = sum(sum(LayersFilled))/sum(sum(elastinLayers2));
numEndPoints            = max(elastinEndPoints(:));



elastinMetrics.numEndPoints     = numEndPoints;
elastinMetrics.avWidthVessel    = avWidthVessel;
elastinMetrics.avWidthLayers    = avWidthLayers;
%%
% q1 = elastinLayers2(:);
% q2= redInverted(:);
% q2(q1==0)=[];
% 
% plot((double().*double(redInverted(:))))

