%old rotation algorithm (doesn't work that great)

    props = regionprops3(neurCC,'Orientation');
    props = props.Orientation;
    props = props(1,:);
    %apply rotations in given order - not commutative
    roll = props(1); 
    pitch = props(2); 
    yaw = props(3);
    
    %roll rotation
    rotatedneur = imrotate(neur,-1 * roll);
        
    %pitch rotation
    %permutation reference https://stackoverflow.com/questions/21100168/how-does-the-permute-function-in-matlab-work
    pitchperm = permute(rotatedneur,[1 3 2]);
    rotatedpitch = imrotate(pitchperm,90 - pitch);
    rotatedneur = ipermute(rotatedpitch,[1 3 2]);
        
    %yaw rotation
    yawperm = permute(rotatedneur, [3 2 1]);
    rotatedyaw = imrotate(yawperm, yaw);
    rotatedneur = ipermute(rotatedyaw,[3 2 1]);
