%load testing data first!

NeuralFMinA = [];
NeuralFMajA = [];
NeuralForamenImages = {};


for n = 1:21
   subImg = allsubImg{n};
   uppercentrumx1 = alluppercentrumx1(n);
   lowercentrumx1 = alllowercentrumx1(n);
   [NeuralFMinA,NeuralFMajA,NeuralForamenImages]...
   = NeuralForamenMeasurement(subImg,uppercentrumx1,lowercentrumx1...
                              ,n,NeuralFMinA,...
                              NeuralFMajA,NeuralForamenImages);

end