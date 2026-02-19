function [vessel,lumen,background,watershedIntensity,redInverted,watershedClean] = detectLumenBackground(currImage)



% Dimensions, if image is RGB, take only the red channel
[rows,cols,levs]    = size(currImage);
if levs>1
    redChannel      = currImage(:,:,1);
else
    redChannel      = currImage;
end
redChannel_LPF      = imfilter(redChannel,fspecial("gaussian",3,2));
redInverted         = 255-redChannel_LPF;

a3 = redInverted>50;
a4 = imopen(a3,ones(5));
a5 = redInverted.*uint8(a4);
a6 = (watershed(a5));
a6_P = regionprops(a6,'Area');

%% Detect the background and lumen\
% These are the largest areas, the background will be the first detected,
% it is assumed that (1,1) is background 

[k1,k2]             = sort([a6_P.Area],'descend');

%background          = uint8(imerode(imclose(a6==(k2(1)),ones(round(min(rows,cols)/200))),ones(15)));

lumen               = uint8(imerode(imfill(a6==(k2(2)),'holes')                         ,ones(5)));
background          = uint8(a6==(k2(1)));

vessel_0            = 1-(background);
vessel_1            = bwlabel(vessel_0);
vessel_1P           = regionprops(vessel_1,'area');

[k1,k2]             = sort([vessel_1P.Area],'descend');
vessel_2            = vessel_1==(k2(1));
vessel              = uint8(imdilate(vessel_2,ones(5)))-lumen;
% imagesc(background*2+lumen)
% figure
% imagesc(currImage.*(repmat(vessel,[1 1 3])))
%%
a55=a5;
a55(a55>230)=255;
a8                  = uint8(imdilate(edge(a55,'canny',[],4),ones(3)));
a9                  = watershed( imfilter(redInverted.*vessel,fspecial('gaussian',9,7)));
watershedClean      = uint8(a9==0).*uint8(vessel);

%imagesc(watershedClean+2*(a8.*vessel))
%axis([2100 2700 3000 3500])
%%
watershedIntensity  = uint8(watershedClean).*redInverted.*(1-a8);

%imagesc(watershedIntensity)