function RotateNeurEulTest(neuralImage)
% constructs connected components object and 
    neur = logical(neuralImage);
    close all;
    neurCC = bwconncomp(neur);
    pix = neurCC.PixelIdxList;
    catpix = [];
    for i = 1:size(pix,2)
       catpix = [catpix ; pix{i}];  
    end
    neurCC.PixelIdxList{1} = catpix;
    neurCC.PixelIdxList = {neurCC.PixelIdxList{1}};
    neurCC.NumObjects = 1;
    
    %TESTING AND DEV - Replaces everything after the next line
    rotatedneur = RotateNeur_Eul(neur, neurCC);
end