clear all
close all

if filesep=='\'
    baseDir  ='C:\Users\sbbk034\OneDrive - City, University of London\Acad\Research\LuisMartinezLemus\Elastin\';
else
    baseDir = ("/Users/constantino-carlos.reyes-aldasoro/Documents/GitHub/Elastin/DATA/");
end

dir0                                    = dir(strcat(baseDir,'*.tif'));
%%

k=1;
currImage                               = imread(strcat(baseDir,dir0(k).name));

figure
imagesc(currImage)
set(gca,'position',[0 0 1 1 ]);axis off
filename                            = strcat('../Figures/Fig_1_',dir0(k).name(1:end-4),'.png');
%imwrite(currImage,filename)

print('-dpng','-r500',filename)
axis([2273 2802 2196 2758])
filename                            = strcat('../Figures/Fig_1_ROI_',dir0(k).name(1:end-4),'.png');
print('-dpng','-r500',filename)

%%
 hot2=hot;
 blue2  = hot2(:,[3 2 1]);
 green2 = hot2(:,[2 1 3]);
figure
imagesc(255 - currImage(:,:,1))
set(gca,'position',[0 0 1 1 ]);axis off
colormap (hot2)
filename                            = strcat('../Figures/Fig_2_a_',dir0(k).name(1:end-4),'.png');
print('-dpng','-r500',filename)
axis([2273 2802 2196 2758])
filename                            = strcat('../Figures/Fig_2_a_ROI_',dir0(k).name(1:end-4),'.png');
print('-dpng','-r500',filename)

figure
imagesc(255 - currImage(:,:,2))
set(gca,'position',[0 0 1 1 ]);axis off
colormap (green2)
filename                            = strcat('../Figures/Fig_2_b_',dir0(k).name(1:end-4),'.png');
print('-dpng','-r500',filename)
axis([2273 2802 2196 2758])
filename                            = strcat('../Figures/Fig_2_b_ROI_',dir0(k).name(1:end-4),'.png');
print('-dpng','-r500',filename)

figure
imagesc(255 - currImage(:,:,3))
set(gca,'position',[0 0 1 1 ]);axis off
colormap (blue2)
filename                            = strcat('../Figures/Fig_2_c_',dir0(k).name(1:end-4),'.png');
print('-dpng','-r500',filename)
axis([2273 2802 2196 2758])
filename                            = strcat('../Figures/Fig_2_c_ROI_',dir0(k).name(1:end-4),'.png');
print('-dpng','-r500',filename)


%%
close all


[elastinLayers,redInverted,lumen]       = detectElastinLayers(currImage);




%%
[elastinLayers2,elastinEndPoints]       = postprocessElastinLayers(elastinLayers,redInverted);
[OutputLayers, outputLayersPoints]      = labelElastinLayers (currImage, elastinLayers2,elastinEndPoints);
elastinMetrics                          = calculateElastinMetrics(currImage,redInverted,elastinLayers2, elastinEndPoints,lumen);
figure
imagesc(outputLayersPoints)
set(gca,'position',[0 0 1 1 ]);axis off
axis equal
filename                                = strcat(dir0(k).name(1:end-4),'_output.mat');
save(filename,'currImage','elastinLayers','OutputLayers','outputLayersPoints','elastinLayers2','elastinEndPoints','redInverted',"lumen",'elastinMetrics')

% filename                            = strcat(dir0(k).name(1:end-4),'_output.png');
% imwrite(outputLayersPoints,filename)
