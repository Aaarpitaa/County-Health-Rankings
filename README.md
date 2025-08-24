# County Health Rankings- Exploring Social Determinants of Health and Cardiovascular Health
Through the Lens of Life’s Essential 8: A Spatial Data Analysis


## Overview
- This project explores county-level health data from the County Health Rankings & Roadmaps (CHR&R) program, developed by the University of Wisconsin Population Health Institute. The CHR&R provides annual, publicly available data on health outcomes and health factors across all U.S. counties. The goal of this analysis is to examine the relationship between health factors and health outcomes in the state of Pennsylvania (N = 65 counties), with a focus on understanding drivers of community health disparities.
🔗 More about CHR&R: countyhealthrankings.org

## Research Question
- How do health factors in Pennsylvania counties influence length of life, as measured by Years of Potential Life Lost (YPLL) Rate?

## Health Factors Considered
The CHR&R conceptual model groups predictors into four domains:
	•	Health Behaviors
	•	Clinical Care
	•	Social and Economic Factors
	•	Physical Environment

- In this project, I selected one domain of interest to evaluate its association with YPLL. In addition, demographic measures (e.g., age distribution, race/ethnicity, % rural population, % female, % not proficient in English) were considered as potential covariates

## Methods
	•	Imported and cleaned CHR&R county-level data for Pennsylvania
	•	Selected outcome: Years of Potential Life Lost Rate
	•	Chose predictors from one health factor domain, supplemented by demographics
	•	Applied regression modeling in R to assess associations between predictors and the outcome
	•	Produced data visualizations to highlight patterns and county-level variation

## Purpose
This project was completed as part of coursework in Statistical Computing in R and served as a hands-on exercise in:
	•	Managing large, publicly available datasets.
	•	Applying regression methods in a real-world health context
	•	Communicating findings through reproducible R scripts and clear visualizations

