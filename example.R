library(conmat)
library(brap)

set.seed(2022-08-31)
library(future)
plan(multisession, workers = 4)
polymod_contact_data <- get_polymod_setting_data()
polymod_survey_data <- get_polymod_population()

setting_models <- fit_setting_contacts(
  contact_data_list = polymod_contact_data,
  population = polymod_survey_data
)

# Then we take this model and extrapolate to the fairfield data:
fairfield_age_pop <- abs_age_lga("Fairfield (C)")
fairfield_age_pop
set.seed(2022-09-01)
synthetic_settings_5y_fairfield <- predict_setting_contacts(
  population = fairfield_age_pop,
  contact_model = setting_models,
  age_breaks = c(seq(0, 85, by = 5), Inf)
)

# Next we'll convert the contact matrix to a next generation matrix, 
# with a specified reproduction number of 2.5
# Q: How do we decide what the R value should be?

ngm <- calibrate_ngm(ngm_unscaled = synthetic_settings_5y_fairfield$all, 
                     R = 2.5)
ngm

# Now let's simulate some cases and convert this to a matrix
n_groups <- ncol(ngm)

cases <- sim_cases(n_cases = 100, 
                   n_groups = n_groups)

cases

cases_matrix <- cases_to_matrix(cases = cases, n_groups = n_groups)

cases_matrix

# And now let's simulate multiple generations of cases
case_counts <- project(ngm = ngm,
                       infections_matrix = cases_matrix,
                       n_days_project = 10)

case_counts

rowSums(case_counts)
