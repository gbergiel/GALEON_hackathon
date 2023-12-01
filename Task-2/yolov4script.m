trainingData = load('Task-2/Training Dataset/Task_2_Training_Dataset.mat').Task_2_Training_Data;
% Add the fullpath to the local vehicle data folder.
trainingDataTable = struct2table(trainingData);
trainingDataTable.Image = fullfile(pwd,'Task-2', 'Training Dataset', trainingDataTable.Image);

newBBs = {};
for i = 1 : height(trainingDataTable)
    newBBs(i,1)={trainingDataTable.BoundingBox(i, :)};
end
trainingDataTable.BoundingBox=newBBs;

% Create training dataset
rng("default");
shuffledIndices = randperm(height(trainingDataTable));
idx = floor(0.6 * length(shuffledIndices) );

trainingIdx = 1:idx;
trainingDataTbl = trainingDataTable(shuffledIndices(trainingIdx),:);

validationIdx = idx+1 : idx + 1 + floor(0.1 * length(shuffledIndices) );
validationDataTbl = trainingDataTable(shuffledIndices(validationIdx),:);

testIdx = validationIdx(end)+1 : length(shuffledIndices);
testDataTbl = trainingDataTable(shuffledIndices(testIdx),:);

imdsTrain = imageDatastore(trainingDataTbl{:,"Image"});
bldsTrain = boxLabelDatastore(trainingDataTbl(:,"BoundingBox"));

imdsValidation = imageDatastore(validationDataTbl{:,"Image"});
bldsValidation = boxLabelDatastore(validationDataTbl(:,"BoundingBox"));

imdsTest = imageDatastore(testDataTbl{:,"Image"});
bldsTest = boxLabelDatastore(testDataTbl(:,"BoundingBox"));
trainingData = combine(imdsTrain,bldsTrain);
validationData = combine(imdsValidation,bldsValidation);
testData = combine(imdsTest,bldsTest);

% validateInputData(trainingData);
% validateInputData(validationData);
% validateInputData(testData);
data = read(trainingData);
I = data{1};
bbox = data{2};
annotatedImage = insertShape(I,"Rectangle",bbox);
annotatedImage = imresize(annotatedImage,2);
figure
imshow(annotatedImage)