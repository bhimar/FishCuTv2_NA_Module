%Client for NeurSpaceAShape.m function

%load previous segmentation
filePath = ['Z:\Rehaan Bhimani\FishCuTv2 Project\FishCuTv2 Modules\Test Data\bmp1a crispants\msbl 95.AB bmp1a 07 Analysis Files\'];
load([filePath 'ReconstructedSegmentation']);
NaMajAx = [];
NaMinAx = [];
NaArea = [];
NaEffArea = [];
Rows = {};
for n = 1:21
    Rows{n} = ['Vertebrae' num2str(n)];
    neuralImage = NeuralArchImages{n};
    [NaMajAx,NaMinAx,NaArea,NaEffArea] = NeurSpaceAShape(n,neuralImage,NaMajAx,NaMinAx,NaArea,NaEffArea);
end

%write to file for r^2 comparison evaluation

% filePath2 = 'Z:\Rehaan Bhimani\FishCuTv2 Project\FishCuTv2 Modules\Test Data\';
% fishSample = 'bmp1aGermlineNAs.xlsx';
% table = xlsread([filePath2 fishSample]);
% table(:,size(table,2)+1) = NaMajAx;
% xlswrite([filePath2 fishSample], Stable);

%write to file for global test evaluation
%T = table(Rows', NaMajAx', NaMinAx', NaArea', NaEffArea','VariableNames',{'Row','NaMajAx','NaMinAx','NaArea','NaEffArea'});
%writetable(T, [filePath 'NaData.txt'], 'Delimiter', '\t');

