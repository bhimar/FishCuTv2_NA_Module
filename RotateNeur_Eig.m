function RotatedNeur = RotateNeur_Eig(neur, neurCC)
%Rotates the neural arch by computing the eigenvectors
%and calculating the angles needed to rotate the principle eigenvector
%to be aligned with the vertical axis (in this case the x axis)
%PARAMS: neurCC is the editted component data of the neural arch
%RETURNS: RotatedNeur is a logical stack of the neural arch after rotation

%regionprops3 to get eigenvectors
props = regionprops3(neurCC,'EigenVectors','EigenValues','Centroid');
vecs = props.EigenVectors{1};
vals = props.EigenValues{1};
[~ , ind] = max(vals);

%first eigenvector is the principle one
%reference https://www.mathworks.com/matlabcentral/answers/398669-eigenvectors-and-eigenvalues-from-regionprops3
princVec = vecs(:,ind);

%working in xyz space is much easier than in ijk space -> the coordinates
%are exactly the same but the axes are visualized differently: x is rows, y
%is cols, z is pages
[x, y, z] = ind2sub(size(neur),find(neur));
centroid = props.Centroid;
centroid = centroid';

%visualize unrotated neural arch: xy plane is the optimal projection plane
scatter3(x,y,z);
hold on
longaxis = centroid + [-15:15] .* princVec;
longaxis = longaxis';
scatter3(longaxis(:,1), longaxis(:,2), longaxis(:,3), 'r*');
xaxis = centroid + [-15:15] .* [1;0;0];
xaxis = xaxis';
scatter3(xaxis(:,1), xaxis(:,2), xaxis(:,3), 'g*');
hold off

%alignment with xvec consists of two rotations: (1) rotate princVec into
%xz plane(2) rotate the princVec to xy plane

%angle for rotation (1)
princVec_xy = [princVec(1);princVec(2)];
phi = acosd(dot(princVec_xy,[1;0]) / (norm(princVec_xy)));
if(phi > 90)
    phi = 180 - phi;
end
if(prod(princVec_xy) > 0)
    phi = -1 * phi;
end

zrot = [
        cosd(phi) -sind(phi) 0
        sind(phi) cosd(phi) 0
        0 0 1];
rotprincvec_z = zrot * princVec;

%angle for rotation (2)
princVec_xz = [rotprincvec_z(1);rotprincvec_z(3)];
theta = acosd(dot(princVec_xz,[1;0]) / (norm(rotprincvec_z)));
if(theta > 90)
   theta = 180 - theta; 
end
if(prod(princVec_xz) < 0)
    theta = -1 * theta;
end

yrot = [
        cosd(theta) 0 sind(theta)
        0 1 0
        -sind(theta) 0 cosd(theta)];
    
rotprincvec_y = yrot * rotprincvec_z;

newaxis = centroid + [-15:15] .* rotprincvec_y;
newaxis = newaxis';
hold on
figure(1);
scatter3(newaxis(:,1), newaxis(:,2), newaxis(:,3), 'b.');
hold off

%transformations: 
%(1) translate centroid to the origin
%(2) rotate around z axis by phi
%(3) rotate around y axis by theta
%(4) translate to make all positive coordinates

neurxyz = [x y z]';

%(1)
transVec = [-1*centroid;1];
transMat = [
            1 0 0 transVec(1)
            0 1 0 transVec(2)
            0 0 1 transVec(3)
            0 0 0 1];

transneur = neurxyz;
transneur(4,:) = 1;
transneur = transMat * transneur;
transneur(4,:) = [];
neurxyz = transneur;

%(2)
neurxyz = zrot * neurxyz;

%(3)
neurxyz = yrot * neurxyz;

%(4)
min_x = min(neurxyz(1,:));
min_y = min(neurxyz(2,:));
min_z = min(neurxyz(3,:));
reverseTransVec = -1 * [min_x;min_y;min_z];
reverseTransVec = reverseTransVec + 1;
invtransMat = [
            1 0 0 reverseTransVec(1)
            0 1 0 reverseTransVec(2)
            0 0 1 reverseTransVec(3)
            0 0 0 1];

invtransneur = neurxyz;
invtransneur(4,:) = 1;
invtransneur = invtransMat * invtransneur;
invtransneur(4,:) = [];
neurxyz = invtransneur;

newcentroid = invtransMat * [0;0;0;1];
newcentroid(4) = [];

%visualize rotation result
neurxyz = neurxyz';
x2 = neurxyz(:,1);
y2 = neurxyz(:,2);
z2 = neurxyz(:,3);
scatter3(x2,y2,z2);
hold on
longaxis = newcentroid + [0:30] .* rotprincvec_y;
longaxis = longaxis';
scatter3(longaxis(:,1), longaxis(:,2), longaxis(:,3), 'r.');
xaxis = newcentroid + [0:30] .* [1;0;0];
xaxis = xaxis';
scatter3(xaxis(:,1), xaxis(:,2), xaxis(:,3), 'g*');
hold off

%export to a matrix stack
max_x = ceil(max(neurxyz(:,1)));
max_y = ceil(max(neurxyz(:,2)));
max_z = ceil(max(neurxyz(:,3)));
RotNeurMask = ones(max_x,max_y,max_z);
RotatedNeur = zeros(size(RotNeurMask));
RotatedNeur(sub2ind(size(RotNeurMask),round(x2),round(y2),round(z2))) = 1;

RotatedNeur = logical(RotatedNeur);


end