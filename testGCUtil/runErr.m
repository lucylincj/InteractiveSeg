function Err = runErr()
    %testImage = 'memorial';
    %imgPath = 'D:/InteractiveSegTestImage/GrabcutDatabase/result/ERS/200/ver0/';
    trimapPath = 'D:/InteractiveSegTestImage/GrabcutDatabase/boundary_GT_lasso/';
    gtPath = 'D:/InteractiveSegTestImage/GrabcutDatabase/boundary_GT/';
    targetFolder = 'D:/InteractiveSegTestImage/GrabcutDatabase/result/ERS/200/ver0/';
    
    %fileList = dir(strcat(imgPath,testImage,'/map*'));
    fileList = dir(strcat(targetFolder,'/map*'));
%     trimap = imread([trimapPath, testImage, '.bmp']);
%     groundTruth = imread([gtPath, testImage, '.bmp']);

    N = size(fileList, 1);
    Err = zeros(N,1);
    for i = 1:N
        [dum, name, type] = fileparts(fileList(i).name);
         [C, r] = strtok(name, '_');
         testImage = strtok(r, '_');
        trimap = imread([trimapPath, testImage, '.bmp']);
        groundTruth = imread([gtPath, testImage, '.bmp']);
        img_path = strcat(targetFolder,fileList(i).name);
        result = imread(img_path);
        Err(i) = computeErr(result, trimap, groundTruth);
        disp([name, ' ', 'OK!']);
    end

end