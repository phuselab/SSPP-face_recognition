classdef Classifier < handle
    %Classifier Face classifier based on the k-LiMaPs algorithm
    
    properties (SetAccess = protected)
        gallery         % image dataset
        residue          
    end
    
    methods
        % construct a Classifier object
        function cla = Classifier(gallery)
            if ~isa(gallery,'Gallery')
                error('Object ''gallery'' is not a ''Gallery'' type!')
            end
            cla.gallery = gallery;
        end      
       
       function ID = klimaps_classify_MultiTest(cla,I_test,TestAugSplit)
            
           N = cla.gallery.db_size; %n. dicts
           M = cla.gallery.num_train;
           nAugTest = size(I_test,2); %n. rappresentation of the I_Test
           nAtomsxSbj = cla.gallery.num_train/size(cla.gallery.sbj_ID,2);
           % perform WLDA projection of dictionaries and apply klimaps
           WLDAt = cellfun(@transpose, cla.gallery.WLDA,'UniformOutput', false); 
           IDsuppTot = [];
           for d=1:N %forall Dict
               IDsupp = [];
               for l=1:nAugTest %forall Feat
                   if TestAugSplit(d,l)
                       F_test = WLDAt{d}*I_test{l};
                       Alpha{d,l} =  cla.KLiMapS(F_test, cla.gallery.train_LDA{d}, cla.gallery.train_LDA_inv{d},  nAtomsxSbj,  5);
                       IDsupp = [IDsupp, cla.gallery.train_ID(logical(Alpha{d,l}(:)))];
                   end
               end
               IDsuppTot = [IDsuppTot, IDsupp];
           end
            
           %ID IDENTIFIED AT MAJORITY TAKING ALL VOTES
           ID = mode(IDsuppTot);
       end
    end
    
    methods (Access = private)
             
        function alpha = KLiMapS(~,s,D,DINV,k,maxIter)
            alpha = DINV*s;
            a = sort(abs(alpha));
            lambda = 1/a(end-k);
            for i=1:maxIter
                % apply sparsity constraction mapping: increase sparsity
                beta = alpha.*(1-exp(-lambda.*abs(alpha)));
                % apply the orthogonal projection
                alpha = beta-DINV*(D*beta-s);
                % update the lambda coefficient
                a = sort(abs(alpha));
                lambda = 1/a(end-k);
            end
            [~,idx] = sort(abs(alpha));
            alpha(idx(1:end-k)) = 0;
        end
    end
end

