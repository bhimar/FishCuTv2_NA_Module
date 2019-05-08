function RotatedNeur = RotateNeur_EulEval(neur, neurCC)
%Rotates the neural arch by computing the Euler Angls
%and rotating to be in line with the cartesian axes
%PARAMS: neurCC is the editted component data of the neural arch
%RETURNS: RotatedNeur is a logical stack of the neural arch after rotation

[x,y,z] = ind2sub(size(neur),find(neur));
props = regionprops3(neurCC, 'Orientation');

eulangs = props.Orientation;
inveul = eul2rotm(-1 * eulangs);
neurxyz = [x y z]';
rotneurxyz = inveul * neurxyz;
max_x = ceil(max(rotneurxyz(:,1)));
max_y = ceil(max(rotneurxyz(:,2)));
max_z = ceil(max(rotneurxyz(:,3)));
RotNeurMask = ones(max_x,max_y,max_z);
RotatedNeur = zeros(size(RotNeurMask));
RotatedNeur(sub2ind(size(RotNeurMask),round(x2),round(y2),round(z2))) = 1;
RotatedNeur = logical(RotatedNeur);

%visualize new axes
neurCC = bwconncomp(RotatedNeur);
pix = neurCC.PixelIdxList;
catpix = [];
for i = 1:size(pix,2)
   catpix = [catpix ; pix{i}];  
end
rotneurCC.PixelIdxList{1} = catpix;
rotneurCC.PixelIdxList = {rotneurCC.PixelIdxList{1}};
rotneurCC.NumObjects = 1;

[x,y,z]=ind2sub(size(RotatedNeur),find(RotatedNeur));
props = regionprops3(rotneurCC, 'Orientation','EigenVectors','EigenValues','Centroid');

vecs = props.EigenVectors{1};
centroid = props.Centroid;
centroid = centroid';

princvec = vecs(:,1);
secondvec = vecs(:,2);
thirdvec = vecs(:,3);

%visualize axes
scatter3(x,y,z);
hold on
longaxis = centroid + [-15:0.25:15] .* princvec;
longaxis = longaxis';
secondaxis = centroid + [-10:0.25:10] .* secondvec;
secondaxis = secondaxis';
thirdaxis = centroid + [-10:0.25:10] .* thirdvec;
thirdaxis = thirdaxis';
scatter3(longaxis(:,1),longaxis(:,2),longaxis(:,3),'r*')
scatter3(secondaxis(:,1),secondaxis(:,2),secondaxis(:,3),'b*')
scatter3(thirdaxis(:,1),thirdaxis(:,2),thirdaxis(:,3),'g*')
hold off
input('press "Enter" to continue');
RotatedNeur = 0;
end