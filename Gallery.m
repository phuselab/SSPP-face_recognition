classdef Gallery < handle
    %Gallery Holds the training image gallery
    
    properties (SetAccess = protected)
        sbj_ID              % subject unique IDs (array of M subjects)
        num_train           % number of training images
        train_ori           % original training features
        train_db            % normalized training features
        train_LDA           % dictionary: training feature dataset (cell(1,N) of matrices)
        WLDA                % LDA projectors
        train_LDA_inv       % pseudo-inverse dictionary (cell(1,N) of matrices)
        train_LDA_sbj       % training feature dataset split per sbj (cell(N,M) of matrices)
        train_LDA_sbj_inv   % training feature dataset split per sbj (inverse)
        train_ID            % subject IDs of training dataset
        mu                  % means of training images
        sigma               % stds of training images
        normalize = true    % normalization flag
        db_size             % size of training db (num_feats di num_feats)
    end
    
    methods
        % contruct a face Gallery object with the normalization trigger
        function gal = Gallery(train_ID,train_db,normalize, LDAon)
            gal.train_ori = train_db;
            % normalization
            if nargin == 3
                gal.normalize = normalize;
            end
            gal.train_ID = train_ID;
            gal.sbj_ID = unique(train_ID);
            gal.num_train = length(train_ID);
            gal.train_db = train_db;
            gal.db_size = numel(train_db);
            if gal.normalize
                gal.L2norm(); 
            end
            gal.train_LDA = cell(1,gal.db_size);
            for i = 1:gal.db_size
                [W,P] = gal.Fisher_LDA(train_db{i}, LDAon);
                gal.train_LDA{i} = P;
                gal.WLDA{i} = W;
            end
            gal.train_LDA_inv = cell(1,gal.db_size);
            
            % LDA feature pseudo-inverse creation
            for i = 1:gal.db_size
                gal.train_LDA_inv{i} = pinv(gal.train_LDA{i});
            end
            
            % split the gallery on submatrices, one for each sbj
            M = length(gal.sbj_ID);
            gal.train_LDA_sbj = cell(gal.db_size,M);
            gal.train_LDA_sbj_inv = cell(gal.db_size,M);
            for j = 1:M
                idx = ismember(gal.train_ID,gal.sbj_ID(j));
                for i = 1:gal.db_size
                    gal.train_LDA_sbj{i,j} = gal.train_LDA{i}(:,idx);
                    gal.train_LDA_sbj_inv{i,j} = pinv(gal.train_LDA{i}(:,idx));
                end
            end
        end
                
        % select a sub-gallery
        function new_gal = sub_gallery(gal,new_ID)
            N = gal.db_size;
            M = length(new_ID);
            new_train_db = cell(1,N);
            new_train_ID = [];
            for j = 1:M
                idx = ismember(gal.train_ID,new_ID(j));
                new_train_ID = [new_train_ID gal.train_ID(idx)];
                for i = 1:N
                    new_train_db{i} = [new_train_db{i} gal.train_ori{i}(:,idx)];
                end
            end
            new_gal = Gallery(new_train_ID,new_train_db);
        end
        
        % normalization by zscore
        function normalization(gal)
            gal.mu = cell(1,gal.db_size);
            gal.sigma = cell(1,gal.db_size);
            for i = 1:gal.db_size
                [gal.train_db{i},m,s] = zscore(gal.train_db{i},0,2);
                gal.mu{i} = m;
                gal.sigma{i} = s;
            end
        end
         
        
        % normalization by zero centering
        function normMean(gal)
            gal.mu = cell(1,gal.db_size);
            gal.sigma = cell(1,gal.db_size);
            for i = 1:gal.db_size
                m = mean(gal.train_db{i},2);
                gal.train_db{i} = gal.train_db{i} - repmat(m, 1, size( gal.train_db{i},2));
                gal.mu{i} = m;
            end
        end
        
        
        % normalization by zero centering
        function L2norm(gal)
            for i = 1:gal.db_size
                gal.train_db{i} = gal.train_db{i} / norm(gal.train_db{i});
             end
        end
        
        
        % do the LDA analysis on dataset db
        function [W,P] = Fisher_LDA(gal,X, LDAon)
            c = gal.sbj_ID;
            % PCA
            MU = mean(X,2);
            Xw = X - repmat(MU, 1, gal.num_train);  % center data
            [E,D,~] = svd(Xw,'econ');  %svds(Xw,rank(Xw));
            d = cumsum(diag(D))/sum(diag(D));
            num_PCA_features = find(d>.95,1);
            if num_PCA_features < length(c)
                num_PCA_features = length(d)-1;
            end
            Wpca = E(:,1:num_PCA_features);
            if LDAon
                Y = Wpca'*Xw;
                % LDA
                dim = size(Y,1);
                muY = mean(Y,2);
                Sw = zeros(dim);
                Sb = zeros(dim);
                for i = 1:length(c)
                    Yi = Y(:,gal.train_ID==c(i));
                    muYi = mean(Yi,2);
                    Yi = Yi - repmat(muYi,1,size(Yi,2));    % center data
                    Sw = Sw + Yi*Yi';
                    Sb = Sb + size(Yi,2)*(muYi-muY)*(muYi-muY)';
                end
                [V,D] = eig(Sb,Sw);    % solve the eigenvalue problem
                [~,idx] = sort(diag(D), 1, 'descend');
                V = V(:,idx);
                Wlda = V(:,1:length(c)-1);
                % PCA + LDA
                W = Wpca * Wlda;         % projection matrix
            else
                W = Wpca;
            end
                P = W'*X;               % training images projection
            
        end
    end
    
    methods (Access = private)
        
    end
    
end

