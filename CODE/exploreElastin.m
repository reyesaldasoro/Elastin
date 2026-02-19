clear all
close all

if filesep=='\'
    baseDir  ='C:\Users\sbbk034\OneDrive - City, University of London\Acad\Research\LuisMartinezLemus\Elastin\';
else
    baseDir = ("/Users/constantino-carlos.reyes-aldasoro/Documents/GitHub/Elastin/DATA/");
end


%%
dir0 = dir(strcat(baseDir,'*.tif'));
currImage = imread(strcat(baseDir,dir0(1).name));
figure(1)
imagesc(currImage)

[vessel,lumen,background,watershedIntensity2,redInverted,watershedClean] = detectLumenBackground(currImage);
figure(2)
imagesc(currImage.*repmat(vessel,[1 1 3]));

%%
%figure(33)
 elastinLayers2 = regionGrowingElastin(watershedIntensity2);
currImage2 = currImage;
currImage2(:,:,2) = uint8(255*imdilate(elastinLayers2,ones(3))) + (currImage(:,:,2).*uint8(1-imdilate(elastinLayers2,ones(3)))) ;
figure
imagesc(currImage2)
%elastinLayers=detectElastinLayers(currImage)
%% frangi filters


B = fibermetric(redInverted,18,'ObjectPolarity','dark');
BW = imbinarize(B);
imagesc(labeloverlay(2*redInverted,BW))
%imagesc(double(watershedClean).*(1-BW))
axis([2100 2700 3000 3500])
%%
imagesc(imdilate(2*double(elastinLayers)+double(1-BW).*double(watershedClean),ones(2)))

%%

a1 = currImage(:,:,1);
a1_LPF = imfilter(a1,fspecial("gaussian",3,2));
a2 = 255-a1_LPF;

a3 = a2>50;
a4 = imopen(a3,ones(5));
a5 = a2.*uint8(a4);
a6 = (watershed(a5));
a6_P = regionprops(a6,'Area');

%%

[k1,k2]=sort([a6_P.Area],'descend');
background  = uint8(a6==(k2(1)));
lumen       = uint8(imfill(a6==(k2(2)),'holes'));

a7 = uint8(a6==0).*uint8(1-lumen);
a8 = uint8(a7).*a2;

imagesc(a8)

% This produces a nice watershed tracking of the layers. The first internal
% ones are easy as they are bright, the last ones are dimmer so they start
% getting lost. For the internal ones, the main issue would be to detect if
% there is a small fold between lobules that is not the actual layer.

% Then it is matter of proceeding layer by layer.

% Grab the first layer by dilating the lumen.
Layer_1 = a8.*imdilate(lumen,ones(3))-lumen;

imagesc(a8-Layer_1)

%% Clean
% remove very dark pixels, then label and all layers should be in contact,
% then remove everything that is not within that mega region. Then proceed
% iteratively taking layer by layer, find contact points between layers and
% end of layers.
q=Layer_1(Layer_1>0);
a9 = a8.*uint8(a8>(mean(q)-6*std(double(q))));


a11 = bwlabel(a9);

a11_P = regionprops(a11);
[k1,k2]=sort([a11_P.Area],'descend');

a12 = a11==k2(1);


a13 = bwmorph(a12,"spur",10);


imagesc(a12+a13)