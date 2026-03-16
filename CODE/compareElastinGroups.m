clear all
close all

if filesep=='\'
    baseDir  ='C:\Users\sbbk034\OneDrive - City, University of London\Acad\Research\LuisMartinezLemus\Elastin\';
else
    baseDir = ("/Users/constantino-carlos.reyes-aldasoro/Desktop/elastinGroups/");
end

dir0                                        = dir(strcat(baseDir,'E_*'));
numDir0                                     = size(dir0,1);
%%

for k1=2%:numDir0
    dir1                                    = dir(strcat(baseDir,filesep,dir0(k1).name,filesep,'*.tif'));
    numFiles                                = size(dir1,1);
    for k=1%:numFiles
        disp([k1 k])
        currImage                               = imread(strcat(dir1(k).folder ,filesep   ,dir1(k).name));
        [elastinLayers,redInverted,lumen]       = detectElastinLayers(currImage);
        [elastinLayers2,elastinEndPoints]       = postprocessElastinLayers(elastinLayers,redInverted,maxIntensity2);
        [OutputLayers, outputLayersPoints]      = labelElastinLayers (currImage, elastinLayers2,elastinEndPoints);
        elastinMetrics                          = calculateElastinMetrics(currImage,redInverted,elastinLayers2, elastinEndPoints,lumen);
        % figure
        % imagesc(outputLayersPoints)
        % set(gca,'position',[0 0 1 1 ]);axis off
        % axis equal
        % filename                                = strcat(dir0(k).name(1:end-4),'_output.mat');
        % save(filename,'currImage','elastinLayers','OutputLayers','outputLayersPoints','elastinLayers2','elastinEndPoints','redInverted',"lumen",'elastinMetrics')

        % filename                            = strcat(dir0(k).name(1:end-4),'_output.png');
        % imwrite(outputLayersPoints,filename)

        %resultsElastinGroups{k1,k} = elastinMetrics;

        resultsElastinGroups(k+(k1-1)*numFiles,1) = k1;
        resultsElastinGroups(k+(k1-1)*numFiles,2) = k;
        resultsElastinGroups(k+(k1-1)*numFiles,3) = elastinMetrics.numEndPoints;
        resultsElastinGroups(k+(k1-1)*numFiles,4) = elastinMetrics.avWidthLayers;
        resultsElastinGroups(k+(k1-1)*numFiles,5) = elastinMetrics.avWidthVessel;
        resultsElastinGroups(k+(k1-1)*numFiles,6) = elastinMetrics.ratioLayersLumen;
        resultsElastinGroups(k+(k1-1)*numFiles,7) = elastinMetrics.ratioLumenVessel;
        resultsElastinGroups(k+(k1-1)*numFiles,8) = elastinMetrics.LumenAspectRatio;
    end
end
%%


for k1=1:numDir0
    dir1                                    = dir(strcat(baseDir,filesep,dir0(k1).name,filesep,'*.tif'));
    numFiles                                = size(dir1,1);
    for k=1:numFiles
        disp([k1 k k+(k1-1)*numFiles] )
        currName{k+(k1-1)*numFiles,1}         = (strcat(dir1(k).folder(end-2:end) ,filesep   ,dir1(k).name));
    end
end

%%
plot(resultsElastinGroups(:,8),'bo')

%%

elastinMetricLabels ={'A/B/C/D','Name','End Points','Width Layers','Width Vessel','layers/Lumen','Lumen/Vessel','Aspect Ratio'};

l1=3;l2=8;
validIndex1 = find(resultsElastinGroups(:,3)>0);
notValid    = find(resultsElastinGroups(:,6)>1);
validIndex  = setdiff(validIndex1,notValid); 
scatter(resultsElastinGroups(validIndex,l1),resultsElastinGroups(validIndex,l2),160)

xlabel(elastinMetricLabels{l1},"FontSize",26)
ylabel(elastinMetricLabels{l2},"FontSize",26)

for k3=1:numel(validIndex)
    text(resultsElastinGroups(validIndex(k3),l1),resultsElastinGroups(validIndex(k3),l2),currName{validIndex(k3)},'Interpreter','none','rotation',45)
end

filename                            = strcat('Results_',elastinMetricLabels{l1},'_',elastinMetricLabels{l2},'.png');
filename=strrep(filename,' ','_');
filename=strrep(filename,'/','_');
print('-dpng','-r300',filename)
