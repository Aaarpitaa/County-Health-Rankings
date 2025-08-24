
# ============================================================
# Project: SDOH, Segregation, and Cardiovascular Health (LE8)
# Script:  Spatial Regression Analysis.R
# Author:  <Your Name>
# Purpose: Clean + spatial regression (OLS, SAR, SEM, SDM)
# ============================================================

# Use renv to manage packages (recommended):
# renv::init(); renv::snapshot()

suppressPackageStartupMessages({
  library(dplyr)
  library(readxl)      
  library(openxlsx)    # reading .xlsx 
  library(psych)       # describe(), etc.
  library(sf)          # spatial data
  library(spdep)       # neighbors & weights
  library(spatialreg)  # SAR/SEM/SDM models
  library(tidyr)
  library(stringr)
  library(stats)
})

set.seed(2025)

# data files in: repo_root/data/
# - finalTabbLE8data.RData   (contains an object named, e.g., `alldata_us`)
# - cvhSR_Feb2024_2.0.xlsx

DATA_DIR <- "data"
CVH_RDATA <- file.path(DATA_DIR, "finalTabbLE8data.RData")
SDOH_XLSX <- file.path(DATA_DIR, "cvhSR_Feb2024_2.0.xlsx")

# RData can contain multiple objects; load to a temp env and pull what you need
env <- new.env()
load(CVH_RDATA, envir = env)

stopifnot("alldata_us" %in% ls(env))
alldata_us <- get("alldata_us", envir = env)

# SDOH excel
upsdohdat <- openxlsx::read.xlsx(SDOH_XLSX)

# Basic checks
message("alldata_us: ", nrow(alldata_us), " rows")
message("upsdohdat:  ", nrow(upsdohdat), " rows")

# --- 3) Merge + Key variables -------------------------------

# key variable in Both data frames- FIPSNEW
stopifnot("FIPSNEW" %in% names(alldata_us), "FIPSNEW" %in% names(upsdohdat))

merged_data <- alldata_us %>%
  inner_join(upsdohdat, by = "FIPSNEW")

# Ensure RUCC is numeric; then categorize:
# 1–3: Metropolitan; 4–9: Urban (as per your note)
merged_data <- merged_data %>%
  mutate(
    AHRF_USDA_RUCC_2013 = as.numeric(AHRF_USDA_RUCC_2013),
    AHRF_USDA_RUCC_2013_category = cut(
      AHRF_USDA_RUCC_2013,
      breaks = c(0, 3, 9),
      labels = c("Metropolitan", "Urban"),
      include.lowest = TRUE, right = TRUE
    )
  )

# Outcome: us8tert.x (LE8 tertile?) – keep as numeric for modeling
stopifnot("us8tert.x" %in% names(merged_data))

# ---Exploratory stats (clean) ---------------------------

# summary of numerics
numeric_cols <- merged_data %>%
  select(where(is.numeric)) %>%
  names()

desc_tbl <- psych::describe(merged_data[, numeric_cols])
# print(head(desc_tbl))

# merged_data |> summarise(across(c(ACS_PCT_BLACK_NONHISP, ACS_PCT_HISPANIC), list(mean=mean, sd=sd), na.rm=TRUE))

# Variable selection: correlation screen --------------

# Candidate predictors
predictors_raw <- c(
  "AHRF_USDA_RUCC_2013",        # numeric; category version used in models below
  "ACS_PCT_BLACK_NONHISP",
  "ACS_PCT_HISPANIC",
  "ACS_PCT_WHITE_NONHISP",
  "ACS_PCT_CTZ_US_BORN",
  "ACS_PCT_FOREIGN_BORN",
  "ACS_MEDIAN_HH_INC",
  "ACS_PCT_HH_FOOD_STMP",
  "ACS_PCT_HH_1FAM_FOOD_STMP",
  "ACS_PCT_PERSON_INC_BELOW99",
  "ACS_PCT_PERSON_INC_ABOVE200",
  "ACS_PCT_HS_GRADUATE",
  "ACS_PCT_HU_MOBILE_HOME",
  "ACS_PCT_VACANT_HU",
  "ACS_PCT_RENTER_HU_CHILD",
  "ACS_PCT_PUB_COMMT_60MINUP",
  "MP_PCT_ADVTG_PEN"
)

# Restrict to numerics present:
predictors_num <- intersect(predictors_raw, names(merged_data))
predictors_num <- predictors_num[sapply(merged_data[predictors_num], is.numeric)]

# Correlation matrix (pairwise.complete.obs to avoid dropping rows)
cor_mat <- cor(merged_data[predictors_num], use = "pairwise.complete.obs")
# print(round(cor_mat, 2))  

# After your correlation screen, choose final predictors (as per your notes)
final_predictors <- c(
  "AHRF_USDA_RUCC_2013_category",  
  "ACS_PCT_BLACK_NONHISP",
  "ACS_PCT_HISPANIC",
  "ACS_PCT_CTZ_US_BORN",
  "ACS_MEDIAN_HH_INC",
  "ACS_PCT_HH_FOOD_STMP",
  "ACS_PCT_PERSON_INC_BELOW99",
  "ACS_PCT_HS_GRADUATE",
  "ACS_PCT_HU_MOBILE_HOME",
  "ACS_PCT_VACANT_HU",
  "ACS_PCT_RENTER_HU_CHILD",
  "ACS_PCT_PUB_COMMT_60MINUP",
  "MP_PCT_ADVTG_PEN"
)

final_predictors <- intersect(final_predictors, names(merged_data))

model_df <- merged_data %>%
  select(FIPSNEW, us8tert.x, all_of(final_predictors)) %>%
  mutate(
    AHRF_USDA_RUCC_2013_category = factor(AHRF_USDA_RUCC_2013_category)
  )

# Missingness summary
missing_counts <- sapply(model_df, function(x) sum(is.na(x)))
# print(missing_counts)

# Spatial neighbors (Queen contiguity) ----------------
# Assumes merged_data/model_df contains polygon geometry (sf)
stopifnot(inherits(merged_data, "sf") || "geometry" %in% names(merged_data))

# If geometries might be invalid, fix them:
model_sf <- st_as_sf(merged_data) %>% st_make_valid()

# s2 off helps poly2nb on some datasets
sf_use_s2(FALSE)

nb_queen <- spdep::poly2nb(pl = model_sf, queen = TRUE, snap = 0.1)
lw_queen <- spdep::nb2listw(nb_queen, style = "W", zero.policy = TRUE)

# --- Models ---------------------------------------------

# a) OLS
ols_formula <- as.formula(
  paste("us8tert.x ~",
        paste(c(
          "AHRF_USDA_RUCC_2013_category",
          setdiff(final_predictors, "AHRF_USDA_RUCC_2013_category")
        ), collapse = " + "))
)

ols_model <- lm(ols_formula, data = model_sf)
summary(ols_model)
AIC(ols_model)
lm.morantest(ols_model, lw_queen)  # spatial residual autocorrelation

# b) Spatial Lag (SAR)
lag_model <- spatialreg::lagsarlm(ols_formula, data = model_sf, listw = lw_queen,
                                  zero.policy = TRUE)
summary(lag_model)
AIC(lag_model)

# c) Spatial Error (SEM)
error_model <- spatialreg::errorsarlm(ols_formula, data = model_sf, listw = lw_queen,
                                      zero.policy = TRUE)
summary(error_model)
AIC(error_model)

# d) Spatial Durbin (SDM; lag + WX)
# Use lagsarlm(..., type="mixed") for Durbin
durbin_model <- spatialreg::lagsarlm(ols_formula, data = model_sf, listw = lw_queen,
                                     zero.policy = TRUE, type = "mixed")
summary(durbin_model)
AIC(durbin_model)

# Impacts (Monte Carlo for inference)
# Note: impacts() for SDM may require specifying R for simulation
imp_durbin <- spatialreg::impacts(durbin_model, listw = lw_queen, R = 1000)
summary(imp_durbin)

# ---Quick reporting objects -----------------------------

out <- list(
  desc = desc_tbl,
  missing = missing_counts,
  cor = cor_mat,
  ols = summary(ols_model),
  lag = summary(lag_model),
  err = summary(error_model),
  durbin = summary(durbin_model),
  durbin_impacts = summary(imp_durbin)
)

# saveRDS(out, file = "outputs/model_summaries.rds")


