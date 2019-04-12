%sandbox file for testing alphaShape capabilities

%given that 'neur' variable is a 3D logical array of the neural arch

%construct tight alphaShape
[x,y,z] = ind2sub(size(neur),find(neur));
shp1 = alphaShape([x,y,z]);
fill = ones(size(neur));
[a,b,c] = ind2sub(size(neur),find(fill));
tf = inShape(shp1,a,b,c);
points = [a,b,c];
points(~tf,:) = [];
bonemat = zeros(size(neur));
bonemat(sub2ind(size(neur),points(:,1),points(:,2),points(:,3))) = 1;

%construct loose alphaShape (with filled in neural arch space)
[x,y,z] = ind2sub(size(neur),find(neur));
shp2 = alphaShape([x,y,z]);
Acrit = shp2.criticalAlpha('one-region');
spec = shp2.alphaSpectrum();
idx = find(spec == Acrit);
subspec = spec(1:idx);
subspec = flipud(subspec);
idx = max(ceil((0.5)*numel(subspec)),1);
alphaval = subspec(idx);
shp2.Alpha = alphaval;
fill = ones(size(neur));
[a,b,c] = ind2sub(size(neur),find(fill));
tf = inShape(shp2,a,b,c);
points = [a,b,c];
points(~tf,:) = [];
hullmat = zeros(size(neur));
hullmat(sub2ind(size(neur),points(:,1),points(:,2),points(:,3))) = 1;

%subtract the bone from the hull to get unfiltered negative space
negspace = hullmat;
negspace(logical(bonemat)) = 0;
%filter out negative space with lowest connectivity
cc = bwconncomp(negspace,6);
pixels = cc.PixelIdxList;
filtnegspace = zeros(size(neur));
filtnegspace(pixels{1}) = 1;

%visualize as point cloud
[x,y,z] = ind2sub(size(neur),find(bonemat));
[a,b,c] = ind2sub(size(neur),find(filtnegspace));
scatter3(x,y,z,'r*');
hold on
scatter3(a,b,c,'b.');

    

