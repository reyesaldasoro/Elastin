function elastinLayers=detectElastinLayers(currImage)

% Dimensions, if image is RGB, take only the red channel
[rows,cols,levs]    = size(currImage);
if levs>1
    redChannel      = currImage(:,:,1);
else
    redChannel      = currImage;
end


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
figure
imagesc(currImage.*(repmat(vessel,[1 1 3])))

%%
watershedClean      = uint8(a6==0).*uint8((1-lumen).*(1-background));
watershedIntensity  = uint8(watershedClean).*redInverted;

imagesc(watershedIntensity)
%%
% This produces a nice watershed tracking of the layers. The first internal
% ones are easy as they are bright, the last ones are dimmer so they start
% getting lost. For the internal ones, the main issue would be to detect if
% there is a small fold between lobules that is not the actual layer.

% Then it is matter of proceeding layer by layer.

% Grab the first layer by dilating the lumen.
Layer_1 = watershedIntensity.*imdilate(lumen,ones(3))-lumen;

imagesc(watershedIntensity-Layer_1)
% 
% %% Clean
% % remove very dark pixels, then label and all layers should be in contact,
% % then remove everything that is not within that mega region. Then proceed
% % iteratively taking layer by layer, find contact points between layers and
% % end of layers.
% q=Layer_1(Layer_1>0);
% a9 = a8.*uint8(a8>(mean(q)-6*std(double(q))));
% 
% 
% a11 = bwlabel(a9);
% 
% a11_P = regionprops(a11);
% [k1,k2]=sort([a11_P.Area],'descend');
% 
% a12 = a11==k2(1);
% 
% 
% a13 = bwmorph(a12,"spur",10);
% 
% 
% imagesc(a12+a13)
% 
% %%
% 
% [rows,cols]= size(a);
% 
% [xx,yy] = meshgrid(1:cols,1:rows);
% 
% x1=sum(sum(xx.*a))/sum(sum(a));
% y1=sum(sum(yy.*a))/sum(sum(a));
% 
% b = zeros(size(a));
% b(round(y1),round(x1))=1;
% b2 = bwdist(b);
% imagesc(b2.*a)
% 
% %% Self organising maps? / Snakes 
% % 1 a grid grows from the inside until it finds first layer, then it stops
% % 2 a second grid grows from the first layer,
% % 3 repeat with 6 grids
% % detect:
% % layers that touch and merge
% % layers that break (small), layers that break (big)
% % remove noise
% 
% 
% %%
% a1_LPF = imfilter(a1,fspecial("gaussian",3,2));
% a3 = (watershed(255-a1_LPF));
% %%
% 
% a4 = double(a3==0).*double(255-a1);
% 
% figure(11)
% imagesc(255-a1)
% figure(12)
% imagesc()
% 
% r1 = 2000; r2 = 2300;
% c1 = 1100; c2 = 1500;
% figure(1)
% axis([r1  r2 c1 c2])
% figure(2)
% axis([r1  r2 c1 c2])
% 
% %%
% seed8                       = uint8(imdilate(elastinLayers,ones(5)));
% seed8_L                     = imdilate(bwlabel(elastinLayers),ones(3));
% 
% 
% result = a0;
% result(:,:,2)=result(:,:,2).*(1-seed8)+255*seed8;
% 
% 
% imagesc(result)