close all;
clear
addpath('functions','images','results');
filename={'barbara256.bmp','baboon256.bmp','lena512.bmp','cameraman512.bmp','couple256.bmp',...
    'pepper512.bmp','street512.bmp','walkbridge512.bmp','lake512.bmp','jetplane512.bmp'};

row1=[];
row2=[];
for i=1:numel(filename)
    img_gray = imread(['images/',filename{i}]);
    if size(img_gray,1)==256
        img_gray=imresize(img_gray,2);
    end
    if i<6
        row1=[row1,img_gray];
    else
        row2=[row2,img_gray];
    end
end
images=[row1;row2];
figure;
imshow(images);
print('-f1','images','-djpeg');