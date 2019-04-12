%3D measurement code for NeurSpaceAShape

    %local thickness
    RunMiji(); %DEVNOTE:remove this when incorporated into FishCuT
    MIJ.createImage('Vertebrae',uint16(filtnegspace*2^16),true);
    MIJ.run('8-bit');
    MIJ.run('Local Thickness (complete process)','threshold=1');
    negThicknessIm = MIJ.getCurrentImage;
    MIJ.run('Close All');
    NeuralSpaceMTs(n) = mean(nonzeros(negThicknessIm));
    NeuralSpaceTSs(n) = std(nonzeros(negThicknessIm));
    
    %volume
    NeuralSpaceVolumes(n) = nnz(filtnegspace);
    
    %surface area
    NeuralSpaceSAs(n) = nnz(bwperim(filtnegspace, 26));