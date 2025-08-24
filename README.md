# County Health Rankings- Exploring Social Determinants of Health and Cardiovascular Health
Through the Lens of Life’s Essential 8: A Spatial Data Analysis


## Overview
- This project investigates the relationship between social determinants of health (SDOH), structural racism (via residential segregation), and cardiovascular health (CVH) across 3,108 U.S. counties. Using the American Heart Association’s Life’s Essential 8 (LE8) framework, the analysis evaluates how social and structural factors shape population-level CVH and how these patterns vary geographically.
🔗 More about CHR&R: countyhealthrankings.org

## Research Aim
- To assess geographic variation in county-level CVH
- To explore associations between SDOH factors (economic, social, educational, and healthcare access) and CVH
- To evaluate how residential segregation contributes to observed disparities

## Data Sources
	•	County Health Rankings (2019) – county-level socioeconomic and health factor data
	•	CDC PLACES – measures to calculate CVH scores using LE8 metrics
	•	AHRQ SDOH Database – indicators of economic stability, education, healthcare, and community context
	•	Index of Concentration at the Extremes (ICE) – residential segregation metrics
	•	Publicly available datasets covering 3108 U.S. counties (contiguous U.S. only)
 
## Methods
- Study design: Ecological study at the county level
- Outcome variable: Composite CVH score (0–16) derived from LE8 metrics (diet, physical activity, nicotine exposure, sleep, BMI, cholesterol, blood glucose, blood pressure)
- Exposure variables: County-level SDOH measures (income, education, race/ethnicity, housing, access to food, healthcare, etc.) and ICE segregation scores
 
## Analysis pipeline:
- Data merged, cleaned, and standardized into z-scores
- Conducted exploratory analysis and summarized statistics descriptively
- Generated regression modeling: OLS (baseline), spatial error, spatial lag, and spatial Durbin models
- Preformed diagnostic tests using Moran’s I, and lagrange multipliers to detect spatial autocorrelation
- Model comparison was done using AIC

## Results
- We found evidence of spatial clustering in CVH scores across counties (Moran’s I = 0.47, p < 0.001)
- Counties with higher percentages of Black populations, low income households, and lower educational attainment showed significant associations with poorer CVH scores
- Spatial regression models outperformed OLS, with the Spatial Durbin model providing the best fit (lowest AIC)
- Non-metropolitan status, poverty, racial composition, and housing indicators demonstrated significant spatial associations with CVH

## Conclusion
- Results of this study highlighted persistent geographic and racial inequities in cardiovascular health, with clear evidence of spatial dependence showing that outcomes in one county are influenced by those in neighboring counties. These findings indicates the importance of regional approaches to intervention. Policy efforts aimed at improving cardiovascular health must address income inequality, education, housing, and healthcare access while also tackling structural racism to reduce disparities.
-  Overall, the study demonstrates how spatial data analysis, grounded in the Life’s Essential 8 framework, can uncover the role of social and structural determinants in shaping cardiovascular outcomes and provide actionable insights for policymakers and public health leaders seeking to advance health equity.

### Note: 
- The analysis was conducted in R using packages such as spdep, spatialreg, sf, psych, dplyr, and openxlsx, and employed methods including Moran’s I tests, Lagrange multiplier diagnostics, and spatial econometric models.
- This project was completed as a hands-on exercise in-
	•	Managing large, publicly available datasets
	•	Applying regression methods in a real-world health context
	•	Communicating findings through reproducible R scripts and clear visualizations

