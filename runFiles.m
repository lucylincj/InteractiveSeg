function runFiles(listName)

    lambda = [1 50 100 150 200 250 300 400 500 600];
    %lambda = [500 600 700 800 900];
    %lambda = [100 300 500 700 900 1000 2000 3000 4000 5000 6000];
    param = [2, 5;
             3, 5;
             4, 5];

    % read from list
%     targetPath = 'D:/InteractiveSegTestImage/GrabcutDatabase';
%     file = fopen([targetPath,listName]);
%     C = textscan(file,'%s');
%     fileName = C{1};
%     N = length(fileName);
%     for i = 1:N
%         disp(fileName{i});
%         for k = 1:size(lambda, 2)
%             main('ver0', fileName{i}, lambda(k));
%             main('ver4', fileName{i}, lambda(k));
%             main('ver3', fileName{i}, lambda(k));
%             for j = 1:size(param, 1)
%                 main('ver1', fileName{i}, [param(j, 1), param(j, 2), lambda(k)]);
%                 main('ver2', fileName{i}, [param(j, 1), param(j, 2), lambda(k)]);
%             end
%         end
%         disp([fileName{i}, ' ', 'OK!']);
%     end
    
    % read entire folder
    imgPath = 'D:/InteractiveSegTestImage/GrabcutDatabase/data_GT/'
    fileList = {dir(strcat(imgPath,'*.jpg')), dir(strcat(imgPath,'*.bmp'))};
    for j = 1:2
        list = fileList{j};
        N = size(list, 1);
        for i = 1:N
            %img_path = strcat(imgPath,fileList(i).name);
            [dum, name, type] = fileparts(list(i).name);
             disp(name);
            for k = 1:size(lambda, 2)
                mainGC('ver0', name, lambda(k), type);
                mainGC('ver4', name, lambda(k), type);
                mainGC('ver3', name, lambda(k), type);
                for p = 1:size(param, 1)
                    mainGC('ver1', name, [param(p, 1), param(p, 2), lambda(k)], type);
                    mainGC('ver2', name, [param(p, 1), param(p, 2), lambda(k)], type);
                end
            end
            disp([name, ' ', 'OK!']);
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