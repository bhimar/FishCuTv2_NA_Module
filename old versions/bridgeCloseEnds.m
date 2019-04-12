function [imageout] = bridgeCloseEnds(imagein,distance)
%bridges nearby endpoints in a binary image (closing algorithm)
%@param dist = threshold for distance between endpoints for closing
    imageout = imagein;
    skel = bwmorph(imagein,'skel',Inf);
    ends = bwmorph(skel,'endpoints');
    [endRow endCol] = find(ends);
    ends = cat(2,endRow,endCol);
    [endLength ,~] = size(ends); 
    for(l = 1:endLength)
        for(k = (1+l):endLength)
            if pdist([ends(l,:);ends(k,:)]) < distance
              closed = imshow(imageout);
              closeLine = imline(gca,[ends(l,2),ends(k,2)],[ends(l,1),ends(k,1)]);
              closeLine = closeLine.createMask();
              imageout(closeLine) = 1;
            end
        end
    end
    close all;
end