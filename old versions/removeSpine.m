function newNeur = removeSpine(neur)
    %given a 3D stack of a neural arch, removes the neural spine
    %returns a 3D stack of the neural arch without the spine

    %slice from the top and continue slicing until 2 or more connected
    %components
    spinefork = false;
    xLocation = 1;
    while(spinefork == false && xLocation < size(neur,1))
        slice = squeeze(neur(xLocation,:,:));
        cc = bwconncomp(slice);
        if (cc.NumObjects >= 2)
           pixels = cc.PixelIdxList;
           objectSizes = cellfun(@numel,pixels);
           % condition: the size of at least 2 objects is greater than 5
           if (numel(find(objectSizes >= 3)) >= 2)
              spinefork = true; 
           else
              xLocation = xLocation + 1;
           end
        else
           xLocation = xLocation + 1; 
        end
    end
    
    
    %save this x value and replace 1: (xVal - 3) with 0 to keep shape but
    %remove the spine
    
    newNeur = neur;
    %experiment with this number, perhaps some sort of height proportion?
    newNeur(1:(xLocation - 5),:,:) = 0;
end