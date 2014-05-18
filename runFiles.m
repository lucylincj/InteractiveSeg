function runFiles(listName)
    targetPath = 'D:/InteractiveSegTestImage/';
    file = fopen([targetPath,listName]);
    C = textscan(file,'%s');
    fileName = C{1};
    N = length(fileName);
    for i = 1:N
        main(fileName{i});
        %imsave([tarPath,name,'.jpg']);
        disp([fileName{i}, ' ', 'OK!']);
    end
end