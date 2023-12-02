
filename='WBA7F21070B235942_20230406_110938_1413_27451.png';

[status,cmdout]=system(append('base64 ', filename, ' | curl -d @- https://detect.roboflow.com/hackathon-r20aq/1?api_key=Ypm944XyRsYlNKBKmcoU'));
predictions=regexp(cmdout, 'predictions":(.*?)}','match');
x=regexp(predictions{1}, 'x":(.*?),','match');
x=x{1};
x=int32(str2num(x(4:end-1)));
y=regexp(predictions{1}, 'y":(.*?),','match');
y=y{1};
y=int32(str2num(y(4:end-1)));
width=regexp(predictions{1}, 'width":(.*?),','match');
width=width{1};
width=int32(str2num(width(8:end-1)));
height=regexp(predictions{1}, 'height":(.*?),','match');
height=height{1};
height=int32(str2num(height(9:end-1)));

[x, y, width, height]