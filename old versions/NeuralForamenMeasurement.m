function [NeuralFMinA,NeuralFMajA,NeuralForamenImages]...
          = NeuralForamenMeasurement...
          (subImg,uppercentrumx1,lowercentrumx1,n,NeuralFMinA,NeuralFMajA,NeuralForamenImages)
% measures the major and minor axes of the neural foramen
% params:
%   uppercentrumx1 = ant. upper bound (inferior) of centrum
%   lowercentrumx1 = ant. lower bound (superior) of centrum
%   subImg = grayscale image of a single vertebra
% returns:
%   All Returns = measurements for data analysis

    bwSubImg = logical(subImg);
    bwSubImg(uppercentrumx1:end,:,:) = 0;
    zMip = squeeze(max(bwSubImg,[],3));
    %create border to prevent false detection of foramen
    zMip(1,:) = 0; zMip(end,:)=0; zMip(:,1) = 0; zMip(:,end) = 0;
    %fill small holes neural arch (e.g. the centrum foramen)
    CC = bwconncomp(~zMip);
    holes = regionprops(CC,'Area');
    areas = cat(1,holes.Area);
    [~,ind] = max(areas);
    areas(ind) = [];
    CC.PixelIdxList(ind) = [];
    filter = (areas < 70); %THRESHOLD
    CC.PixelIdxList(~filter) = [];
    for j = 1:size(CC.PixelIdxList,2)
        zMip(CC.PixelIdxList{j}) = 1;
    end
        
    %detect orientation in frontal plane and rotate accordingly
    skel = bwmorph(zMip,'skel',Inf);
    skel = bwmorph(skel,'spur',Inf);
    invskel = ~(bwmorph(skel,'diag'));
    % if all pixels are lower than lowercentrum x1, it must be nonunion
    [rows,~] = find(skel);
    minrow = min(rows);
    if minrow >= floor(lowercentrumx1)
        NeuralFMajA(n) = 0;
        NeuralFMinA(n) = 0;
        disp(['Vertebra ' num2str(n) 'is predicted to have neural arch nonunion'])
        imshow(~zMip)
        keepframe = getframe;
        keepframe = keepframe.cdata;
        NeuralForamenImages{n} = keepframe;
        close all
        return
    end
    holes = regionprops(invskel,'Area','Orientation');
    areas = cat(1,holes.Area);
    angle = cat(1,holes.Orientation);
    filter = areas < 10;%THRESHOLD
    areas(filter) = [];
    angle(filter) = [];
    [~,ind] = max(areas);
    areas(ind) = 0;
    if areas == 0
        NeuralFMajA(n) = 0;
        NeuralFMinA(n) = 0;
        disp(['Vertebra ' num2str(n) 'is predicted to have neural arch nonunion'])
        imshow(~zMip)
        keepframe = getframe;
        keepframe = keepframe.cdata;
        NeuralForamenImages{n} = keepframe;
        close all
        return
    end
    [~,ind] = max(areas);
    rotangle = angle(ind);
    sign = 0;
    if rotangle < 0
        sign = -1;
    elseif rotangle > 0
        sign = 1;
    end
    rotangle = sign * 90 - rotangle;
    bwSubImg = imrotate(bwSubImg,rotangle);
    
    %isolate neural arch around the foramen
    zMip = squeeze(max(bwSubImg,[],3));
    zMip(1,:) = 0; zMip(end,:)=0; zMip(:,1) = 0; zMip(:,end) = 0;
    zMip = bwmorph(zMip,'diag');
    holes = regionprops(~zMip,'Area','BoundingBox');  
    areas = cat(1,holes.Area);
    boxes = cat(1,holes.BoundingBox);
    filter = (areas < 10);%THRESHOLD
    areas(filter) = [];
    boxes(filter,:) = [];
    [~,ind] = max(areas);
    areas(ind) = 0;
    if areas == 0
        NeuralFMajA(n) = 0;
        NeuralFMinA(n) = 0;
        disp(['Vertebra ' num2str(n) ' is predicted to have neural arch nonunion'])
        imshow(~zMip)
        keepframe = getframe;
        keepframe = keepframe.cdata;
        NeuralForamenImages{n} = keepframe;
        close all;
        return
    end
    [~,ind] = max(areas);
    box = boxes(ind,:);
    top = floor(box(2)-1);
    holes = regionprops(~zMip,'Area','BoundingBox'); 
    areas = cat(1,holes.Area);
    boxes = cat(1,holes.BoundingBox);
    [~,ind] = max(areas);
    areas(ind) = 0;
    [~,ind] = max(areas);
    box = boxes(ind,:);
    bottom = floor(box(2)) + floor(box(4))-1;
    archvolume = bwSubImg;
    archvolume(bottom:end,:,:) = 0;
    archvolume(1:top,:,:) = 0;
    components = bwconncomp(archvolume);
    indexes = components.PixelIdxList;
    pixels = cellfun(@numel,indexes);
    [~,ind] = max(pixels);
    inds = 1:size(pixels,2);
    inds = inds(inds ~= ind);
    for j = 1:size(inds,2)
       archvolume(indexes{inds(j)}) = 0; 
    end
    %detect neural arch angle
    archmip = squeeze(max(archvolume,[],2));
    archmip = bwmorph(archmip,'bridge','fill');
    angle = regionprops(archmip,'Orientation','Area');
    areas = cat(1,angle.Area);
    angle = cat(1,angle.Orientation);
    if size(angle,1) > 1
        [~,ind] = max(areas);
        angle = angle(ind);
    end
    if angle < 0
       angle = 90;
    end
    rotangle = 90-angle;

    bwSubImg = permute(bwSubImg,[1 3 2]);
    bwSubImg = imrotate(bwSubImg,rotangle);
    bwSubImg = ipermute(bwSubImg,[1 3 2]);
    archmip = imrotate(archmip,rotangle);
    archmip = bwmorph(archmip,'thicken');
    [~,cols] = find(archmip);
    left = min(cols) - 1;
    right = max(cols) + 1;
    bwSubImg(:,:,1:left) = 0;
    bwSubImg(:,:,right:end) = 0;
    mip = squeeze(max(bwSubImg,[],3));
    mip = bwmorph(mip,'fill');
    close all
    mip = bridgeCloseEnds(mip,5);
    mip = bwmorph(mip,'diag');
    
    %measure the neural foramen
    archProj = ~mip;
    imshow(archProj);
    hold on;
    propsArchProj = regionprops(archProj,'Centroid','Area','MinorAxisLength','MajorAxisLength','Orientation');
    centroids = cat(1,propsArchProj.Centroid);
    areas = cat(1,propsArchProj.Area);
    [~, centIdx] = max(areas);
    areas(centIdx) = 0;
    [area, centIdx] = max(areas);
    if area > 0 %if there is a component besides the background(removed)
        naCent = centroids(centIdx,:);
        minAx = cat(1,propsArchProj.MinorAxisLength);
        minAx = minAx(centIdx);
        majAx = cat(1,propsArchProj.MajorAxisLength);
        majAx = majAx(centIdx);
        majAng = cat(1,propsArchProj.Orientation);
        majAng = majAng(centIdx);
        %plot ellipse
        xCentroid = naCent(1);
        yCentroid = naCent(2);
        plot(xCentroid,yCentroid,'b.','MarkerSize',0.25)
        phi = linspace(0,2*pi,50);
        cosphi = cos(phi);
        sinphi = sin(phi);
        xbar = xCentroid;
        ybar = yCentroid;
        a = majAx/2;
        b = minAx/2;
        theta = deg2rad(majAng);
        R = [cos(theta) sin(theta)
             -sin(theta) cos(theta)];
        xy = [a*cosphi;b*sinphi];
        xy = R*xy;
        x = xy(1,:) + xbar;
        y = xy(2,:) + ybar;
        plot(x,y,'r','LineWidth',0.1);
    else
        minAx = 0;
        majAx = 0;
    end
    hold off
    NeuralFMajA(n) = majAx;
    NeuralFMinA(n) = minAx;

    %preprocess for cropping
    keepframe = getframe;
    keepframe = keepframe.cdata;
    NeuralForamenImages{n} = keepframe;
end