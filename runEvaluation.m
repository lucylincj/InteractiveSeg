function runEvaluation(listName)
    targetPath = 'D:/InteractiveSegTestImage/';
    file = fopen([targetPath,listName]);
    C = textscan(file,'%s');
    fileName = C{1};
    N = length(fileName);
    path = 'D:/InteractiveSegTestImage/';
    P = [];
    R = [];
   
    for i = 1:N
        [pr] = evaluate([path, 'result/SLICO/300/', fileName{i}, '/'], [path, 'groundTruth/'],fileName{i});
        P = [P, pr(:,1)];
        R = [R, pr(:,2)];
        disp([fileName{i}, ' ', 'OK!']);
    end
end