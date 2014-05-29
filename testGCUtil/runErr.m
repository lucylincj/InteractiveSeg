function Err = runErr()
    testImage = 'memorial';
    imgPath = 'D:/InteractiveSegTestImage/GrabcutDatabase/result/ERS/200/';
    trimapPath = 'D:/InteractiveSegTestImage/GrabcutDatabase/boundary_GT_lasso/';
    gtPath = 'D:/InteractiveSegTestImage/GrabcutDatabase/boundary_GT/';
    fileList = dir(strcat(imgPath,testImage,'/map*'));
    
    trimap = imread([trimapPath, testImage, '.bmp']);
    groundTruth = imread([gtPath, testImage, '.bmp']);
    N = size(fileList, 1);
    Err = zeros(N,1);
    for i = 1:N
        img_path = strcat(imgPath,testImage,'/',fileList(i).name);
        [dum, name, type] = fileparts(fileList(i).name);
        result = imread(img_path);
        Err(i) = computeErr(result, trimap, groundTruth);
        disp([name, ' ', 'OK!']);
    end

end