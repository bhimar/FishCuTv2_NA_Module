%qualitative testing function for euler angles

%Client for RotateNeurEulTest.m function

%load previous segmentation
filePath = 'Z:\Rehaan Bhimani\FishCuTv2 Project\FishCuTv2 Modules\Test Data\bmp1a germline mutants\germ1\02-Jun-2016\';
load([filePath 'ReconstructedSegmentation']);
for n = 1:21
    neuralImage = NeuralArchImages{n};
    RotateNeurEulTest(neuralImage);
end
