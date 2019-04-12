function [NeuralFMinA,NeuralFMajA,NeuralForamenImages]...
          = NeuralForamenMeasurementOldV2...
          (uppercentrumx1,lowercentrumx1,subImg,n,NeuralFMinA,NeuralFMajA,NeuralForamenImages)
% measures the major and minor axes of the neural foramen
% params:
%   uppercentrumx1 = ant. upper bound (inferior) of centrum
%   lowercentrumx1 = ant. lower bound (superior) of centrum
%   subImg = grayscale image of a single vertebra
% returns:
%   All Returns = measurements for data analysis

    %rotate vertebra to account for scoliosis or tilted scanning
    midcentrumx1 = floor((uppercentrumx1 + lowercentrumx1)/2);
    isoArch = imbinarize(subImg);
    isoArch(midcentrumx1:end,:,:) = 0;
    %NOTE: added isoArchRot for testing (need to implement corrective
    %rotation)
    isoArchRot = isoArch;

    
    %isolate just the arch
    branchmip = squeeze(max(isoArchRot,[],3));
    branchskel = bwmorph(branchmip,'skel',Inf);
    branchskel = bridgeCloseEnds(branchskel,7);
    for j = 1:25
       branchskel = bwmorph(branchskel,'spur'); 
    end
    branchskel = bwmorph(branchskel,'clean');
    branchpoints = bwmorph(branchskel,'branchpoints');
    [branchrows,~] = find(branchpoints);
    fork = min(branchrows);
    branchskel(fork:end,:) = 0;
    angle = regionprops(branchskel,'Orientation');
    angle = cat(1,angle.Orientation);
    angle = angle(1);
    negative = 1;
    if(angle < 0)
       negative = -1; 
    end
    isoArchRot = imrotate(isoArchRot,negative * 90-angle);
    branchmip = squeeze(max(isoArchRot,[],3));
    branchskel = bwmorph(branchmip,'skel',Inf);
    branchskel = bridgeCloseEnds(branchskel,7);
    for j = 1:25
       branchskel = bwmorph(branchskel,'spur'); 
    end
    branchskel = bwmorph(branchskel,'clean');
    branchpoints = bwmorph(branchskel,'branchpoints');
    [branchrows,~] = find(branchpoints);
    fork = min(branchrows);
    isoArchRot(1:fork-1,:,:) = 0;
    slice = squeeze(isoArchRot(fork,:,:));
    [~, cols] = find(slice);
    archend = max(cols);
    isoArchRot(:,:,archend:end) = 0;
    
    %make the neural arch perpendicular
    arch = isoArchRot;
    box = regionprops(branchskel,'BoundingBox');
    box = cat(1,box.BoundingBox);
    box = box(1,:);
    bottomarch = box(2)+box(4);
    arch(floor(bottomarch-2):end,:,:) = 0;
    props = regionprops3(arch,'Orientation','Volume');
    vol = cat(1,props.Volume);
    [~,ind] = max(vol);
    angs = cat(1,props.Orientation);
    angs = angs(ind,:);
    ang = angs(2);
    arch = permute(arch,[1 3 2]);
    arch = imrotate(arch,ang);
    arch = ipermute(arch,[1 3 2]);
    archproj = squeeze(max(arch,[],2));
    props = regionprops(archproj,'BoundingBox','Area');
    area = cat(1,props.Area);
    [~,ind] = max(area);
    box = cat(1,props.BoundingBox);
    box = box(ind,:);
    projstack = permute(isoArchRot,[1 3 2]);
    projstack = imrotate(projstack,ang);
    projstack = ipermute(projstack,[1 3 2]);
    projstack(:,:,1:(floor(box(1)-1))) = 0;
    projstack(:,:,(ceil(box(1)) + ceil(box(3)+1):end)) = 0;
    mip = squeeze(max(projstack,[],3));
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
    grayframe = rgb2gray(keepframe);
    bwframe = imbinarize(grayframe);
    invertedframe = ~bwframe;
    %crop keepframe to include only necessary image space
    boxframeprops = regionprops(invertedframe,'Area','BoundingBox');
    areas = boxframeprops.Area;
    [~,ind] = max(areas);
    box = cat(1,boxframeprops.BoundingBox);
    box = box(ind,:);
    keepframe = imcrop(keepframe,box);
    NeuralForamenImages{n} = keepframe;
end