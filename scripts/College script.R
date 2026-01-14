# ---------------------- CLEAR WORKSPACE ----------------------
rm(list = ls())

# ---------------------- LOAD LIBRARIES -----------------------
library(readr)
library(dplyr)
library(ggplot2)
library(psych)
library(forcats)
library(stargazer)
library(here)

# ---------------------- FILE PATH SETUP ----------------------
library(here)
data_file <- here("data", "pppub24.csv")
if (!file.exists(data_file)) {
  stop("Missing data/pppub24.csv. Download CPS ASEC 2024 and save it there.")
}

# ---------------------- LOAD DATA ----------------------------
data <- read_csv(data_file)

# ---------------------- RENAME VARIABLES ---------------------
data <- data %>%
  rename(
    age     = A_AGE,
    sex     = A_SEX,
    race    = PRDTRACE,
    educ    = A_HGA,
    inctot  = TAX_INC,
    marital = A_MARITL,
    hhrole  = A_FAMREL
  )

# ---------------------- FILTER & TRANSFORM -------------------
data <- data %>%
  filter(age >= 25) %>%
  mutate(
    educ_years = case_when(
      educ == 31 ~ 0, educ == 32 ~ 1, educ == 33 ~ 5, educ == 34 ~ 8,
      educ == 35 ~ 9, educ == 36 ~ 10, educ == 37 ~ 12, educ == 38 ~ 12,
      educ == 39 ~ 13, educ == 40 ~ 14, educ == 41 ~ 14, educ == 42 ~ 16,
      educ == 43 ~ 18, educ == 44 ~ 20, educ == 45 ~ 21, TRUE ~ NA_real_
    ),
    college_attend = ifelse(educ >= 39, 1, 0),
    sex = factor(sex, levels = c(1, 2), labels = c("Male", "Female")),
    race = factor(race, levels = c(1, 2, 3, 4, 5, 6, 7),
                  labels = c("White", "Black", "American Indian", "Asian",
                             "Hawaiian/Pacific Islander", "Multiracial", "Other")),
    married = ifelse(marital %in% c(1, 2), 1, 0),
    head_of_household = ifelse(hhrole == 1, 1, 0)
  ) %>%
  filter(!is.na(educ_years), !is.na(college_attend), !is.na(inctot),
         !is.na(race), !is.na(sex), !is.na(married), !is.na(head_of_household))

# ---------------------- DESCRIPTIVE STATS --------------------
cat("Summary Table:\n")
describe(select(data, educ_years, college_attend, inctot, age, married, head_of_household))

cat("\nCollege Attendance Rate:\n")
print(prop.table(table(data$college_attend)))

# ---------------------- REGRESSION MODELS --------------------

# Linear regression on education years
model_lm <- lm(educ_years ~ inctot + race + sex, data = data)

# Logistic: unadjusted (race only)
model_logit_unadj <- glm(college_attend ~ race, data = data, family = binomial)

# Logistic: adjusted model
model_logit_adj <- glm(college_attend ~ log(inctot + 1) + race + sex + married + head_of_household,
                       data = data, family = binomial)

cat("\nLinear Regression Summary:\n")
print(summary(model_lm))

cat("\nLogistic Regression (Adjusted) Summary:\n")
print(summary(model_logit_adj))

cat("\nOdds Ratios (Adjusted Logit):\n")
print(exp(coef(model_logit_adj)))

# ---------------------- STARGAZER OUTPUT ---------------------
stargazer(model_logit_unadj, model_logit_adj,
          type = "text",
          title = "Unadjusted vs Adjusted Models: College Attendance",
          dep.var.labels = c("Attended College"),
          column.labels = c("Unadjusted", "Adjusted"),
          covariate.labels = c("Log(Income + 1)", "Black", "American Indian", "Asian",
                               "Pacific Islander", "Multiracial", "Other",
                               "Female", "Married", "Head of Household"),
          no.space = TRUE)

# ---------------------- PLOTS: KEY VISUALS ----------------------
dir.create("figures", showWarnings = FALSE)

p_race <- ggplot(data, aes(x = race, fill = factor(college_attend, labels = c("No", "Yes")))) +
  geom_bar(position = "fill", color = "white") +
  scale_y_continuous(labels = scales::percent_format()) +
  labs(title = "College Attendance by Race",
       x = "Race", y = "Percentage", fill = "Attended College") +
  theme_minimal()

ggsave("figures/college_attendance_by_race.png", p_race, width = 8, height = 5, dpi = 200, bg="white")


p_sex <- ggplot(data, aes(x = sex, fill = factor(college_attend, labels = c("No", "Yes")))) +
  geom_bar(position = "fill", color = "white") +
  scale_y_continuous(labels = scales::percent_format()) +
  labs(title = "College Attendance by Gender",
       x = "Sex", y = "Percentage", fill = "Attended College") +
  theme_minimal()

ggsave("figures/college_attendance_by_gender.png", p_sex, width = 8, height = 5, dpi = 200, bg="white")


p_married <- ggplot(data, aes(x = factor(married, labels = c("No", "Yes")),
                              fill = factor(college_attend, labels = c("No", "Yes")))) +
  geom_bar(position = "fill", color = "white") +
  scale_y_continuous(labels = scales::percent_format()) +
  labs(title = "College Attendance by Marital Status",
       x = "Married", y = "Percentage", fill = "Attended College") +
  theme_minimal()

ggsave("figures/college_attendance_by_marital_status.png", p_married, width = 8, height = 5, dpi = 200, bg="white")


p_hh <- ggplot(data, aes(x = factor(head_of_household, labels = c("No", "Yes")),
                         fill = factor(college_attend, labels = c("No", "Yes")))) +
  geom_bar(position = "fill", color = "white") +
  scale_y_continuous(labels = scales::percent_format()) +
  labs(title = "College Attendance by Household Role",
       x = "Head of Household", y = "Percentage", fill = "Attended College") +
  theme_minimal()

ggsave("figures/college_attendance_by_household_role.png", p_hh, width = 8, height = 5, dpi = 200, bg="white")


p_income <- ggplot(data, aes(x = log(inctot + 1), y = educ_years)) +
  geom_jitter(alpha = 0.2, size = 0.5) +
  geom_smooth(method = "lm", se = FALSE, color = "steelblue", linewidth = 1) +
  labs(title = "Education Years vs. Log Income",
       x = "Log(Income + 1)", y = "Years of Education") +
  theme_minimal()

ggsave("figures/educ_years_vs_log_income.png", p_income, width = 8, height = 5, dpi = 200, bg="white")
# ---------------------- ODDS RATIO PLOT -----------------------

library(broom)  # for tidying model output

# Tidy logistic model results with exponentiated coefficients
tidy_model <- tidy(model_logit_adj, exponentiate = TRUE, conf.int = TRUE)

# Remove intercept
tidy_model <- tidy_model[tidy_model$term != "(Intercept)", ]

# Clean term names
tidy_model$term <- recode(tidy_model$term,
                          `log(inctot + 1)` = "Log(Income + 1)",
                          `raceBlack` = "Black",
                          `raceAmerican Indian` = "American Indian",
                          `raceAsian` = "Asian",
                          `raceHawaiian/Pacific Islander` = "Pacific Islander",
                          `raceMultiracial` = "Multiracial",
                          `raceOther` = "Other",
                          `sexFemale` = "Female",
                          `married` = "Married",
                          `head_of_household` = "Head of Household"
)

# Plot odds ratios
p_or <- ggplot(tidy_model, aes(x = reorder(term, estimate), y = estimate)) +
  geom_point(size = 3, color = "steelblue") +
  geom_errorbar(aes(ymin = conf.low, ymax = conf.high), width = 0.2) +
  geom_hline(yintercept = 1, linetype = "dashed", color = "gray40") +
  coord_flip() +
  labs(title = "Figure 1. Odds Ratios from Adjusted Logistic Model",
       x = "Variable", y = "Odds Ratio (exp(β))") +
  theme_minimal()

ggsave("figures/odds_ratios_adjusted_logit.png", p_or, width = 8, height = 5, dpi = 200, bg="white")


