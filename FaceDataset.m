classdef FaceDataset < handle
    %FaceDataset Loads features from file and creates the train and test
    %sets
    
    properties %(SetAccess = protected)
        info          % face dataset info (FaceDatasetInfo type)
        gallery       % gallery of training images (Gallery type)
        galleryStacked %gallery with stacked feats on a subset of IDs
        num_test      % number of test images
        num_val
        test_db       % test dataset of features
        val_db
        test_ID       % test IDs of features      
        val_ID
        K = 1         % num training images x subject
        num_feats     % overall num. of features
        stack         % flag indicating whether to stack or not the features
        idx_train_test
        idxABS
        TestAugSplit
        testStacked
        testIDstacked
    end
    
    methods
        % load a face dataset
        function fds = FaceDataset(name, SERVER)
            fds.info = FaceDatasetInfo(name, SERVER);
        end
        
        function set.gallery(fds,gallery)
            fds.gallery = gallery;
        end
        % set the num of training images x subject
        function set.K(fds,K)
            fds.K = K;
        end
        
        % load features from files and create train & test set. If seed
        % is set it is used to set the seed of random gen
        function create_train_test_sets_SingleImg(fds,seed, DictSplit, TestAugSplit, LDAon)
            if nargin >= 2
               rng(seed) 
            end
            feat_filename = fds.set_filenames();
            if nargin<3
                DictSplit = ones(1,size(feat_filename,1));
            end
            if nargin<4
                TestAugSplit = zeros(1,size(feat_filename,1));
                TestAugSplit(round(end/2))=1;
            end
            
            nDicts = max(DictSplit); %n. of distinct dictionaries to be referred
            if size(TestAugSplit,1) >1
            SwitchOnTestFeat = max(TestAugSplit);
            else
                SwitchOnTestFeat = TestAugSplit;
            end
            nTestAugmented = sum(SwitchOnTestFeat); %n. of augmeted view for each test image
            fds.TestAugSplit = TestAugSplit;
            
            train_LDA = cell(1,nDicts);   % train feature struct 
            fds.test_db = cell(1,nTestAugmented);   % test feature struct
            fds.val_db = cell(1,nTestAugmented);
            train_ID = [];
            nFeats = 0;
            nTest = 0;
            for fname = feat_filename
                load(fname{1})
                nFeats = nFeats+1;
                if strcmp(fname{1},'RAW')
                    I{nFeats} = imgdb; 
                else
                    I{nFeats} = imgdb_feat; 
                end 
                if nFeats == 1          % define train and tests set IDs
                    idx = fds.define_IDs(I{1}.class_ID);
                    fds.idxABS =idx;
                    fds.test_ID = I{1}.class_ID(idx.test);
                    fds.val_ID = I{1}.class_ID(idx.val);
                    fds.num_test = length(fds.test_ID);
                    fds.num_val = length(fds.val_ID);
                end
                %Dict data organization, according to DictSplit
                train_LDA{DictSplit(nFeats)} = [train_LDA{DictSplit(nFeats)}, I{nFeats}.images(:,idx.train)];
                if DictSplit(nFeats)==1
                    train_ID = [train_ID, I{nFeats}.class_ID(idx.train)];
                end
                
                if SwitchOnTestFeat(nFeats)
                    nTest = nTest +1;
                    %test data organization according to TestAugmented
                    fds.test_db{nTest} = I{nFeats}.images(:,idx.test);
                    fds.val_db{nTest} = I{nFeats}.images(:,idx.val);
                end
            end
            fds.gallery = Gallery(train_ID,train_LDA, 1, LDAon);
            fds.idx_train_test = idx;
        end
                
        % disp object
        function disp(fds)
            fprintf('  ***  REPORT on face dataset  ***\n');
            fprintf('                 Dataset name : %s\n',fds.info.name);
            fprintf('           Number of subjects : %d\n',fds.info.num_sbj);
            fprintf('           Number of features : %d\n',fds.num_feats);
            fprintf('          Num training images : %d\n',fds.gallery.num_train);
            fprintf('        Num Validation images : %d\n',fds.num_val);
            fprintf('              Num test images : %d\n',fds.num_test);
            fprintf(' Num training img per subject : %d\n',fds.K);            
        end
    end
    
    methods (Access = private)
        
        % check and set filenames of illuminations x features
        function filename = set_filenames(fds)
            h = fds.info;
            num_file = numel(h.feat_name)*numel(h.illu_name);
            filename = cell(1,num_file);
            n = 0;
            warn = '';
            for j = 1:numel(h.illu_name)
                for i = 1:numel(h.feat_name)
                    p = [h.path{1} h.db_name '/' h.filename '_' h.illu_name{j} '_' h.feat_name{i} '.mat'];
                    if exist(p,'file')
                        n = n+1;
                        filename{n} = p;
                    else
                        warn = strcat(warn,[p ',']);
                    end
                end
            end
            if num_file ~= n
                warning('Warning: features %s not found!',warn);
                filename = filename(~cellfun('isempty',filename)); % remove empty cells
            end
            fds.num_feats = n;
        end
        
        % define the train and test indeces for db selection
        function idx = define_IDs(fds,IDs)
            IDu = unique(IDs);
            num_sbj = length(IDu);
            idx.test = [];
            idx.val = [];
            idx.train = [];
            IDrand = randperm(size(IDu,2));
            s = 0;
            sb = 0; 
            validation_num = 0;      % Number of examples for validation
            while sb < fds.info.num_sbj & s < size(IDrand,2)
                s = s+1;
                nc = sum(IDs == IDu(IDrand(s)));
                 
                if nc>=2    % at least 2 images
                    sb = sb+1;
                    s_idx = find(IDs == IDu(IDrand(s)));
                    rd = randperm(nc);
                    T = sort(s_idx(rd(1:fds.K)));
                    idx.train = [idx.train T];               % select K imgs of sbj s
                    V = sort(s_idx(rd(fds.K+1:fds.K + validation_num)));
                    idx.val = [idx.val V];
                    idx.test = [idx.test setdiff(setdiff(s_idx,T),V)];  % take the remaining imgs of sbj s
                end
            end
            
            s=0;
            while length(idx.train) < fds.info.num_sbj %GUARANTEE THAT AT LEAST THE TRAIN RESPECT THE CARDINALITY!
                s = s+1;
                nc = sum(IDs == IDu(IDrand(s)));
                if nc==1
                    sb = sb+1;
                    s_idx = find(IDs == IDu(IDrand(s)));
                    idx.train = [idx.train s_idx];               % select K imgs of sbj s
                end
            end
        end
        
    end
    
end

