function best = runEvaluation(listName)
    targetPath = 'D:/InteractiveSegTestImage/';
    file = fopen([targetPath,listName]);
    C = textscan(file,'%s');
    fileName = C{1};
    N = length(fileName);
    path = 'D:/InteractiveSegTestImage/';
    P = [];
    R = [];
    best = zeros(2, N);
   
    for i = 1:N
        [pr name] = evaluate([path, 'test/ERS/300/', fileName{i}, '/'], [path, 'groundTruth/'],fileName{i});
        ave = (pr(:,1) + pr(:,2))/2;
        [best(2,i) best(1,i)] = max(ave);
        P = [P, pr(:,1)];
        R = [R, pr(:,2)];
        
        disp([fileName{i}, ' ', 'OK!']);
    end
end