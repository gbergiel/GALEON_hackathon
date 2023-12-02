
foldername='Training Dataset';
directory=dir(foldername);
a=struct2cell(directory);
a=a(1,:)';
saveToFile.Image=a;
bbs=[];
for i = 1:size(a)
    t=a(i);
    t2=append(foldername, '/', t{1});
    tmp=getBB(t2);
    if size(tmp)~=0
        bbs(i,:)=tmp;
    else
        bbs(i, :)=[0 0 0 0];
    end
end
saveToFile.BoundingBox=bbs;
save('Task_2_Galeon.mat', "saveToFile");

function result = getBB(filename)
    result=[];
    try
        body = matlab.net.http.MessageBody(base64file(filename));
        contentTypeField = matlab.net.http.field.ContentTypeField('application/x-www-form-urlencoded');
        type1 = matlab.net.http.MediaType('text/*');
        type2 = matlab.net.http.MediaType('application/json','q','.5');
        acceptField = matlab.net.http.field.AcceptField([type1 type2]);
        header = [acceptField contentTypeField];
        method = matlab.net.http.RequestMethod.POST;
        request = matlab.net.http.RequestMessage(method,header,body);
        uri = matlab.net.URI('https://detect.roboflow.com/hackathon-r20aq/2?api_key=Ypm944XyRsYlNKBKmcoU');
        resp = send(request,uri);
        preds = resp.Body.Data.predictions;
        result=[preds.x preds.y preds.width preds.height];
    catch exception
        exception;
    end
end
