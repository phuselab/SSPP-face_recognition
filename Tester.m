classdef Tester < handle
    %TESTER launch tests on images
    
    properties (SetAccess = protected)
        fds             % face dataset
        ratio_TOT       % total rec. rate
        type            % val or test                              
    end
    
    methods
        % generate a Tester object
        function tsr = Tester(fds, type)
            if ~isa(fds,'FaceDataset')
                error('Object ''fds'' is not a ''FaceDataset'' type!')
            end
            if ~ismember(type, {'val','test'})
                error('type, must be "val" or "test"');
            end
            tsr.fds = fds;
            tsr.type = type;
        end
        
        function classify_LFW_MF_TestAugmented(tsr)
            
            if strcmp(tsr.type, 'test')
                N = tsr.fds.num_test;         % num of test images
            else
                N = tsr.fds.num_val;
            end

            tsr.ratio_TOT = 0;
            
            ID_FOUND = cell(1,N);
            
            % main classification cycle
            
            TSR = tsr.fds; 
            if strcmp(tsr.type,'val')
                TSR.test_ID = TSR.val_ID;
                TSR.test_db = TSR.val_db;
            end
           
            for i = 1:N
                cla = Classifier(TSR.gallery);
                nAugmentedTest = size(TSR.test_db,2);
                I_test = cell(1,nAugmentedTest);
                ID_test = TSR.test_ID(i);
                for j = 1:nAugmentedTest
                    I_test{j} = TSR.test_db{j}(:,i);
                end
                gallery = TSR.gallery;
                
                if gallery.normalize
                    for j = 1:nAugmentedTest
                        I_test_Norm{j} = I_test{j}/norm(I_test{j});
                    end
                end
                
                % Klimaps Classification
                ID = cla.klimaps_classify_MultiTest(I_test, TSR.TestAugSplit);
                
                ID_FOUND{i} = [ID; 1];
                fprintf('\n Example %d   --->   FOUND = %d  --  TRUE = %d\n',i ,ID, ID_test)
                if ID ~= ID_test
                    fprintf('\n ERROR!!! \n');
                end                               
            end
            
            ID_FOUND = cell2mat(ID_FOUND);
            tsr.ratios(ID_FOUND);
        end
        
        % disp object
        function disp(tsr)
            if strcmp(tsr.type,'test')
                N = tsr.fds.num_test;         % num of test images
            else
                N = tsr.fds.num_val;
            end
            fprintf('\n  ***  REPORT on experiments  ***\n');
            fprintf('  Num of tested images : %d\n',N);
            fprintf('             Ratio TOT : %.2f\n',100*tsr.ratio_TOT);            
        end
    end
    
    methods (Access = private)      
        % compute ratios
        function ratios(tsr,ID_FOUND)
            if strcmp(tsr.type,'test')
                N = tsr.fds.num_test;         % num of test images
            else
                N = tsr.fds.num_val;
            end
            for i = 1:N
                if  ID_FOUND(1,i) == tsr.fds.test_ID(i)     % ID found is OK!
                    tsr.ratio_TOT = tsr.ratio_TOT+1;
                end
            end
            tsr.ratio_TOT = tsr.ratio_TOT/N;
        end
    end
    
end