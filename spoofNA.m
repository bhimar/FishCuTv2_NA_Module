%used to spoof data for NAFilter:
function NASpoof = spoofNA(neur)
%creates a spoof of the neural arch data by putting a horizontal rectangle
%at the bas of the neural arch. used to test the NAFilter.m script
%params: neur is a logical stack of the neural arch bone
%return: NASpoof is logical and contains neur + the rectangle

%get the connected components of the neur and evaluate as single component
neurCC = bwconncomp(neur);
pix = neurCC.PixelIdxList;
catpix = [];
for i = 1:size(pix,2)
   catpix = [catpix ; pix{i}];  
end
neurCC.PixelIdxList{1} = catpix;
neurCC.PixelIdxList = {neurCC.PixelIdxList{1}};
neurCC.NumObjects = 1;
%get the bounding box coordinates and measurements to compute the size and
%position of the rectangle
props = regionprops3(neurCC,'BoundingBox');
%props in form: [ulf_x ulf_y ulf_z width_x width_y width_z]
bb = props.BoundingBox;
ulf = bb(1:3);
width = bb(4:6);
A = ulf + [width(1) 0 0];
C = A + [0 width(2) width(3)];
coordA = [A(2) A(3)];
coordC = [C(2) C(3)];
coordA = ceil(coordA);
coordC = floor(coordC);
height = A(1);
height = ceil(height);
NASpoof = neur;
NASpoof(height,coordA(1):coordC(1),coordA(2):coordC(2)) = 1;





end
