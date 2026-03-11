function  elastinMetrics  = calculateElastinMetrics(currImage,redInverted,elastinLayers2, elastinEndPoints,lumen)
% layers and interlayers
LayersFilled            = (1-lumen).*imclose(uint8(elastinLayers2),strel('disk',128));

%imagesc(currImage.*(repmat(LayersFilled,[1 1 3])))

%imagesc(currImage.*(uint8(repmat(1-lumen,[1 1 3]))))
avWidthVessel           = 2*sum(sum(LayersFilled))/sum(sum(edge(LayersFilled)));
avWidthLayers           = sum(sum(LayersFilled))/sum(sum(elastinLayers2));
numEndPoints            = max(elastinEndPoints(:));


lumen_P                         = regionprops(lumen,'solidity','EquivDiameter','Area','Eccentricity','MajorAxisLength','MinorAxisLength');
layers_P                        = regionprops(LayersFilled,'solidity','EquivDiameter','Area','Eccentricity','MajorAxisLength','MinorAxisLength');



elastinMetrics.numEndPoints     = numEndPoints;
elastinMetrics.avWidthVessel    = avWidthVessel;
elastinMetrics.avWidthLayers    = avWidthLayers;
try 
    elastinMetrics.ratioLumenVessel = lumen_P.Area/(lumen_P.Area+layers_P.Area);
    elastinMetrics.ratioLayersLumen = layers_P.Area/(lumen_P.Area);
catch
    elastinMetrics.ratioLumenVessel = -1;
    elastinMetrics.ratioLayersLumen = -1;
end

elastinMetrics.LumenAspectRatio = lumen_P.MinorAxisLength/(lumen_P.MajorAxisLength);



%%
% q1 = elastinLayers2(:);
% q2= redInverted(:);
% q2(q1==0)=[];
% 
% plot((double().*double(redInverted(:))))

