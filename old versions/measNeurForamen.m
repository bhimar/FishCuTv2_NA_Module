function [NeurArchData,montage] = measNeurForamen(CCStack,VertIDs,coordData,labelImg)
%measures the major and minor axes of each neural arch by rotating
%   a binarized microCT stack and projecting through the neural arch
    NeurArchData = zeros(2,length(VertIDs));%row 1 is major axes, 2 = minor axes
    montage = {[1,length(VertIDs)]};
    dimStack = size(CCStack);
    for vertNum = 1:length(VertIDs)
        %isolate vertebra
        singleVert = uint16(zeros(dimStack));
        for i = 1:length(VertIDs{vertNum})
           component = labelImg;
           thisVertIDs = VertIDs{vertNum};
           component(component ~= thisVertIDs(i)) = 0;
           singleVert = singleVert + component;
        end
        singleVert = logical(singleVert);
        %isolate centrum to compute rotation angles
        centrum = singleVert;
        centrum(1:coordData.xLows(vertNum),:,:) = [];
        centrum(coordData.xHighs(vertNum):end,:,:) = [];
        
        %rotate to align along z-axis (accounts for tilted sagittal plane)
        centrumFrontalMIP = squeeze(max(centrum,[],3));
        angle = regionprops(centrumFrontalMIP,'Area','Orientation');
        areas = angle.Area;
        [~, ind] = max(areas);
        angle = angle.Orientation;
        angle = angle(ind);
        
        %if the image contains part of the ribs/arches, then the axis could
        %   be in the direction of the ribs/arches, not the centrum
        %ASSUMES: if the angle is < 45, then condition above is true
        %   otherwise, it detects the angle of the centrum
        rotangle = -angle;
        if(abs(angle) > 45)
            if(angle > 0)
                rotangle = 90 - angle;
            else
                rotangle = -90 - angle;
            end
        end
        
        %use permutation and imrotate instead of imrotate3 for efficiency
        perm = permute(singleVert,[2 3 1]);
        rotperm = imrotate(perm,rotangle);
        singleVert = permute(rotperm,[3 1 2]);
        
        %rotate to make neural arch perpendicular for projection
        sagittalMIP = squeeze(max(singleVert,[],3));
        archMIP = sagittalMIP;
        archMIP(coordData.xLows(vertNum):end,:) = 0;
        angle = regionprops(archMIP,'Area','Orientation');
        areas = angle.Area;
        [~, ind] = max(areas);
        angle = angle.Orientation;
        angle = angle(ind);
        rotangle = 90-angle;
        rotArchMIP = imrotate(archMIP,rotangle);
        
        %filter any smaller components for computing projection range
        rotccs = bwconncomp(rotArchMIP);
        pixels = rotccs.PixelIdxList;
        index = 1;
        if rotccs.NumObjects > 1
            maxLength = length(pixels{1});
            for j = 2:length(pixels)
               if length(pixels{j}) > maxLength
                  index = j;
                  maxLength = length(pixels{j});
               end
            end
        end
        rotArchMIP = false(size(rotArchMIP));%same as logical(zeros(M))
        rotArchMIP(pixels{index}) = 1;
        
        %compute projection range
        rotArchMIP = bwmorph(rotArchMIP,'thicken');
        propsRotArch = regionprops(rotArchMIP,'BoundingBox');
        box = propsRotArch.BoundingBox;
        cornerCoord = [box(1),box(2)];
        width = [box(3),box(4)];
        %projection range
        lowerZ = floor(cornerCoord(1)-1);
        upperZ = ceil(cornerCoord(1)+ceil(width(1)));
        
        %use imrotate instead of imrotate3 for efficiency
        %no permutation needed, because default axis of rotation used
        singleVert = imrotate(singleVert,rotangle);
        
        archStack = singleVert(:,lowerZ:upperZ,:);
        archProj = squeeze(max(archStack,[],2));
        %param 2 for bridgeCloseEnds function can be change: see fxn file
        archProj = bridgeCloseEnds(archProj,7);
        archProj = bwmorph(archProj,'diag');
        
        %measure major and minor axes for data records
        archProj = ~archProj;
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
        NeurArchData(1,vertNum) = majAx;
        NeurArchData(2,vertNum) = minAx;
        
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
        montage{vertNum} = keepframe;
        close all
    end
    
end