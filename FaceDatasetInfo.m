classdef FaceDatasetInfo
    %FaceDatasetInfo Describe datasets characteristics and
    %collects the illumination and feature types.
      
    properties (Constant)
        feature_names = {'RAW', 'dct','hog','hogs8','hog9','mslbp','shearlet','wavelet', 'DeepFeat36', 'DeepFeat36_Augmented_Avg', ...
            'DeepFeat36_s1_c1_f1', 'DeepFeat36_s1_c1_f2', 'DeepFeat36_s1_c2_f1', 'DeepFeat36_s1_c2_f2', 'DeepFeat36_s1_c3_f1', ...
            'DeepFeat36_s1_c3_f2', 'DeepFeat36_s1_c4_f1', 'DeepFeat36_s1_c4_f2', 'DeepFeat36_s1_c5_f1', 'DeepFeat36_s1_c5_f2', ...
            'DeepFeat36_s2_c1_f1', 'DeepFeat36_s2_c1_f2', 'DeepFeat36_s2_c2_f1', 'DeepFeat36_s2_c2_f2', 'DeepFeat36_s2_c3_f1', ...
            'DeepFeat36_s2_c3_f2', 'DeepFeat36_s2_c4_f1', 'DeepFeat36_s2_c4_f2', 'DeepFeat36_s2_c5_f1', 'DeepFeat36_s2_c5_f2', ...
            'DeepFeat36_s3_c1_f1', 'DeepFeat36_s3_c1_f2', 'DeepFeat36_s3_c2_f1', 'DeepFeat36_s3_c2_f2', 'DeepFeat36_s3_c3_f1', ...
            'DeepFeat36_s3_c3_f2', 'DeepFeat36_s3_c4_f1', 'DeepFeat36_s3_c4_f2', 'DeepFeat36_s3_c5_f1', 'DeepFeat36_s3_c5_f2', ...
            'DeepFeat36_s1_f1', ...
            'DeepFeat36_SingleImg_s1_f1', 'DeepFeat36_SingleImg_s1_f2',...
            'DeepFeat36_SingleImg_s2_f1', 'DeepFeat36_SingleImg_s2_f2', ...
            'DeepFeat36_SingleImg_s3_f1', 'DeepFeat36_SingleImg_s3_f2'};
        
        illuminations_names = {'ASSR','Homo','RET','MSR','MSQ','SF','SSQ','SSR', 'NONE'}
    end
    
    properties (SetAccess = protected)
        name                % dataset name
        db_name             % database name
        filename            % features filenames
        num_sbj             % number of subjects
        feat_name           % feature list
        illu_name           % illumination list
        path
    end
    
    methods
        % contructs a face database info
        function fdb = FaceDatasetInfo(name, SERVER)
            switch name
                case 'MULTI-PIE'
                    fdb.name = 'MULTI-PIE';
                    fdb.db_name = 'MULTI_PIE_80x70';
                    fdb.filename = 'MULTI_PIE_80x70';
                    fdb.num_sbj = 337;
                    fdb.feat_name = {'hog'};
                    fdb.illu_name = {'MSQ','ASSR','HOMO'};
                case 'YaleB'
                    fdb.name = 'YaleB';
                    fdb.db_name = 'YaleB_80x72';
                    fdb.filename = 'YaleB_80x72';
                    fdb.num_sbj = 38;
                    fdb.feat_name = {'RAW'};
                    fdb.illu_name = {'ASSR','MSQ','SSQ'};
                case 'FRGC_Uncontrolled'
                    fdb.name = 'FRGC_Uncontrolled';
                    fdb.db_name = 'FRGC_Uncontrolled_80x70';
                    fdb.filename = 'FRGC_Uncontrolled_80x70';
                    fdb.num_sbj = 289;
                    fdb.feat_name = {'hog','mslbp','shearlet'};
                    fdb.illu_name = {'ASSR','MSQ','SSQ'};
                case 'LFW'
                    fdb.path = fdb.paths(SERVER);
                    fdb.name = 'LFW';
                    fdb.db_name = 'LFW_FUNNELED_AllSbj';
                    fdb.filename = 'LFW_FUNNELED';
                    fdb.num_sbj = 50; %100; %158; %793; %1680;
                    
                    idx = 1;    
                    for s=1:4           % four scales
                        for c=1:9       % nine crops
                            for f=1:2   % two flips
                                fdb.feat_name{idx} = ['DeepFeat36_VeryLarge_SingleImg_s' num2str(s) '_c' num2str(c) '_f' num2str(f)];
                                idx = idx + 1;
                            end
                        end
                    end
                    
                    fdb.illu_name = {'NONE'};
                case 'FACEBOOK'
                    fdb.name = 'FACEBOOK';
                    fdb.db_name = 'FACEBOOK';
                    fdb.filename = 'FACEBOOK';
                    fdb.num_sbj = 28; %610;
                    fdb.feat_name = {'DeepFeat36_VeryLarge_SingleImg_s1_f1', 'DeepFeat36_VeryLarge_SingleImg_s1_f2', ...
                        'DeepFeat36_VeryLarge_SingleImg_s2_f1', 'DeepFeat36_VeryLarge_SingleImg_s2_f2', ...
                        'DeepFeat36_VeryLarge_SingleImg_s3_f1', 'DeepFeat36_VeryLarge_SingleImg_s3_f2'};
                    fdb.illu_name = {'NONE'};
            end
        end
    end
end