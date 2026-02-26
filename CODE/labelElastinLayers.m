function  [OutputLayers, outputLayersPoints] = labelElastinLayers (currImage, elastinLayers,elastinEndPoints_3_L)

elastinEndPoints_3_P            = regionprops(elastinEndPoints_3_L,"Centroid");
numEndpoints                    = max(elastinEndPoints_3_L(:));
OutputLayers                    = currImage;
outputLayersPoints              = currImage;
OutputLayers(:,:,2)             = uint8(255*imdilate(elastinLayers,ones(3))) +...
                                (currImage(:,:,2).*uint8(1-imdilate(elastinLayers,ones(3)))) ;

outputLayersPoints(:,:,1)       = uint8(175*imdilate(elastinLayers_3,ones(3))) +...
                                (currImage(:,:,1).*uint8(1-imdilate(elastinLayers_3,ones(3)))) ;

outputLayersPoints(:,:,2)       = uint8(240*imdilate(elastinEndPoints_3_L>0,ones(14))) +...
                                (currImage(:,:,2).*uint8(1-imdilate(elastinEndPoints_3_L>0,ones(14)))) ;
for k=1:numEndPoints
    outputLayersPoints          = insertText(outputLayersPoints,[ elastinEndPoints_3_P(k).Centroid(1),elastinEndPoints_3_P(k).Centroid(2)],num2str(k),FontSize=50,BoxOpacity=0.2,TextColor='black',TextBoxColor='white');
end

outputLayersPoints              = insertText(outputLayersPoints,[ 1,1],strcat('Number of points=',num2str(numEndPoints)),FontSize=200,BoxOpacity=0.2,TextColor='black',TextBoxColor='white');
