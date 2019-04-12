%Filtration Algorithm for NeurSpaceAShape.m

%% Filtration for if the top of the centrum interferes with projection
    
    %This section of code uses the alphaShape tool to isolate the empty
    %space inside the neural arch, which we are considering the neural
    %arch space. It then runs a filtration algorithm for projection
    %purposes
    
    %alphaShape(args) operates on point clouds not stacks, so the data
    %is converted back and forth
    
    % convert image stack to point cloud
    [x,y,z] = ind2sub(size(rotatedneur),find(rotatedneur));
    
    % construct tight alpha shape that encases bone
    shp1 = alphaShape([x,y,z]);
    figure(1); plot(shp1);

    %construct loose alphaShape (with filled in neural arch space)
    %loose alphashape is the tightest alphashape that encompasses all points
   
    % the loose alphaShape is computed using code from the 'boundary'
    % function which implements alphaShape and changes the alpha radius of the shape
    Acrit = shp1.criticalAlpha('one-region');
    valid = size(Acrit);
    if(~(valid(1) == 0 && valid(2) == 0)) 
        spec = shp1.alphaSpectrum();
        idx = find(spec == Acrit);
        subspec = spec(1:idx);
        subspec = flipud(subspec);
        idx = max(ceil((0.5)*numel(subspec)),1);
        alphaval = subspec(idx);
        shp1.Alpha = alphaval;
        fill = ones(size(rotatedneur));
        [a,b,c] = ind2sub(size(rotatedneur),find(fill));
        tf = inShape(shp1,a,b,c);
        %'points' is the points inside the loose alphaShape
        points = [a,b,c];
        points(~tf,:) = [];
        figure(2); plot(shp1);
    
        % fill alpha shape to get hull(inside loose alphaShape) of neural arch
        hullmat = zeros(size(rotatedneur));
        hullmat(sub2ind(size(rotatedneur),points(:,1),points(:,2),points(:,3))) = 1;

        %subtract the bone from the hull to get unfiltered negative space
        negspace = hullmat;
        negspace(rotatedneur) = 0;%unfiltered negative space

        %depending on the shape of the neural arch, small extra spaces
        %can be included as a part of the negative space, so we filter
        cc = bwconncomp(negspace,6);
        pixels = cc.PixelIdxList;
        numOfPixels = cellfun(@numel,pixels);
        [~,indexOfMax] = max(numOfPixels);
        filtnegspace = zeros(size(rotatedneur));
        filtnegspace(pixels{indexOfMax}) = 1;
        %filtnegspace is a stack of the neural arch space

        display = double(rotatedneur);
        display(filtnegspace == 1) = -1;
        disp3D(display);
        
        %FILTNEGSPACE will be used to filter out any centrum parts
        %FilteredNA = NAFilter (rotatedneur, logical(filtnegspace));
        %disp3D(FilteredNA);
        %figure(2); disp3D(rotatedneur);
        %rotatedneur = FilteredNA;
    end