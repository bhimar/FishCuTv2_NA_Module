function imdisp(montage)
    %montage must be a cell array
    for j = 1:size(montage,2)
        subplot(ceil(sqrt(size(montage,2))),ceil(sqrt(size(montage,2))),j);
        imshow(montage{j});
    end
end