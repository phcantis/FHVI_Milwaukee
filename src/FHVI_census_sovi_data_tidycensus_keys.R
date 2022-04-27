## TITLE: PROCESSING RAW CENSUS DATA TO GENERATE A FLOOD-HEALTH RISK INDEX IN MILWAUKEE, WI
## DEVELOPER: PABLO HERREROS CANTIS (phcantis@gmail.com | herrerop@newschool.edu)
## DATE: APRIL 2022

### THIS SCRIPT IS USED TO STORE THE KEYS NEEDED TO DOWNLOAD THE DIFFERENT SEVERAL DATASETS, 
### FOR THE SAKE OF TIDYNESS IN THE FHVI_census_sovi_data.R FILE

### ADD AND PROCESS SOVI VARS 

vars_ACS19 <- load_variables(2019, "acs5", cache = TRUE)
vars_cen10 <- load_variables(2010, "sf1", cache = TRUE)

vi10_Total <- c("P009001", "tot_pop_cen10")

vi10_White <- c("P009005", "White")
vi10_Black <- c("P009006", "Black")
vi10_Black_two_or_more <- c("P009021", "Black_x2")
vi10_Latinx <- c("P009002", "Latinx")
vi10_Asian <- c("P009008", "Asian")

vi10_malemin5 <- c("P012003", "m_0_5")
vi10_male6.9 <- c("P012004", "m_6_9")
vi10_male10.14 <- c("P012005", "m_10_14")
vi10_male15.17 <- c("P012006", "m_15_17")

vi10_femalemin5 <- c("P012027", "f_0_5")
vi10_female6.9 <- c("P012028", "f_6_9")
vi10_female10.14 <- c("P012029", "f_10_14")
vi10_female15.17 <- c("P012030", "f_15_17")

vi10_male65.66 <- c("P012020", "m_65_66")
vi10_male67.69 <- c("P012021", "m_67_69")
vi10_male70.74 <- c("P012022", "m_70_74")
vi10_male75.79 <- c("P012023", "m_75_79")
vi10_male80.84 <- c("P012024", "m_80_84")
vi10_male85 <- c("P012025", "m_85plus")

vi10_female65.66 <- c("P012044", "f_65_66")
vi10_female67.69 <- c("P012045", "f_67_69")
vi10_female70.74 <- c("P012046", "f_70_74")
vi10_female75.79 <- c("P012047", "f_75_79")
vi10_female80.84 <- c("P012048", "f_80_84")
vi10_female85 <- c("P012049", "f_85plus")

decennial_vars <- list(vi10_White,
                       vi10_Black,
                       vi10_Black_two_or_more,
                       vi10_Latinx,
                       vi10_Asian,
                       vi10_malemin5,
                       vi10_male6.9,
                       vi10_male10.14,
                       vi10_male15.17,
                       vi10_femalemin5,
                       vi10_female6.9,
                       vi10_female10.14,
                       vi10_female15.17,
                       vi10_male65.66,
                       vi10_male67.69,
                       vi10_male70.74,
                       vi10_male75.79,
                       vi10_male80.84,
                       vi10_male85,
                       vi10_female65.66,
                       vi10_female67.69,
                       vi10_female70.74,
                       vi10_female75.79,
                       vi10_female80.84,
                       vi10_female85)

vi_total_incomeratio <- c("C17002_001", "incrat_total")
vi_total_incomeratiomin50 <- c("C17002_002", "incrat_50")
vi_total_incomeratio50_99 <- c("C17002_003", "incrat_99")
vi_total_incomeratio100_124 <- c("C17002_004", "incrat_124")
vi_total_incomeratio125_149 <- c("C17002_005", "incrat_149")
vi_total_incomeratio150_184 <- c("C17002_006", "incrat_184")
vi_total_incomeratio185_199 <- c("C17002_007", "incrat_199")

vi_total_25 <- c("B15002_001", "total_above25")
vi_male_NoSch <- c("B15002_003", "m_NoSch")
vi_male_4thg <- c("B15002_004", "m_4thg")
vi_male_6thg <- c("B15002_005", "m_6thg")
vi_male_8thg <- c("B15002_006", "m_8thg")
vi_male_9thg <- c("B15002_007", "m_9thg")
vi_male_10thg <- c("B15002_008", "m_10thg")
vi_male_11thg <- c("B15002_009", "m_11thg")
vi_male_12thg <- c("B15002_010", "m_12thg")
vi_female_NoSch <- c("B15002_020", "f_NoSch")
vi_female_4thg <- c("B15002_021", "f_4thg")
vi_female_6thg <- c("B15002_022", "f_6thg")
vi_female_8thg <- c("B15002_023", "f_8thg")
vi_female_9thg <- c("B15002_024", "f_9thg")
vi_female_10thg <- c("B15002_025", "f_10thg")
vi_female_11thg <- c("B15002_026", "f_11thg")
vi_female_12thg <- c("B15002_027", "f_12thg")

vi_total_hins <- c("B18135_001", "total_hins")
vi_hins_19A <- c("B18135_007", "hins_19A")
vi_hins_19B <- c("B18135_012", "hins_19B")
vi_hins_64A <- c("B18135_018", "hins_64A")
vi_hins_64B <- c("B18135_023", "hins_64B")
vi_hins_65A <- c("B18135_029", "hins_65A")
vi_hins_65B <- c("B18135_034", "hins_65B")

vi_ab5 <- c("B16004_001", "total_lang")
vi_sp_not_well5.17 <- c("B16004_007", "sp517__wll")
vi_sp_not_all5.17 <- c("B16004_008", "sp517__all")
vi_ie_not_well5.17 <- c("B16004_012", "ie517__wll")
vi_ie_not_all5.17 <- c("B16004_013", "ie517__all")
vi_ap_not_well5.17 <- c("B16004_017", "ap517__wll")
vi_ap_not_all5.17 <- c("B16004_018", "ap517__all")
vi_ol_not_well5.17 <- c("B16004_022", "ol517__wll")
vi_ol_not_all5.17 <- c("B16004_023", "ol517__all")
vi_sp_not_well18.64 <- c("B16004_029", "sp1864_nt_wll")
vi_sp_not_all18.64 <- c("B16004_030", "sp1864_nt_all")
vi_ie_not_well18.64 <- c("B16004_034", "ie1864_nt_wll")
vi_ie_not_all18.64 <- c("B16004_035", "ie1864_nt_all")
vi_ap_not_well18.64 <- c("B16004_039", "ap1864_nt_wll")
vi_ap_not_all18.64 <- c("B16004_040", "ap1864_nt_all")
vi_ol_not_well18.64 <- c("B16004_044", "ol1864_nt_wll")
vi_ol_not_all18.64 <- c("B16004_045", "ol1864_nt_all")
vi_sp_not_well65p <- c("B16004_051", "sp65_nt_wll")
vi_sp_not_all65p <- c("B16004_052", "sp65_nt_all")
vi_ie_not_well65p <- c("B16004_056", "ie65_nt_wll")
vi_ie_not_all65p <- c("B16004_057", "ie65_nt_all")
vi_ap__not_well65p <- c("B16004_061", "ap65_nt_wll")
vi_ap_not_all65p <- c("B16004_062", "ap65_nt_all")
vi_ol_not_well65p <- c("B16004_066", "ol65_nt_wll")
vi_ol_not_all65p <- c("B16004_067", "ol65_nt_all")

vi_total_dis <- c("B18101_001", "total_dis")
vi_male0.5_dis <- c("B18101_004", "m_dis0_5")
vi_male5.17_dis <- c("B18101_007", "m_dis5_17")
vi_male18.34_dis <- c("B18101_010", "m_dis18_34")
vi_male35.64_dis <- c("B18101_013", "m_dis35_64")
vi_male65.75_dis <- c("B18101_016", "m_dis65_75")
vi_male75_dis <- c("B18101_019", "m_dis75plus")

vi_female0.5_dis <- c("B18101_023", "f_dis0_5")
vi_female5.17_dis <- c("B18101_026", "f_dis5_17")
vi_female18.34_dis <- c("B18101_029", "f_dis18_34")
vi_female35.64_dis <- c("B18101_032", "f_dis35_64")
vi_female65.75_dis <- c("B18101_035", "f_dis65_75")
vi_female75_dis <- c("B18101_038", "f_dis75plus")

vi_total_hh_nocar <- c("B25044_001", "total_hh_nocar")
vi_owned_nocar <- c("B25044_003", "owned_nocar")
vi_rented_nocar <- c("B25044_010", "rented_nocar")

vi_total_hh_livealone <- c("B11012_001", "total_hh_livealone")

vi_female_livealone <- c("B11012_009", "hh_f_livalone")
vi_male_livealone <- c("B11012_014", "hh_m_livalone")

vi_total_units <- c("B25024_001", "total_units")
vi_mob_home_units <- c("B25024_010", "mobhome_units")

acs_vars <- list(vi_total_incomeratiomin50,
                 vi_total_incomeratio50_99,
                 vi_total_incomeratio100_124,
                 vi_total_incomeratio125_149,
                 vi_total_incomeratio150_184,
                 vi_total_incomeratio185_199,
                 vi_total_25,
                 vi_male_NoSch,
                 vi_male_4thg,
                 vi_male_6thg,
                 vi_male_8thg,
                 vi_male_9thg,
                 vi_male_10thg,
                 vi_male_11thg,
                 vi_male_12thg,
                 vi_female_NoSch,
                 vi_female_4thg,
                 vi_female_6thg,
                 vi_female_8thg,
                 vi_female_9thg,
                 vi_female_10thg,
                 vi_female_11thg,
                 vi_female_12thg,
                 vi_total_hins,
                 vi_hins_19A,
                 vi_hins_19B,
                 vi_hins_64A,
                 vi_hins_64B,
                 vi_hins_65A,
                 vi_hins_65B,
                 vi_ab5,
                 vi_sp_not_well5.17,
                 vi_sp_not_all5.17,
                 vi_ie_not_well5.17,
                 vi_ie_not_all5.17,
                 vi_ap_not_well5.17,
                 vi_ap_not_all5.17,
                 vi_ol_not_well5.17,
                 vi_ol_not_all5.17,
                 vi_sp_not_well18.64,
                 vi_sp_not_all18.64,
                 vi_ie_not_well18.64,
                 vi_ie_not_all18.64,
                 vi_ap_not_well18.64,
                 vi_ap_not_all18.64,
                 vi_ol_not_well18.64,
                 vi_ol_not_all18.64,
                 vi_sp_not_well65p,
                 vi_sp_not_all65p,
                 vi_ie_not_well65p,
                 vi_ie_not_all65p,
                 vi_ap__not_well65p,
                 vi_ap_not_all65p,
                 vi_ol_not_well65p,
                 vi_ol_not_all65p,
                 vi_total_dis,
                 vi_male0.5_dis,
                 vi_male5.17_dis,
                 vi_male18.34_dis,
                 vi_male35.64_dis,
                 vi_male65.75_dis,
                 vi_male75_dis,
                 vi_female0.5_dis,
                 vi_female5.17_dis,
                 vi_female18.34_dis,
                 vi_female35.64_dis,
                 vi_female65.75_dis,
                 vi_female75_dis,
                 vi_total_hh_nocar,
                 vi_owned_nocar,
                 vi_rented_nocar,
                 vi_total_hh_livealone,
                 vi_female_livealone,
                 vi_male_livealone)