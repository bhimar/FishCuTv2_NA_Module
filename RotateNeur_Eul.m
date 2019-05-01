function RotatedNeur = RotateNeur_Eul(neur, neurCC)
%Rotates the neural arch by computing the Euler Angls
%and rotating to be in line with the cartesian axes
%PARAMS: neurCC is the editted component data of the neural arch
%RETURNS: RotatedNeur is a logical stack of the neural arch after rotation

props = regionprops3(neurCC, 'Orientation','EigenVectors','EigenValues','Centroid');

eulangs = props.Orientation;
vecs = props.EigenVectors{1};
centroid = props.Centroid;
centroid = centroid';

princvec = vecs(:,1);
secondvec = vecs(:,2);
thirdvec = vecs(:,3);

[x,y,z] = ind2sub(size(neur),find(neur));

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

RotatedNeur = 0;
end