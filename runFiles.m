function runFiles(listName)
    targetPath = 'D:/InteractiveSegTestImage/';
    file = fopen([targetPath,listName]);
    C = textscan(file,'%s');
    fileName = C{1};
    N = length(fileName);
    lambda = [1 50 100 150 200 250 300 400];
    %lambda = [500 750];
    param = [2, 5;
             3, 5;
             4, 5];
%     for i = 1:N
%         runERS(fileName{i}, 300);
%     end
% 
    for i = 1:N
        for j = 1:size(param, 1)
            for k = 1:size(lambda, 2)
                main(fileName{i}, 'ver1', [param(j, 1), param(j, 2), lambda(k)]);
                %imsave([tarPath,name,'.jpg']);
                disp([fileName{i}, ' ', 'OK!']);
            end
        end
    end
    
%     for i = 1:N
%         for k = 1:size(lambda, 2)
%             main(fileName{i}, lambda(k));
%             %imsave([tarPath,name,'.jpg']);
%             disp([fileName{i}, ' ', 'OK!']);
%         end
%     end
    
end