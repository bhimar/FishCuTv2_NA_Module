%Client for NeurSpaceAShape.m function

%load previous segmentation
filePath = 'Z:\Rehaan Bhimani\FishCuTv2 Project\FishCuTv2 Modules\Test Data\crispant shams\msbl 95.AB sham 15 Analysis Files\';
load([filePath 'ReconstructedSegmentation']);
NaMajAx = [];
NaMinAx = [];
NaArea = [];
NaEffArea = [];
for n = 1:21
    neuralImage = NeuralArchImages{n};
    [NaMajAx,NaMinAx,NaArea,NaEffArea] = NeurSpaceAShape(n,neuralImage,NaMajAx,NaMinAx,NaArea,NaEffArea);
end

%write to file for R^2 eval

% filePath2 = 'Z:\Rehaan Bhimani\FishCuTv2 Project\FishCuTv2 Modules\Test Data\ARCHIVE\rotation with eulerangles eval\';
% fishSample = 'shamNAs.xlsx';
% table = xlsread([filePath2 fishSample]);
% table(:,size(table,2)+1) = NaMajAx;
% xlswrite([filePath2 fishSample], table);


