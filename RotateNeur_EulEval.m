function RotatedNeur = RotateNeur_EulEval(neur, neurCC)
%Rotates the neural arch by computing the Euler Angls
%and rotating to be in line with the cartesian axes
%PARAMS: neurCC is the editted component data of the neural arch
%RETURNS: RotatedNeur is a logical stack of the neural arch after rotation

[x,y,z] = ind2sub(size(neur),find(neur));
props = regionprops3(neurCC, 'Orientation');

eulangs = props.Orientation;
inveul = (eul2rotm(deg2rad(eulangs)))';
neurxyz = [x y z]';
rotneurxyz = inveul * neurxyz;

% translate to positive coordinates
min_x = min(rotneurxyz(1,:));
min_y = min(rotneurxyz(2,:));
min_z = min(rotneurxyz(3,:));
reverseTransVec = -1 * [min_x;min_y;min_z];
reverseTransVec = reverseTransVec + 1;
invtransMat = [
            1 0 0 reverseTransVec(1)
            0 1 0 reverseTransVec(2)
            0 0 1 reverseTransVec(3)
            0 0 0 1];

invtransneur = rotneurxyz;
invtransneur(4,:) = 1;
invtransneur = invtransMat * invtransneur;
invtransneur(4,:) = [];
rotneurxyz = invtransneur';


x2 = rotneurxyz(:,1);
y2 = rotneurxyz(:,2);
z2 = rotneurxyz(:,3);
max_x = ceil(max(x2));
max_y = ceil(max(y2));
max_z = ceil(max(z2));
RotNeurMask = ones(max_x,max_y,max_z);
RotatedNeur = zeros(size(RotNeurMask));
RotatedNeur(sub2ind(size(RotNeurMask),round(x2),round(y2),round(z2))) = 1;
RotatedNeur = logical(RotatedNeur);

%visualize new axes
rotneurCC = bwconncomp(RotatedNeur);
pix = rotneurCC.PixelIdxList;
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
end