function disp3D(image3d)
    negs = image3d;
    negs(image3d > 0) = 0;
    pos = image3d;
    pos(image3d < 0) = 0;
    [x y z] = ind2sub(size(pos), find(pos));
    scatter3(z,y,x,'r.')
    hold on
    [x y z] = ind2sub(size(negs), find(negs));
    scatter3(z,y,x,'b.')
    h = gca;
    set(h,'ZDir','reverse');
    set(h,'YDir','reverse');
    hold off
end