function [NeuralFMinA,NeuralFMajA,NeuralForamenImages]...
          = NeuralForamenMeasurementOld...
          (uppercentrumx1,lowercentrumx1,subImg,n,NeuralFMinA,NeuralFMajA,NeuralForamenImages)
% measures the major and minor axes of the neural foramen
% params:
%   uppercentrumx1 = ant. upper bound (inferior) of centrum
%   lowercentrumx1 = ant. lower bound (superior) of centrum
%   subImg = grayscale image of a single vertebra
% returns:
%   All Returns = measurements for data analysis

    %rotate vertebra to account for scoliosis or tilted scanning
    centrumHeight1 = uppercentrumx1 - lowercentrumx1;
    subHalf = subImg(1:ceil(lowercentrumx1 + centrumHeight1/2),:,:);
    bwHalf = subHalf;
    bwHalf = imbinarize(bwHalf);
    archonly = bwHalf(1:ceil(lowercentrumx1),:,:);
    archonlymip = squeeze(max(archonly,[],1));
    box = regionprops(archonlymip,"BoundingBox","Area");
    areas = cat(1,box.Area);
    [~,ind] = max(areas);
    box = cat(1,box.BoundingBox);
    box = box(ind,:);
    boxy = box(2);
    boxheight = box(4);
    isoArch = bwHalf;
    isoArch(:,1:floor(boxy),:) = 0;
    isoArch(:,ceil(boxy+boxheight):end,:) = 0;
    centrum = imbinarize(subImg(ceil(lowercentrumx1):floor(uppercentrumx1),:,:));
    props = regionprops3(centrum,'Orientation','Volume');
    [~,ind] = max(cat(1,props.Volume));
    angs = cat(1,props.Orientation);
    angs = angs(ind,:);
    rotAng = angs(2);
    perm = permute(isoArch,[2 3 1]);
    rotperm = imrotate(perm,rotAng);
    isoArchRot = ipermute(rotperm,[2 3 1]);
    branchmip = squeeze(max(isoArchRot,[],3));
    branchskel = bwmorph(branchmip,'skel',Inf);
    branchpoints = bwmorph(branchskel,'branchpoints');
    [rows,~] = find(branchpoints);
    fork = min(rows);
    isoArchRot(1:fork,:,:) = 0;
    slice = squeeze(isoArchRot(fork+1,:,:));
    [~, cols] = find(slice);
    archend = max(cols);
    isoArchRot(:,:,archend:end) = 0;
    orientation = regionprops3(isoArchRot,'Orientation');
    orientation = cat(1,orientation.Orientation);
    ang = orientation(3);
    projstack = permute(isoArchRot,[1 3 2]);
    projstack = imrotate(projstack,ang);
    projstack = ipermute(projstack,[1 3 2]);
    mip = squeeze(max(projstack,[],3)); 
    
    
    %rotate neural arch and project
%     sagittalMIP = squeeze(max(isoArchRot,[],2));
%     archMIP = sagittalMIP;
%     archMIP(lowercentrumx1:end,:) = 0;
%     ang = regionprops(archMIP,'Area','Orientation');
%     areas = cat(1,ang.Area);
%     [~, ind] = max(areas);
%     ang = cat(1,ang.Orientation);
%     ang = ang(ind);
%     if ang > 0
%        rotangle = 90-ang;
%     else
%         rotangle = 90 + ang;
%     end
%     rotArchMIP = imrotate(archMIP,rotangle);
%     
%     propsRotArch = regionprops(rotArchMIP,'BoundingBox','Area');
%     areas = cat(1,propsRotArch.Area);
%     [~,ind] = max(areas);
%     box = cat(1,propsRotArch.BoundingBox);
%     box = box(ind,:);
%     cornerCoord = [box(1),box(2)];
%     width = [box(3),box(4)];
%     projection range
%     lowerZ = floor(cornerCoord(1)-1);
%     upperZ = ceil(cornerCoord(1)+ceil(width(1)));
%         
%     use imrotate instead of imrotate3 for efficiency
%     perm = permute(isoArchRot,[1 3 2]);
%     rotperm = imrotate(perm,rotangle);
%     isoArchRot = ipermute(rotperm,[1 3 2]);
%     archStack = isoArchRot(:,:,lowerZ:upperZ);
%     archProj = squeeze(max(archStack,[],3));
%     param 2 for bridgeCloseEnds function can be change: see fxn file
%     archProj = bridgeCloseEnds(archProj,7);
%     archProj = bwmorph(archProj,'diag');
%     
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