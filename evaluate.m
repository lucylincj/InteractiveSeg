function evaluate(imgPath, gtPath, imgName)
% evaluate('D:/InteractiveSegTestImage/result/SLICO/300/0_5_5887/', 'D:/InteractiveSegTestImage/groundTruth/','0_5_5887')
    fileList = dir(strcat(imgPath,'map*'));
    N = size(fileList, 1);
    prTable = zeros(2, N);
    nameCell = cell(1, N);
    for i = 1:N
        img_path = strcat(imgPath,fileList(i).name);
        [dum, name, type] = fileparts(fileList(i).name);

        map = imread(img_path);
        gt = imread([gtPath, imgName, '.bmp']);
        [prTable(i, 1), prTable(i, 2)] = computePR(map, gt(:,:,1));
        nameCell{i} = name;
    end
    figure;
    subplot(1, 2, 1); bar(prTable(:, 1), 'grouped', N);
    subplot(1, 2, 2); bar(prTable(:, 2));
    %set(gca, 'xticklabel', nameCell);
end