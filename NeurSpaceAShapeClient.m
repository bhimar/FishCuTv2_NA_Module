%Client for NeurSpaceAShape.m function

%load previous segmentation
filePath = 'Z:\Rehaan Bhimani\FishCuTv2 Project\FishCuTv2 Modules\Test Data\bmp1a crispants\msbl 95.AB bmp1a 01 Analysis Files\';
load([filePath 'ReconstructedSegmentation']);
NaMajAx = [];
NaMinAx = [];
NaArea = [];
NaEffArea = [];
for n = 1:21
    neuralImage = NeuralArchImages{n};
    [NaMajAx,NaMinAx,NaArea,NaEffArea] = NeurSpaceAShape(n,neuralImage,NaMajAx,NaMinAx,NaArea,NaEffArea);
end

%write to file

% filePath2 = 'Z:\Rehaan Bhimani\FishCuTv2 Project\FishCuTv2 Modules\Test Data\';
% fishSample = 'shamGermlineNAs.xlsx';
% table = xlsread([filePath2 fishSample]);
% table(:,size(table,2)+1) = NaMajAx;
% xlswrite([filePath2 fishSample], table);
% 
