function [NaMajAx,NaMinAx,NaArea,NaEffArea] = ...
          NeurSpaceAShape(n,neuralImage,NaMajAx, ...
                          NaMinAx,NaArea,NaEffArea)
% Computes measurements (area, effective area, axes lengths) 
%   on the neural arch space
% For Integration into FishCuTv2, this module will go at the end of
%   NeuralArchMeasurements.m in the Measurements section
% params:
%   neuralImage = image stack of neural arch
% returns:
%   all returns = measurements calculated

% Data Preparation for Measurements 
    
    %like in the rest of FishCuT, the neural arch is considered all of the
    %bone of the vertebra above the upper user inputted coordinates
    neur = logical(neuralImage);

%% Orient Neural Arch for Projection
    %in order to take cross sectional measurements of the neural arch space
    %we must orient it optimally in the projection plane
    %we use the loose alpha shape to increase power of orientation algorithm
    
    close all;
    neurCC = bwconncomp(neur);
    pix = neurCC.PixelIdxList;
    catpix = [];
    for i = 1:size(pix,2)
       catpix = [catpix ; pix{i}];  
    end
    neurCC.PixelIdxList{1} = catpix;
    neurCC.PixelIdxList = {neurCC.PixelIdxList{1}};
    neurCC.NumObjects = 1;
    
    %TESTING AND DEV - Replaces everything after the next line
    rotatedneur = RotateNeur_Eig(neur, neurCC);
    
    %SEE oldrot.m for old rotation algorithm

%% Filtration code for high segmentation would go here if needed
    %see filterCode.m

%% Measure and Visualize 2D projecion
    %the measurements are recorded by taking the area of the
    %projected space and the effective area, major, and minor axes
    %of an ellipse that is automatically fit to the space
    
    %in order to get the neural arch space,use the 2D alphashape of the projection
    %for segmenting the space before fitting an ellipse
    projection = max(rotatedneur,[],3);

    [projx, projy] = ind2sub(size(projection),find(projection));
    projShape = alphaShape(projx,projy);
    Acrit = projShape.criticalAlpha('one-region');
    valid = size(Acrit);
    if(~(valid(1) == 0 && valid(2) == 0)) 
        spec = projShape.alphaSpectrum();
        idx = find(spec == Acrit);
        subspec = spec(1:idx);
        subspec = flipud(subspec);
        idx = max(ceil((0.5)*numel(subspec)),1);
        alphaval = subspec(idx);
        projShape.Alpha = alphaval;
        fill = ones(size(projection));
        [a,b] = ind2sub(size(projection),find(fill));
        tf = inShape(projShape,a,b);
        %'points' is the points inside the loose alphaShape
        points = [a,b];
        points(~tf,:) = [];
        figure(3); plot(projShape);
    
        filledproj = zeros(size(projection));
        filledproj(sub2ind(size(projection),points(:,1),points(:,2))) = 1;
        space2d = xor(projection, filledproj);
        spaceCCs = bwconncomp(space2d); 
        numOfPixels = cellfun(@numel,spaceCCs.PixelIdxList);
        [~,indexOfMax] = max(numOfPixels);
        biggest = zeros(size(space2d));
        biggest(spaceCCs.PixelIdxList{indexOfMax}) = 1;
        space2d = biggest;
    
    %fit ellipse and record measurements
        properties = regionprops(space2d,'AREA','Centroid','MinorAxisLength','MajorAxisLength','Orientation');
        AREA = cat(1,properties.Area);
        MINAX = cat(1,properties.MinorAxisLength);
        MAJAX = cat(1,properties.MajorAxisLength);
        EFFAREA = pi * MINAX * MAJAX;
        NaArea(n) = AREA;
        NaMinAx(n) = MINAX;
        NaMajAx(n) = MAJAX;
        NaEffArea(n) = EFFAREA;
    
        %for visualiation
        centroid = cat(1,properties.Centroid);
        majAng = cat(1,properties.Orientation);

%%  Data Visualization
        %2D Data Visualization
        %visualize ellipse  
        imshow(projection);
        hold on
        plot(centroid(1),centroid(2),'b.','MarkerSize',0.25);
        phi = linspace(0,2*pi,50);
        cosphi = cos(phi);
        sinphi = sin(phi);
        xbar = centroid(1);
        ybar = centroid(2);
        a = MAJAX/2;
        b = MINAX/2;
        theta = deg2rad(majAng);
        R = [cos(theta) sin(theta)
             -sin(theta) cos(theta)];
        xy = [a*cosphi;b*sinphi];
        xy = R*xy;
        x = xy(1,:) + xbar;
        y = xy(2,:) + ybar;
        plot(x,y,'g','LineWidth',0.1);
        pause(1);
        %3D visualization as point cloud
        [x,y,z] = ind2sub(size(rotatedneur),find(rotatedneur));
        [a,b,c] = ind2sub(size(neur),find(neur));
        figure(5);
        scatter3(x,y,z,'r*');
        hold on
        scatter3(a,b,c,'b.');
    
    else
       NaArea(n) = NaN;
       NaMinAx(n) = NaN;
       NaMajAx(n) = NaN;
       NaEffArea(n) = NaN;
    end
    %for development/debugging reasons
    %input('press "Enter" to continue');
    close all
end
