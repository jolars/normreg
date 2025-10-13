using OrderedCollections

BASE_URL = "https://www.csie.ntu.edu.tw/~cjlin/libsvmtools/datasets/"
DATASETS = OrderedDict(
    # ======================================================================== #
    # Binary
    # ======================================================================== #
    "a1a" => Dict(:file => "a1a", :type => "binary", :dims => (1_605, 123), :ncls => 2),
    "a1a.t" =>
        Dict(:file => "a1a.t", :type => "binary", :dims => (30_956, 123), :ncls => 2),
    "a2a" => Dict(:file => "a2a", :type => "binary", :dims => (2_265, 123), :ncls => 2),
    "a2a.t" =>
        Dict(:file => "a2a.t", :type => "binary", :dims => (30_296, 123), :ncls => 2),
    "a3a" => Dict(:file => "a3a", :type => "binary", :dims => (3_185, 123), :ncls => 2),
    "a3a.t" =>
        Dict(:file => "a3a.t", :type => "binary", :dims => (29_376, 123), :ncls => 2),
    "a4a" => Dict(:file => "a4a", :type => "binary", :dims => (4_781, 123), :ncls => 2),
    "a4a.t" =>
        Dict(:file => "a4a.t", :type => "binary", :dims => (27_780, 123), :ncls => 2),
    "a5a" => Dict(:file => "a5a", :type => "binary", :dims => (6_414, 123), :ncls => 2),
    "a5a.t" =>
        Dict(:file => "a5a.t", :type => "binary", :dims => (26_147, 123), :ncls => 2),
    "a6a" => Dict(:file => "a6a", :type => "binary", :dims => (11_220, 123), :ncls => 2),
    "a6a.t" =>
        Dict(:file => "a6a.t", :type => "binary", :dims => (21_341, 123), :ncls => 2),
    "a7a" => Dict(:file => "a7a", :type => "binary", :dims => (16_100, 123), :ncls => 2),
    "a7a.t" =>
        Dict(:file => "a7a.t", :type => "binary", :dims => (16_461, 123), :ncls => 2),
    "a8a" => Dict(:file => "a8a", :type => "binary", :dims => (22_696, 123), :ncls => 2),
    "a8a.t" => Dict(:file => "a8a.t", :type => "binary", :dims => (9_865, 123), :ncls => 2),
    "a9a" => Dict(:file => "a8a", :type => "binary", :dims => (32_561, 123), :ncls => 2),
    "a9a.t" =>
        Dict(:file => "a8a.t", :type => "binary", :dims => (16_281, 123), :ncls => 2),
    "australian" =>
        Dict(:file => "australian", :type => "binary", :dims => (690, 14), :ncls => 2),
    "australian_scale" =>
        Dict(:file => "australian_scale", :type => "binary", :dims => (690, 14), :ncls => 2),
    "avazu-app" => Dict(
        :file => "avazu-app.bz2",
        :type => "binary",
        :dims => (14_596_137, 1_000_000),
        :ncls => 2,
    ),
    "avazu-app.t" => Dict(
        :file => "avazu-app.t.bz2",
        :type => "binary",
        :dims => (1_719_304, 1_000_000),
        :ncls => 2,
    ),
    "avazu-app.tr" => Dict(
        :file => "avazu-app.tr.bz2",
        :type => "binary",
        :dims => (12_642_186, 1_000_000),
        :ncls => 2,
    ),
    "avazu-app.val" => Dict(
        :file => "avazu-app.val.bz2",
        :type => "binary",
        :dims => (1_953_951, 1_000_000),
        :ncls => 2,
    ),
    "avazu-site" => Dict(
        :file => "avazu-site.bz2",
        :type => "binary",
        :dims => (25_831_830, 1_000_000),
        :ncls => 2,
    ),
    "avazu-site.t" => Dict(
        :file => "avazu-site.t.bz2",
        :type => "binary",
        :dims => (2_858_160, 1_000_000),
        :ncls => 2,
    ),
    "avazu-site.tr" => Dict(
        :file => "avazu-site.tr.bz2",
        :type => "binary",
        :dims => (23_567_843, 1_000_000),
        :ncls => 2,
    ),
    "avazu-site.val" => Dict(
        :file => "avazu-site.val.bz2",
        :type => "binary",
        :dims => (2_264_987, 1_000_000),
        :ncls => 2,
    ),
    "breast-cancer" =>
        Dict(:file => "breast-cancer", :type => "binary", :dims => (683, 10), :ncls => 2),
    "breast-cancer_scale" => Dict(
        :file => "breast-cancer_scale",
        :type => "binary",
        :dims => (683, 10),
        :ncls => 2,
    ),
    "cod-rna" =>
        Dict(:file => "cod-rna", :type => "binary", :dims => (59_535, 8), :ncls => 2),
    "cod-rna.t" =>
        Dict(:file => "cod-rna.t", :type => "binary", :dims => (271_617, 8), :ncls => 2),
    "cod-rna.r" =>
        Dict(:file => "cod-rna.r", :type => "binary", :dims => (157_413, 8), :ncls => 2),
    "colon-cancer" => Dict(
        :file => "colon-cancer.bz2",
        :type => "binary",
        :dims => (62, 2_000),
        :ncls => 2,
    ),
    "covtype.binary" => Dict(
        :file => "covtype.libsvm.binary.bz2",
        :type => "binary",
        :dims => (581_012, 54),
        :ncls => 2,
    ),
    "covtype.binary.scale" => Dict(
        :file => "covtype.libsvm.binary.scale.bz2",
        :type => "binary",
        :dims => (581_012, 54),
        :ncls => 2,
    ),
    # TODO : fill criteo dims
    # "criteo" => Dict(
    #     :file => "criteo.kaggle2014.svm.tar.xz",
    #     :type => "binary",
    #     :dims => (?, 1_000_000),
    #     :ncls => 2,
    # ),
    # TODO : fill criteo_tb dims
    # "criteo_tb" => Dict(
    #     :file => "criteo_tb.svm.tar.xz",
    #     :type => "binary",
    #     :dims => (?, 1_000_000),
    #     :ncls => 2,
    # ),
    "diabetes" =>
        Dict(:file => "diabetes", :type => "binary", :dims => (768, 8), :ncls => 2),
    "diabetes_scale" =>
        Dict(:file => "diabetes_scale", :type => "binary", :dims => (768, 8), :ncls => 2),
    "duke" => Dict(:file => "duke.bz2", :type => "binary", :dims => (44, 7129), :ncls => 2),
    "duke.tr" =>
        Dict(:file => "duke.tr.bz2", :type => "binary", :dims => (38, 7129), :ncls => 2),
    "duke.val" =>
        Dict(:file => "duke.val.bz2", :type => "binary", :dims => (4, 7129), :ncls => 2),
    "epsilon_normalized" => Dict(
        :file => "epsilon_normalized.xz",
        :type => "binary",
        :dims => (400_000, 2_000),
        :ncls => 2,
    ),
    "epsilon_normalized.t" => Dict(
        :file => "epsilon_normalized.t.xz",
        :type => "binary",
        :dims => (100_000, 2_000),
        :ncls => 2,
    ),
    "fourclass" =>
        Dict(:file => "fourclass", :type => "binary", :dims => (862, 2), :ncls => 2),
    "fourclass_scale" =>
        Dict(:file => "fourclass_scale", :type => "binary", :dims => (862, 2), :ncls => 2),
    "german.number" =>
        Dict(:file => "german.number", :type => "binary", :dims => (1_000, 24), :ncls => 2),
    "german.number_scale" => Dict(
        :file => "german.number_scale",
        :type => "binary",
        :dims => (1_000, 24),
        :ncls => 2,
    ),
    "gisette_scale" => Dict(
        :file => "gisette_scale.bz2",
        :type => "binary",
        :dims => (6_000, 5_000),
        :ncls => 2,
    ),
    "gisette_scale.t" => Dict(
        :file => "gisette_scale.t.bz2",
        :type => "binary",
        :dims => (1_000, 5_000),
        :ncls => 2,
    ),
    "heart" => Dict(:file => "heart", :type => "binary", :dims => (270, 13), :ncls => 2),
    "heart_scale" =>
        Dict(:file => "heart_scale", :type => "binary", :dims => (270, 13), :ncls => 2),
    "HIGGS" =>
        Dict(:file => "HIGGS.xz", :type => "binary", :dims => (11_000_000, 28), :ncls => 2),
    "ijcnn" =>
        Dict(:file => "ijcnn.bz2", :type => "binary", :dims => (49_990, 22), :ncls => 2),
    "ijcnn.t" =>
        Dict(:file => "ijcnn.t.bz2", :type => "binary", :dims => (91_701, 22), :ncls => 2),
    "ijcnn.tr" =>
        Dict(:file => "ijcnn.tr.bz2", :type => "binary", :dims => (35_000, 22), :ncls => 2),
    "ijcnn.val" =>
        Dict(:file => "ijcnn.tr.bz2", :type => "binary", :dims => (14_990, 22), :ncls => 2),
    "ionosphere_scale" =>
        Dict(:file => "ionosphere_scale", :type => "binary", :dims => (351, 34), :ncls => 2),
    "kdda" => Dict(
        :file => "kdda.bz2",
        :type => "binary",
        :dims => (8_407_752, 20_216_830),
        :ncls => 2,
    ),
    "kdda.t" => Dict(
        :file => "kdda.t.bz2",
        :type => "binary",
        :dims => (510_302, 20_216_830),
        :ncls => 2,
    ),
    "kddb" => Dict(
        :file => "kddb.bz2",
        :type => "binary",
        :dims => (19_264_097, 29_890_095),
        :ncls => 2,
    ),
    "kddb.t" => Dict(
        :file => "kddb.t.bz2",
        :type => "binary",
        :dims => (748_401, 29_890_095),
        :ncls => 2,
    ),
    # kddb-raw : skip raw data
    "kdd12" => Dict(
        :file => "kdd12.xz",
        :type => "binary",
        :dims => (149_639_105, 54_686_452),
        :ncls => 2,
    ),
    "kdd12.tr" => Dict(
        :file => "kdd12.tr.xz",
        :type => "binary",
        :dims => (119_705_032, 54_686_452),
        :ncls => 2,
    ),
    "kdd12.val" => Dict(
        :file => "kdd12.val.xz",
        :type => "binary",
        :dims => (29_934_073, 54_686_452),
        :ncls => 2,
    ),
    "leukemia" =>
        Dict(:file => "leu.bz2", :type => "binary", :dims => (38, 7129), :ncls => 2),
    "leukemia.t" =>
        Dict(:file => "leu.t.bz2", :type => "binary", :dims => (34, 7129), :ncls => 2),
    "liver-disorders" =>
        Dict(:file => "liver-disorders", :type => "binary", :dims => (145, 5), :ncls => 2),
    "liver-disorders_scale" => Dict(
        :file => "liver-disorders_scale",
        :type => "binary",
        :dims => (145, 5),
        :ncls => 2,
    ),
    "liver-disorders.t" =>
        Dict(:file => "liver-disorders.t", :type => "binary", :dims => (200, 5), :ncls => 2),
    "madelon" =>
        Dict(:file => "madelon", :type => "binary", :dims => (2_000, 500), :ncls => 2),
    "madelon.t" =>
        Dict(:file => "madelon.t", :type => "binary", :dims => (600, 500), :ncls => 2),
    "mushrooms" =>
        Dict(:file => "mushrooms", :type => "binary", :dims => (8_124, 112), :ncls => 2),
    "news20.binary" => Dict(
        :file => "news20.binary.bz2",
        :type => "binary",
        :dims => (19_996, 1_355_191),
        :ncls => 2,
    ),
    "phishing" =>
        Dict(:file => "phishing", :type => "binary", :dims => (11_055, 68), :ncls => 2),
    "rcv1_train.binary" => Dict(
        :file => "rcv1_train.binary.bz2",
        :type => "binary",
        :dims => (20_242, 47_236),
        :ncls => 2,
    ),
    "rcv1_test.binary" => Dict(
        :file => "rcv1_test.binary.bz2",
        :type => "binary",
        :dims => (677_399, 47_236),
        :ncls => 2,
    ),
    "ream-sim" => Dict(
        :file => "ream-sim.bz2",
        :type => "binary",
        :dims => (72_309, 20_958),
        :ncls => 2,
    ),
    "skin_nonskin" =>
        Dict(:file => "skin_nonskin", :type => "binary", :dims => (245_057, 3), :ncls => 2),
    "splice" =>
        Dict(:file => "splice", :type => "binary", :dims => (1_000, 60), :ncls => 2),
    "splice_scale" =>
        Dict(:file => "splice_scale", :type => "binary", :dims => (1_000, 60), :ncls => 2),
    "splice.t" =>
        Dict(:file => "splice.t", :type => "binary", :dims => (2_175, 60), :ncls => 2),
    "splice-site" => Dict(
        :file => "splice_site.xz",
        :type => "binary",
        :dims => (50_000_000, 11_725_480),
        :ncls => 2,
    ),
    "splice-site.t" => Dict(
        :file => "splice_site.t.xz",
        :type => "binary",
        :dims => (4_627_840, 11_725_480),
        :ncls => 2,
    ),
    "sonar_scale" =>
        Dict(:file => "sonar_scale", :type => "binary", :dims => (208, 60), :ncls => 2),
    "SUSY" =>
        Dict(:file => "SUSY.xz", :type => "binary", :dims => (5_000_000, 18), :ncls => 2),
    "svmguide1" =>
        Dict(:file => "svmguide1", :type => "binary", :dims => (3_089, 4), :ncls => 2),
    "svmguide1.t" =>
        Dict(:file => "svmguide1.t", :type => "binary", :dims => (4_000, 4), :ncls => 2),
    "svmguide3" =>
        Dict(:file => "svmguide3", :type => "binary", :dims => (1_243, 22), :ncls => 2),
    "svmguide3.t" =>
        Dict(:file => "svmguide3.t", :type => "binary", :dims => (41, 22), :ncls => 2),
    "url" => Dict(
        :file => "url_combined.bz2",
        :type => "binary",
        :dims => (2_396_130, 3_231_961),
        :ncls => 2,
    ),
    "url_normalized" => Dict(
        :file => "url_normalized_combined.bz2",
        :type => "binary",
        :dims => (2_396_130, 3_231_961),
        :ncls => 2,
    ),
    "w1a" => Dict(:file => "w1a", :type => "binary", :dims => (2_477, 300), :ncls => 2),
    "w1a.t" =>
        Dict(:file => "w1a.t", :type => "binary", :dims => (47_272, 300), :ncls => 2),
    "w2a" => Dict(:file => "w2a", :type => "binary", :dims => (3_470, 300), :ncls => 2),
    "w2a.t" =>
        Dict(:file => "w2a.t", :type => "binary", :dims => (46_279, 300), :ncls => 2),
    "w3a" => Dict(:file => "w3a", :type => "binary", :dims => (4_912, 300), :ncls => 2),
    "w3a.t" =>
        Dict(:file => "w3a.t", :type => "binary", :dims => (44_837, 300), :ncls => 2),
    "w4a" => Dict(:file => "w4a", :type => "binary", :dims => (7_366, 300), :ncls => 2),
    "w4a.t" =>
        Dict(:file => "w4a.t", :type => "binary", :dims => (42_383, 300), :ncls => 2),
    "w5a" => Dict(:file => "w5a", :type => "binary", :dims => (9_888, 300), :ncls => 2),
    "w5a.t" =>
        Dict(:file => "w5a.t", :type => "binary", :dims => (39_861, 300), :ncls => 2),
    "w6a" => Dict(:file => "w6a", :type => "binary", :dims => (17_188, 300), :ncls => 2),
    "w6a.t" =>
        Dict(:file => "w6a.t", :type => "binary", :dims => (32_561, 300), :ncls => 2),
    "w7a" => Dict(:file => "w7a", :type => "binary", :dims => (24_692, 300), :ncls => 2),
    "w7a.t" =>
        Dict(:file => "w7a.t", :type => "binary", :dims => (25_057, 300), :ncls => 2),
    "w8a" => Dict(:file => "w8a", :type => "binary", :dims => (49_749, 300), :ncls => 2),
    "w8a.t" =>
        Dict(:file => "w8a.t", :type => "binary", :dims => (14_951, 300), :ncls => 2),
    "webspam-trigram" => Dict(
        :file => "webspam_wc_normalized_trigram.svm.xz",
        :type => "binary",
        :dims => (350_000, 16_609_143),
        :ncls => 2,
    ),
    "webspam-unigram" => Dict(
        :file => "webspam_wc_normalized_unigram.svm.xz",
        :type => "binary",
        :dims => (350_000, 16_609_143),
        :ncls => 2,
    ),

    # ======================================================================== #
    # Multiclass
    # ======================================================================== #
    "aloi" => Dict(
        :file => "aloi.bz2",
        :type => "multiclass",
        :dims => (108_000, 128),
        :ncls => 1_000,
    ),
    "aloi.scale" => Dict(
        :file => "aloi.scale.bz2",
        :type => "multiclass",
        :dims => (108_000, 128),
        :ncls => 1_000,
    ),
    "cifar10" => Dict(
        :file => "cifar10.bz2",
        :type => "multiclass",
        :dims => (50_000, 3_072),
        :ncls => 10,
    ),
    "cifar10.t" => Dict(
        :file => "cifar10.t.bz2",
        :type => "multiclass",
        :dims => (50_000, 3_072),
        :ncls => 10,
    ),
    "connect-4" =>
        Dict(:file => "connect-4", :type => "multiclass", :dims => (67_557, 126), :ncls => 3),
    "covtype" => Dict(
        :file => "covtype.bz2",
        :type => "multiclass",
        :dims => (581_012, 54),
        :ncls => 7,
    ),
    "covtype.scale01" => Dict(
        :file => "covtype.scale01.bz2",
        :type => "multiclass",
        :dims => (581_012, 54),
        :ncls => 7,
    ),
    "covtype.scale" => Dict(
        :file => "covtype.scale.bz2",
        :type => "multiclass",
        :dims => (581_012, 54),
        :ncls => 7,
    ),
    "dna.scale" =>
        Dict(:file => "dna.scale", :type => "multiclass", :dims => (2_000, 180), :ncls => 3),
    "dna.scale.t" => Dict(
        :file => "dna.scale.t",
        :type => "multiclass",
        :dims => (1_186, 180),
        :ncls => 3,
    ),
    "dna.scale.tr" => Dict(
        :file => "dna.scale.tr",
        :type => "multiclass",
        :dims => (1_400, 180),
        :ncls => 3,
    ),
    "dna.scale.val" => Dict(
        :file => "dna.scale.val",
        :type => "multiclass",
        :dims => (600, 180),
        :ncls => 3,
    ),
    "glass.scale" =>
        Dict(:file => "glass.scale", :type => "multiclass", :dims => (214, 9), :ncls => 6),
    "iris.scale" =>
        Dict(:file => "iris.scale", :type => "multiclass", :dims => (150, 4), :ncls => 3),
    "letter.scale" => Dict(
        :file => "letter.scale",
        :type => "multiclass",
        :dims => (15_000, 16),
        :ncls => 26,
    ),
    "letter.scale.t" => Dict(
        :file => "letter.scale.t",
        :type => "multiclass",
        :dims => (5_000, 16),
        :ncls => 26,
    ),
    "letter.scale.tr" => Dict(
        :file => "letter.scale.tr",
        :type => "multiclass",
        :dims => (10_500, 16),
        :ncls => 26,
    ),
    "letter.scale.val" => Dict(
        :file => "letter.scale.val",
        :type => "multiclass",
        :dims => (4_500, 16),
        :ncls => 26,
    ),
    "mnist" => Dict(
        :file => "mnist.bz2",
        :type => "multiclass",
        :dims => (60_000, 780),
        :ncls => 10,
    ),
    "mnist.t" => Dict(
        :file => "mnist.t.bz2",
        :type => "multiclass",
        :dims => (10_000, 778),
        :ncls => 10,
    ),
    "mnist.scale" => Dict(
        :file => "mnist.scale.bz2",
        :type => "multiclass",
        :dims => (60_000, 780),
        :ncls => 10,
    ),
    "mnist.scale.t" => Dict(
        :file => "mnist.scale.t.bz2",
        :type => "multiclass",
        :dims => (10_000, 778),
        :ncls => 10,
    ),
    "mnist8m" => Dict(
        :file => "mnist8m.xz",
        :type => "multiclass",
        :dims => (8_100_000, 784),
        :ncls => 10,
    ),
    "mnist8m.scale" => Dict(
        :file => "mnist8m.scale.xz",
        :type => "multiclass",
        :dims => (8_100_000, 784),
        :ncls => 10,
    ),
    "news20" => Dict(
        :file => "news20.bz2",
        :type => "multiclass",
        :dims => (15_935, 62_061),
        :ncls => 20,
    ),
    "news20.t" => Dict(
        :file => "news20.t.bz2",
        :type => "multiclass",
        :dims => (3_993, 62_060),
        :ncls => 20,
    ),
    "news20.scale" => Dict(
        :file => "news20.scale.bz2",
        :type => "multiclass",
        :dims => (15_935, 62_061),
        :ncls => 20,
    ),
    "news20.t.scale" => Dict(
        :file => "news20.t.scale.bz2",
        :type => "multiclass",
        :dims => (3_993, 62_060),
        :ncls => 20,
    ),
    "pendigits" =>
        Dict(:file => "pendigits", :type => "multiclass", :dims => (7_494, 16), :ncls => 10),
    "pendigits.t" => Dict(
        :file => "pendigits.t",
        :type => "multiclass",
        :dims => (3_498, 16),
        :ncls => 10,
    ),
    "poker" =>
        Dict(:file => "poker.bz2", :type => "multiclass", :dims => (25_010, 10), :ncls => 10),
    "poker.t" => Dict(
        :file => "poker.t.bz2",
        :type => "multiclass",
        :dims => (1_000_000, 10),
        :ncls => 10,
    ),
    "protein" => Dict(
        :file => "protein.bz2",
        :type => "multiclass",
        :dims => (17_766, 357),
        :ncls => 3,
    ),
    "protein.t" => Dict(
        :file => "protein.t.bz2",
        :type => "multiclass",
        :dims => (6_621, 357),
        :ncls => 3,
    ),
    "protein.tr" => Dict(
        :file => "protein.tr.bz2",
        :type => "multiclass",
        :dims => (14_895, 357),
        :ncls => 3,
    ),
    "protein.val" => Dict(
        :file => "protein.val.bz2",
        :type => "multiclass",
        :dims => (2_871, 357),
        :ncls => 3,
    ),
    "rcv1_tain.multiclass" => Dict(
        :file => "rcv1_tain.multiclass.bz2",
        :type => "multiclass",
        :dims => (15_564, 47_236),
        :ncls => 53,
    ),
    "rcv1_test.multiclass" => Dict(
        :file => "rcv1_test.multiclass.bz2",
        :type => "multiclass",
        :dims => (518_571, 47_236),
        :ncls => 53,
    ),
    "satimage.scale" => Dict(
        :file => "satimage.scale",
        :type => "multiclass",
        :dims => (4_435, 36),
        :ncls => 6,
    ),
    "satimage.scale.t" => Dict(
        :file => "satimage.scale.t",
        :type => "multiclass",
        :dims => (2_000, 36),
        :ncls => 6,
    ),
    "satimage.scale.tr" => Dict(
        :file => "satimage.scale.tr",
        :type => "multiclass",
        :dims => (3_104, 36),
        :ncls => 6,
    ),
    "satimage.scale.val" => Dict(
        :file => "satimage.scale.val",
        :type => "multiclass",
        :dims => (1_331, 36),
        :ncls => 6,
    ),
    "sector" => Dict(
        :file => "sector.bz2",
        :type => "multiclass",
        :dims => (6_412, 55_197),
        :ncls => 105,
    ),
    "sector.t" => Dict(
        :file => "sector.t.bz2",
        :type => "multiclass",
        :dims => (3_207, 55_197),
        :ncls => 105,
    ),
    "sector.scale" => Dict(
        :file => "sector.scale.bz2",
        :type => "multiclass",
        :dims => (6_412, 55_197),
        :ncls => 105,
    ),
    "sector.scale.t" => Dict(
        :file => "sector.t.scale.bz2",
        :type => "multiclass",
        :dims => (3_207, 55_197),
        :ncls => 105,
    ),
    "segment.scale" => Dict(
        :file => "segment.scale",
        :type => "multiclass",
        :dims => (2_310, 19),
        :ncls => 7,
    ),
    "Sensorless" => Dict(
        :file => "Sensorless",
        :type => "multiclass",
        :dims => (58_509, 48),
        :ncls => 11,
    ),
    "Sensorless.scale" => Dict(
        :file => "Sensorless.scale",
        :type => "multiclass",
        :dims => (58_509, 48),
        :ncls => 11,
    ),
    "Sensorless.scale.tr" => Dict(
        :file => "Sensorless.scale.tr",
        :type => "multiclass",
        :dims => (48_509, 48),
        :ncls => 11,
    ),
    "Sensorless.scale.tr" => Dict(
        :file => "Sensorless.scale.tr",
        :type => "multiclass",
        :dims => (10_000, 48),
        :ncls => 11,
    ),
    "shuttle.scale" => Dict(
        :file => "shuttle.scale",
        :type => "multiclass",
        :dims => (43_500, 9),
        :ncls => 7,
    ),
    "shuttle.scale.t" => Dict(
        :file => "shuttle.scale.t",
        :type => "multiclass",
        :dims => (14_500, 9),
        :ncls => 7,
    ),
    "shuttle.scale.tr" => Dict(
        :file => "shuttle.scale.tr",
        :type => "multiclass",
        :dims => (30_450, 9),
        :ncls => 7,
    ),
    "shuttle.scale.val" => Dict(
        :file => "shuttle.scale.val",
        :type => "multiclass",
        :dims => (13_050, 9),
        :ncls => 7,
    ),
    "smallNORB" => Dict(
        :file => "smallNORB.xz",
        :type => "multiclass",
        :dims => (24_300, 18_432),
        :ncls => 5,
    ),
    "smallNORB.t" => Dict(
        :file => "smallNORB.t.xz",
        :type => "multiclass",
        :dims => (24_300, 18_432),
        :ncls => 5,
    ),
    "smallNORB-32x32" => Dict(
        :file => "smallNORB-32x32.xz",
        :type => "multiclass",
        :dims => (24_300, 2_048),
        :ncls => 5,
    ),
    "smallNORB-32x32.t" => Dict(
        :file => "smallNORB-32x32.t.xz",
        :type => "multiclass",
        :dims => (24_300, 2_048),
        :ncls => 5,
    ),
    "SVHN" => Dict(
        :file => "SVHN.xz",
        :type => "multiclass",
        :dims => (73_257, 3_072),
        :ncls => 10,
    ),
    "SVHN.t" => Dict(
        :file => "SVHN.t.xz",
        :type => "multiclass",
        :dims => (26_032, 3_072),
        :ncls => 10,
    ),
    "SVHN.extra" => Dict(
        :file => "SVHN.extra.xz",
        :type => "multiclass",
        :dims => (531_131, 3_072),
        :ncls => 10,
    ),
    "SVHN.scale" => Dict(
        :file => "SVHN.scale.xz",
        :type => "multiclass",
        :dims => (73_257, 3_072),
        :ncls => 10,
    ),
    "SVHN.scale.t" => Dict(
        :file => "SVHN.scale.t.xz",
        :type => "multiclass",
        :dims => (26_032, 3_072),
        :ncls => 10,
    ),
    "SVHN.scale.extra" => Dict(
        :file => "SVHN.scale.extra.xz",
        :type => "multiclass",
        :dims => (531_131, 3_072),
        :ncls => 10,
    ),
    "svmguide2" =>
        Dict(:file => "svmguide2", :type => "multiclass", :dims => (391, 20), :ncls => 3),
    "svmguide4" =>
        Dict(:file => "svmguide4", :type => "multiclass", :dims => (300, 10), :ncls => 6),
    "svmguide4.t" =>
        Dict(:file => "svmguide4.t", :type => "multiclass", :dims => (312, 10), :ncls => 6),
    "usps" =>
        Dict(:file => "usps.bz2", :type => "multiclass", :dims => (7_291, 256), :ncls => 10),
    "usps.t" => Dict(
        :file => "usps.t.bz2",
        :type => "multiclass",
        :dims => (2_007, 256),
        :ncls => 10,
    ),
    "acoustic" =>
        Dict(:file => "acoustic", :type => "multiclass", :dims => (78_823, 50), :ncls => 3),
    "acoustic.t" =>
        Dict(:file => "acoustic.t", :type => "multiclass", :dims => (19_705, 50), :ncls => 3),
    "acoustic_scale" => Dict(
        :file => "acoustic_scale",
        :type => "multiclass",
        :dims => (78_823, 50),
        :ncls => 3,
    ),
    "acoustic_scale.t" => Dict(
        :file => "acoustic_scale.t",
        :type => "multiclass",
        :dims => (19_705, 50),
        :ncls => 3,
    ),
    "combined" =>
        Dict(:file => "combined", :type => "multiclass", :dims => (78_823, 100), :ncls => 3),
    "combined.t" => Dict(
        :file => "combined.t",
        :type => "multiclass",
        :dims => (19_705, 100),
        :ncls => 3,
    ),
    "combined_scale" => Dict(
        :file => "combined_scale",
        :type => "multiclass",
        :dims => (78_823, 100),
        :ncls => 3,
    ),
    "combined_scale.t" => Dict(
        :file => "combined_scale.t",
        :type => "multiclass",
        :dims => (19_705, 100),
        :ncls => 3,
    ),
    "vehicle.scale" =>
        Dict(:file => "vehicle.scale", :type => "multiclass", :dims => (846, 18), :ncls => 4),
    "vowel" =>
        Dict(:file => "vowel", :type => "multiclass", :dims => (528, 10), :ncls => 11),
    "vowel.t" =>
        Dict(:file => "vowel.t", :type => "multiclass", :dims => (426, 10), :ncls => 11),
    "vowel.scale" =>
        Dict(:file => "vowel.scale", :type => "multiclass", :dims => (528, 10), :ncls => 11),
    "vowel.scale.t" => Dict(
        :file => "vowel.scale.t",
        :type => "multiclass",
        :dims => (426, 10),
        :ncls => 11,
    ),
    "wine.scale" =>
        Dict(:file => "wine.scale", :type => "multiclass", :dims => (178, 13), :ncls => 3),

    # ======================================================================== #
    # Regression
    # ======================================================================== #
    "abalone" =>
        Dict(:file => "abalone", :type => "regression", :dims => (4_177, 8), :ncls => Inf),
    "abalone_scale" => Dict(
        :file => "abalone_scale",
        :type => "regression",
        :dims => (4_177, 8),
        :ncls => Inf,
    ),
    "bodyfat" =>
        Dict(:file => "bodyfat", :type => "regression", :dims => (252, 14), :ncls => Inf),
    "bodyfat_scale" => Dict(
        :file => "bodyfat_scale",
        :type => "regression",
        :dims => (252, 14),
        :ncls => Inf,
    ),
    "cadata" =>
        Dict(:file => "cadata", :type => "regression", :dims => (20_640, 8), :ncls => Inf),
    "cpusmall" =>
        Dict(:file => "cpusmall", :type => "regression", :dims => (8_192, 12), :ncls => Inf),
    "cpusmall_scale" => Dict(
        :file => "cpusmall_scale",
        :type => "regression",
        :dims => (8_192, 12),
        :ncls => Inf,
    ),
    "E2006-log1p.train" => Dict(
        :file => "log1p.E2006.train.bz2",
        :type => "regression",
        :dims => (16_087, 4_272_227),
        :ncls => Inf,
    ),
    "E2006-log1p.test" => Dict(
        :file => "log1p.E2006.test.bz2",
        :type => "regression",
        :dims => (3_308, 4_272_227),
        :ncls => Inf,
    ),
    "E2006.train" => Dict(
        :file => "E2006.train.bz2",
        :type => "regression",
        :dims => (16_087, 150_360),
        :ncls => Inf,
    ),
    "E2006.test" => Dict(
        :file => "E2006.test.bz2",
        :type => "regression",
        :dims => (3_308, 150_360),
        :ncls => Inf,
    ),
    "eunite2001" =>
        Dict(:file => "eunite2001", :type => "regression", :dims => (336, 16), :ncls => Inf),
    "eunite2001.t" =>
        Dict(:file => "eunite2001.t", :type => "regression", :dims => (31, 16), :ncls => Inf),
    "housing" =>
        Dict(:file => "housing", :type => "regression", :dims => (506, 13), :ncls => Inf),
    "housing_scale" => Dict(
        :file => "housing_scale",
        :type => "regression",
        :dims => (506, 13),
        :ncls => Inf,
    ),
    "mg" => Dict(:file => "mg", :type => "regression", :dims => (1_385, 6), :ncls => Inf),
    "mg_scale" =>
        Dict(:file => "mg_scale", :type => "regression", :dims => (1_385, 6), :ncls => Inf),
    "mgp" => Dict(:file => "mg", :type => "regression", :dims => (392, 7), :ncls => Inf),
    "mgp_scale" =>
        Dict(:file => "mg_scale", :type => "regression", :dims => (392, 7), :ncls => Inf),
    "pyrim" =>
        Dict(:file => "pyrim", :type => "regression", :dims => (74, 27), :ncls => Inf),
    "space_ga" =>
        Dict(:file => "space_ga", :type => "regression", :dims => (3_107, 6), :ncls => Inf),
    "space_ga_scale" => Dict(
        :file => "space_ga_scale",
        :type => "regression",
        :dims => (3_107, 6),
        :ncls => Inf,
    ),
    "triazines" =>
        Dict(:file => "triazines", :type => "regression", :dims => (186, 60), :ncls => Inf),
    "triazines_scale" => Dict(
        :file => "triazines_scale",
        :type => "regression",
        :dims => (186, 60),
        :ncls => Inf,
    ),
    "YearPredictionMSD" => Dict(
        :file => "YearPredictionMSD.bz2",
        :type => "regression",
        :dims => (463_715, 90),
        :ncls => Inf,
    ),
    "YearPredictionMSD.t" => Dict(
        :file => "YearPredictionMSD.t.bz2",
        :type => "regression",
        :dims => (51_630, 90),
        :ncls => Inf,
    ),

    # ======================================================================== #
    # Multilabel
    # ======================================================================== #
    "bibtex" => Dict(
        :file => "bibtex.bz2",
        :type => "multilabel",
        :dims => (7_395, 1_836),
        :ncls => 159,
    ),
    "BlogCatalog_deepwalk" => Dict(
        :file => "blogcatalog_deepwalk.svm.bz2",
        :type => "multilabel",
        :dims => (10_312, 128),
        :ncls => 39,
    ),
    "BlogCatalog_line" => Dict(
        :file => "blogcatalog_line.svm.bz2",
        :type => "multilabel",
        :dims => (10_312, 128),
        :ncls => 39,
    ),
    "BlogCatalog_node2vec" => Dict(
        :file => "blogcatalog_node2vec.svm.bz2",
        :type => "multilabel",
        :dims => (10_312, 128),
        :ncls => 39,
    ),
    "delicious" => Dict(
        :file => "delicious.bz2",
        :type => "multilabel",
        :dims => (16_105, 500),
        :ncls => 983,
    ),
    # eurlex_raw : skip raw data
    "eurlex_tfidf_train" => Dict(
        :file => "eurlex_tfidf_train.svm.bz2",
        :type => "multilabel",
        :dims => (15_449, 186_104),
        :ncls => 3_956,
    ),
    "eurlex_tfidf_test" => Dict(
        :file => "eurlex_tfidf_test.svm.bz2",
        :type => "multilabel",
        :dims => (3_865, 186_104),
        :ncls => 3_956,
    ),
    # eurlex57k : skip raw data
    "flickr_deepwalk" => Dict(
        :file => "flickr_deepwalk.svm.bz2",
        :type => "multilabel",
        :dims => (80_513, 128),
        :ncls => 195,
    ),
    "flickr_line" => Dict(
        :file => "flickr_line.svm.bz2",
        :type => "multilabel",
        :dims => (80_513, 128),
        :ncls => 195,
    ),
    "flickr_node2vec" => Dict(
        :file => "flickr_node2vec.svm.bz2",
        :type => "multilabel",
        :dims => (80_513, 128),
        :ncls => 195,
    ),
    "exp1-train" => Dict(
        :file => "train-exp1.svm.bz2",
        :type => "multilabel",
        :dims => (30_993, 120),
        :ncls => 101,
    ),
    "exp1-test" => Dict(
        :file => "test-exp1.svm.bz2",
        :type => "multilabel",
        :dims => (12_914, 120),
        :ncls => 101,
    ),
    "ppi_deepwalk" => Dict(
        :file => "ppi_deepwalk.svm.bz2",
        :type => "multilabel",
        :dims => (56_944, 128),
        :ncls => 121,
    ),
    "ppi_line" => Dict(
        :file => "ppi_line.svm.bz2",
        :type => "multilabel",
        :dims => (56_944, 128),
        :ncls => 121,
    ),
    "ppi_node2vec" => Dict(
        :file => "ppi_node2vec.svm.bz2",
        :type => "multilabel",
        :dims => (56_944, 128),
        :ncls => 121,
    ),
    "rcv1subset_topics_train_1" => Dict(
        :file => "rcv1subset_topics_train_1.svm.bz2",
        :type => "multilabel",
        :dims => (3_000, 47_236),
        :ncls => 101,
    ),
    "rcv1subset_topics_train_2" => Dict(
        :file => "rcv1subset_topics_train_2.svm.bz2",
        :type => "multilabel",
        :dims => (3_000, 47_236),
        :ncls => 101,
    ),
    "rcv1subset_topics_train_3" => Dict(
        :file => "rcv1subset_topics_train_3.svm.bz2",
        :type => "multilabel",
        :dims => (3_000, 47_236),
        :ncls => 101,
    ),
    "rcv1subset_topics_train_4" => Dict(
        :file => "rcv1subset_topics_train_4.svm.bz2",
        :type => "multilabel",
        :dims => (3_000, 47_236),
        :ncls => 101,
    ),
    "rcv1subset_topics_train_5" => Dict(
        :file => "rcv1subset_topics_train_5.svm.bz2",
        :type => "multilabel",
        :dims => (3_000, 47_236),
        :ncls => 101,
    ),
    "rcv1subset_topics_test_1" => Dict(
        :file => "rcv1subset_topics_test_1.svm.bz2",
        :type => "multilabel",
        :dims => (3_000, 47_236),
        :ncls => 101,
    ),
    "rcv1subset_topics_test_2" => Dict(
        :file => "rcv1subset_topics_test_2.svm.bz2",
        :type => "multilabel",
        :dims => (3_000, 47_236),
        :ncls => 101,
    ),
    "rcv1subset_topics_test_3" => Dict(
        :file => "rcv1subset_topics_test_3.svm.bz2",
        :type => "multilabel",
        :dims => (3_000, 47_236),
        :ncls => 101,
    ),
    "rcv1subset_topics_test_4" => Dict(
        :file => "rcv1subset_topics_test_4.svm.bz2",
        :type => "multilabel",
        :dims => (3_000, 47_236),
        :ncls => 101,
    ),
    "rcv1subset_topics_test_5" => Dict(
        :file => "rcv1subset_topics_test_5.svm.bz2",
        :type => "multilabel",
        :dims => (3_000, 47_236),
        :ncls => 101,
    ),
    "rcv1_topics_train" => Dict(
        :file => "rcv1_topics_train.svm.bz2",
        :type => "multilabel",
        :dims => (23_149, 47_236),
        :ncls => 101,
    ),
    "rcv1_topics_test_0" => Dict(
        :file => "rcv1_topics_test_0.svm.bz2",
        :type => "multilabel",
        :dims => (199_328, 47_236),
        :ncls => 101,
    ),
    "rcv1_topics_test_1" => Dict(
        :file => "rcv1_topics_test_1.svm.bz2",
        :type => "multilabel",
        :dims => (199_339, 47_236),
        :ncls => 101,
    ),
    "rcv1_topics_test_2" => Dict(
        :file => "rcv1_topics_test_2.svm.bz2",
        :type => "multilabel",
        :dims => (199_576, 47_236),
        :ncls => 101,
    ),
    "rcv1_topics_test_3" => Dict(
        :file => "rcv1_topics_test_3.svm.bz2",
        :type => "multilabel",
        :dims => (183_022, 47_236),
        :ncls => 101,
    ),
    "rcv1_topics_combined_test" => Dict(
        :file => "rcv1_topics_combined_test.svm.bz2",
        :type => "multilabel",
        :dims => (781_265, 47_236),
        :ncls => 101,
    ),
    "rcv1_industries_train" => Dict(
        :file => "rcv1_industries_train.svm.bz2",
        :type => "multilabel",
        :dims => (23_149, 47_236),
        :ncls => 313,
    ),
    "rcv1_industries_test_0" => Dict(
        :file => "rcv1_industries_test_0.svm.bz2",
        :type => "multilabel",
        :dims => (23_149, 781_265),
        :ncls => 313,
    ),
    "rcv1_industries_test_1" => Dict(
        :file => "rcv1_industries_test_1.svm.bz2",
        :type => "multilabel",
        :dims => (23_149, 781_265),
        :ncls => 313,
    ),
    "rcv1_industries_test_2" => Dict(
        :file => "rcv1_industries_test_2.svm.bz2",
        :type => "multilabel",
        :dims => (23_149, 781_265),
        :ncls => 313,
    ),
    "rcv1_industries_test_3" => Dict(
        :file => "rcv1_industries_test_3.svm.bz2",
        :type => "multilabel",
        :dims => (23_149, 781_265),
        :ncls => 313,
    ),
    "rcv1_regions_train" => Dict(
        :file => "rcv1_regions_train.svm.bz2",
        :type => "multilabel",
        :dims => (23_149, 47_236),
        :ncls => 228,
    ),
    "rcv1_regions_test_0" => Dict(
        :file => "rcv1_regions_test_0.svm.bz2",
        :type => "multilabel",
        :dims => (23_149, 781_265),
        :ncls => 228,
    ),
    "rcv1_regions_test_1" => Dict(
        :file => "rcv1_regions_test_1.svm.bz2",
        :type => "multilabel",
        :dims => (23_149, 781_265),
        :ncls => 228,
    ),
    "rcv1_regions_test_2" => Dict(
        :file => "rcv1_regions_test_2.svm.bz2",
        :type => "multilabel",
        :dims => (23_149, 781_265),
        :ncls => 228,
    ),
    "rcv1_regions_test_3" => Dict(
        :file => "rcv1_regions_test_3.svm.bz2",
        :type => "multilabel",
        :dims => (23_149, 781_265),
        :ncls => 228,
    ),
    "scene_train" => Dict(
        :file => "scene_train.bz2",
        :type => "multilabel",
        :dims => (1_211, 294),
        :ncls => 6,
    ),
    "scene_test" => Dict(
        :file => "scene_test.bz2",
        :type => "multilabel",
        :dims => (1_196, 294),
        :ncls => 6,
    ),
    "tmc2007_train" => Dict(
        :file => "tmc2007_train.svm.bz2",
        :type => "multilabel",
        :dims => (21_519, 30_438),
        :ncls => 22,
    ),
    "tmc2007_test" => Dict(
        :file => "tmc2007_test.svm.bz2",
        :type => "multilabel",
        :dims => (7_077, 30_438),
        :ncls => 22,
    ),
    "wiki10_31k_tfidf_train" => Dict(
        :file => "wiki10_31k_tfidf_train.svm.bz2",
        :type => "multilabel",
        :dims => (14_146, 104_374),
        :ncls => 30_938,
    ),
    "wiki10_31k_tfidf_test" => Dict(
        :file => "wiki10_31k_tfidf_test.svm.bz2",
        :type => "multilabel",
        :dims => (6_616, 104_374),
        :ncls => 30_938,
    ),
    "yeast_train" => Dict(
        :file => "yeast_train.svm.bz2",
        :type => "multilabel",
        :dims => (1_500, 103),
        :ncls => 14,
    ),
    "yeast_test" => Dict(
        :file => "yeast_test.svm.bz2",
        :type => "multilabel",
        :dims => (917, 103),
        :ncls => 14,
    ),
    "youtube_deepwalk" => Dict(
        :file => "youtube_deepwalk.svm.bz2",
        :type => "multilabel",
        :dims => (1_138_499, 128),
        :ncls => 46,
    ),
    "youtube_line" => Dict(
        :file => "youtube_line.svm.bz2",
        :type => "multilabel",
        :dims => (1_138_499, 128),
        :ncls => 46,
    ),
    "youtube_node2vec" => Dict(
        :file => "youtube_node2vec.svm.bz2",
        :type => "multilabel",
        :dims => (1_138_499, 128),
        :ncls => 46,
    ),

    # ======================================================================== #
    # String
    # ======================================================================== #
    # TODO : mnist
)
