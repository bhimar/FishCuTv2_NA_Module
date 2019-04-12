
function [FilteredNA] = NAFilter (rotatedneur, filtnegspace)
%Used to filter out the top of the centrum or other extraneous bone
%that obstructs the projection of the neural arch space
%PARAMS:
%   neur: logical stack of neural arch bone
%   filtnegspace: logical alphashape determined

%make one stack with filtnegspace as -1 and neur as 1 (double)
NACombo = double(rotatedneur);
NACombo(filtnegspace) = -1;

%loop over every slice in the matrix from left to right
for i = 1:size(NACombo,2)
    Slice = squeeze(NACombo(:,i,:));
    %for each column
    for j = 1:size(Slice,1)
        vector = Slice(:,j);%take a row vector from the slice
        %remove all repeated digits except the first
        curval = vector(1);
        for k = 2:length(vector)
            if(vector(k) == curval && vector(k) ~= 0)
               vector(k) = 0; 
            else
               curval = vector(k); 
            end
        end
        %find all nonzero elements, put in a vector
        elements = vector(vector ~= 0);
        %make even indices (indexing starts at 1) equal to abs val
        if(length(vector) > 1)
            for k = 2:2:length(elements)
                elements(k) = abs(elements(k));
            end
        end
        %set entire column of the stack to the product of the vector
        altprod = prod(elements);
        if(altprod == -1)
            NACombo(j,i,:) = 0;
        end
    end
end
%make all non-1 elements equal to zero and convert to logical
NACombo((NACombo == -1)) = 0;
%return matrix as FilteredNA
FilteredNA = logical(NACombo);





end