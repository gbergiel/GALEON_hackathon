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
% figure
% imshow(annotatedImage)

inputSize = size(annotatedImage);
className = "BoundingBox";
rng("default")
trainingDataForEstimation = transform(trainingData,@(data)preprocessData(data,inputSize));
numAnchors = 9;
[anchors,meanIoU] = estimateAnchorBoxes(trainingDataForEstimation,numAnchors);
area = anchors(:, 1).*anchors(:,2);
[~,idx] = sort(area,"descend");

anchors = anchors(idx,:);
anchorBoxes = {anchors(1:3,:)
    anchors(4:6,:)
    anchors(7:9,:)
    };
detector = yolov4ObjectDetector("csp-darknet53-coco",className,anchorBoxes,InputSize=inputSize);

options = trainingOptions("adam",...
    GradientDecayFactor=0.9,...
    SquaredGradientDecayFactor=0.999,...
    InitialLearnRate=0.001,...
    LearnRateSchedule="none",...
    MiniBatchSize=4,...
    L2Regularization=0.0005,...
    MaxEpochs=70,...
    BatchNormalizationStatistics="moving",...
    DispatchInBackground=true,...
    ResetInputNormalization=false,...
    Shuffle="every-epoch",...
    VerboseFrequency=20,...
    ValidationFrequency=1000,...
    CheckpointPath=tempdir,...
    ValidationData=validationData);
doTraining = true;
if doTraining       
    % Train the YOLO v4 detector.
    [detector,info] = trainYOLOv4ObjectDetector(trainingData,detector,options);
else
    % Load pretrained detector for the example.
    detector = downloadPretrainedYOLOv4Detector();
end
I = imread("Task-2/Training Dataset/WBA7F21070B235942_20230406_110938_0104_27723.png");
[bboxes,scores,labels] = detect(detector,I);
I = insertObjectAnnotation(I,"rectangle",bboxes,scores);
figure
imshow(I)

function data = preprocessData(data,targetSize)
% Resize image and bounding boxes to the targetSize.
    scale = targetSize(1:2)./size(data{1},[1 2]);
    data{1} = imresize(data{1},targetSize(1:2));
    boxEstimate=round(data{2});
    boxEstimate(:,1)=max(boxEstimate(:,1),1);
    boxEstimate(:,2)=max(boxEstimate(:,2),1);
    data{2} = bboxresize(boxEstimate,scale);
end