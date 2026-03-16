function elastinLayers = regionGrowingElastin(watershedIntensity)
%%
maxIntensity        = max(watershedIntensity(:));
maxIntensity2       = (maxIntensity-10);
seed                = watershedIntensity>=maxIntensity2;
%%
for k=2:1000
    %disp(k)
    if mod(k,50)==1
        % Spur to remove branches that are going sideways   
        seed        = bwmorph(seed,'spur',5+floor(k/100));% 1+k/10);
        % seed_B1     = bwmorph(bwskel(seed),'branchpoints');
        % seed        = bwmorph(seed-seed_B1,'spur',5);% 1+k/10);
    end
    seed_E1         = bwmorph(seed,'endpoints');
    if mod(k,200)==0
        % dilation is normally ones(3) except every 100 to allow cases that have been broken by 1 pixel
        seed_d          = imdilate(seed_E1,ones(7));
        %seed_d          = imdilate(seed_E1,[0 1 1 1 0;1 1 1 1 1;1 1 1 1 1;1 1 1 1 1; 0 1 1 1 0]);

    elseif mod(k,900)==0
        seed_d          = imdilate(seed_E1,ones(15));
    else
        seed_d          = imdilate(seed_E1,[1 1 1;1 1 1;1 1 1]);
    end

    %   seed_d      = imdilate(seed_d1,[0 1 0;1 1 1;0 1 0]);
    % curr        = (a8==k);
    % curr_L      = bwlabel(curr);
    % curr_keep1  = unique(curr_L.*seed_d);
    % curr_keep   = ismember(curr_L,curr_keep1(2:end));

    if mod(k,100)==0
        % imagesc(2*seed+seed_d)
        % axis([3700 4300 3800 4700])  % fig 4
        % axis([2100 2700 3000 3500])    % fig 1
        % axis ([2100 2600 2700 3200])
        % axis ([3200 3800 3600 4200])
        % drawnow
        % pause(0.0001)
    end
    % disp(k)
    n_seed = sum(sum(seed>0));
    seed            = seed|(seed_d.*(watershedIntensity>(maxIntensity2-floor(k/10))));
    n_seed2 = sum(sum(seed>0));

    %disp([k -n_seed+n_seed2])
end
%% Once the main region growing is finished, join the layers, label and join one by one
% Then spur, remove small holes and then find points touching Y junctions
% and X junctions, H junctions



%% Post process, fill small holes
% Imfill holes may fill the lumen and everything else. It is necessary to check
% that it only fills small holes
seedFilled          = imfill(seed,'holes');
seedHoles           = bwlabel(seedFilled-seed);
seedHoles_P         = regionprops(seedHoles,'Area','MajorAxisLength','MinorAxisLength');

seed1               = seed|ismember(seedHoles,find([seedHoles_P.MinorAxisLength]<20));
seed2               = bwmorph(seed1,'thin','inf');
%imagesc(2*seed2+seed)


elastinLayers       = seed2;




