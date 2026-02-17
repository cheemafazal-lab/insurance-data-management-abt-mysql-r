### Data Management Assignment ######

### Data loaded into R with all 4 tables using the Global Environment ##########
### Loading the dplyr package ###########

install.packages("dplyr")
library(dplyr)

##### Joining tables in R to create an ABT ########

abt_insurance <- Data_1_Customer %>%
  left_join(Data_2_Motor_Policies,  by = "MotorID") %>%
  left_join(Data_3_Health_Policies, by = "HealthID") %>%
  left_join(Data_4_Travel_Policies, by = "TravelID")

## INspecting the data #######
glimpse(abt_insurance)
summary(abt_insurance)

### Conducting a thorough data quality check and fixing issues #################
### In the ages column we have age numbers like 180 which are not valid and need to be excluded#####
### These are outliers in the data ######
abt_insurance <- abt_insurance %>% mutate(Age= ifelse(Age< 0 | Age > 100, NA, Age))
glimpse(abt_insurance)
### This has replaced the outliers with NA #####
### There are some invalid categories that need fixing #########
abt_insurance <- abt_insurance %>%
  mutate(CardType = ifelse(CardType == "0", NA, CardType))

##### Now we standardize the claims fields numclaim and clm ######
abt_insurance <- abt_insurance %>%
  mutate(
    clm = ifelse(is.na(clm), 0, clm),
    Numclaims = ifelse(is.na(Numclaims), 0, Numclaims)
  )

## removing records where policy and dat occurs before start date
abt_insurance <- abt_insurance %>%
  filter(is.na(policyStart.x) | policyEnd >= policyStart.x)

### Now we remove the records where travel policy and date is before the start date #######
abt_insurance <- abt_insurance %>%
  filter(is.na(policyStart.y) | PolicyEnd.y >= policyStart.y)

### Now we remove duplicates ###############
abt_insurance %>% count(CustomerID) %>% filter(n>1)

### We will handle extreme vehicle values at the 99th Percentile #####
cap <- quantile(abt_insurance$veh_value, 0.99, na.rm = TRUE)

abt_insurance <- abt_insurance %>%
  mutate(veh_value = ifelse(veh_value > cap, cap, veh_value))


#### Final View of the data ######
glimpse(abt_insurance
)
summary(abt_insurance)

######## DATA QUALITY @@@@@

#### Again function for cleaning outliers in Age ########
n <- nrow(abt_insurance)
abt_insurance %>% summarise(
  min_age = min(Age, na.rm=TRUE),
  max_age = max(Age, na.rm=TRUE),
  outlier_age = sum(Age < 0 | Age > 100, na.rm=TRUE),
  outlier_age_pct = outlier_age/n
)

#### Vehicle value outliers ########
abt_insurance %>% summarise(
  p99 = quantile(veh_value, 0.99, na.rm=TRUE),
  above_p99 = sum(veh_value > quantile(veh_value, 0.99, na.rm=TRUE), na.rm=TRUE)
)

#####Category levels to spot invalid codes
abt_insurance %>% count(CardType, sort=TRUE)
abt_insurance %>% count(ComChannel, sort=TRUE)


#######################################################################
################ DATA INSIGHTS #######################################
######################################################################

names(abt)

############################################
############################################
library(dplyr)

# Work from ABT
abt <- abt_insurance

### Fix ComChannel small coding issue (E/P/S -> full labels)
abt <- abt %>%
  mutate(
    ComChannel = ifelse(ComChannel == "E", "Email", ComChannel),
    ComChannel = ifelse(ComChannel == "P", "Phone", ComChannel),
    ComChannel = ifelse(ComChannel == "S", "SMS",   ComChannel)
  )

#### Create simple age groups (customer characteristics)
abt <- abt %>%
  mutate(
    age_group = case_when(
      is.na(Age) ~ "Unknown",
      Age < 30 ~ "Under 30",
      Age <= 49 ~ "30–49",
      TRUE ~ "50+"
    )
  )

############################################
# QUERY 1: Channel size + Age profile
############################################
q1_channel_profile <- abt %>%
  group_by(ComChannel) %>%
  summarise(
    customers = n(),
    share = customers / nrow(abt),
    median_age = median(Age, na.rm = TRUE),
    iqr_age = IQR(Age, na.rm = TRUE)
  ) %>%
  arrange(desc(customers))

q1_channel_profile

library(dplyr)

abt <- abt_insurance %>%
  mutate(
    has_motor  = !is.na(PolicyStart),
    has_health = !is.na(policyStart.x),
    has_travel = !is.na(policyStart.y)
  )

############################################
# QUERY 2: Product uptake by channel
############################################
q2_uptake_by_channel <- abt %>%
  group_by(ComChannel) %>%
  summarise(
    customers = n(),
    motor_uptake  = mean(has_motor),
    health_uptake = mean(has_health),
    travel_uptake = mean(has_travel)
  ) %>%
  arrange(desc(customers))

q2_uptake_by_channel

abt <- abt %>%
  mutate(
    age_group = case_when(
      is.na(Age) ~ "Unknown",
      Age < 30 ~ "Under 30",
      Age <= 49 ~ "30–49",
      TRUE ~ "50+"
    )
  )
############################################
# QUERY 3: Product uptake by age group
############################################
q3_uptake_by_age <- abt %>%
  group_by(age_group) %>%
  summarise(
    customers = n(),
    motor_uptake  = mean(has_motor),
    health_uptake = mean(has_health),
    travel_uptake = mean(has_travel)
  ) %>%
  arrange(match(age_group, c("Under 30","30–49","50+","Unknown")))

q3_uptake_by_age

############################################
# QUERY 4: Motor claims by channel (motor customers only)
############################################
q4_motor_claims_by_channel <- abt %>%
  filter(has_motor) %>%
  group_by(ComChannel) %>%
  summarise(
    motor_customers = n(),
    claim_rate = mean(clm == 1, na.rm = TRUE),
    median_numclaims = median(Numclaims, na.rm = TRUE),
    iqr_numclaims = IQR(Numclaims, na.rm = TRUE),
    median_exposure = median(Exposure, na.rm = TRUE),
    iqr_exposure = IQR(Exposure, na.rm = TRUE)
  ) %>%
  arrange(desc(motor_customers))

q4_motor_claims_by_channel


overall_age <- abt %>%
  summarise(
    n = n(),
    mean_age = mean(Age, na.rm = TRUE),
    trimmed_mean_age_10pct = mean(Age, trim = 0.10, na.rm = TRUE),
    median_age = median(Age, na.rm = TRUE),
    iqr_age = IQR(Age, na.rm = TRUE)
  )

overall_vehicle_value <- abt %>%
  summarise(
    median_veh_value = median(veh_value, na.rm = TRUE),
    iqr_veh_value = IQR(veh_value, na.rm = TRUE),
    p99_veh_value = quantile(veh_value, 0.99, na.rm = TRUE)
  )

overall_age
overall_vehicle_value


install.packages("ggplot2")
library(ggplot2)

############################################
##PLOT 1 Customers by preferred channel
############################################
ggplot(q1_channel_profile, aes(x = ComChannel, y = customers)) +
  geom_col() +
  labs(x = "Preferred channel", y = "Number of customers")

############################################
# PLOT 2 Product uptake by channel (motor/health/travel)
############################################
uptake_long <- rbind(
  data.frame(ComChannel = q2_uptake_by_channel$ComChannel, product = "Motor",  uptake = q2_uptake_by_channel$motor_uptake),
  data.frame(ComChannel = q2_uptake_by_channel$ComChannel, product = "Health", uptake = q2_uptake_by_channel$health_uptake),
  data.frame(ComChannel = q2_uptake_by_channel$ComChannel, product = "Travel", uptake = q2_uptake_by_channel$travel_uptake)
)

ggplot(uptake_long, aes(x = ComChannel, y = uptake, fill = product)) +
  geom_col(position = "dodge") +
  labs(x = "Preferred channel", y = "Uptake rate (share of customers)")

############################################
# PLOT 3 Product uptake by age group
############################################
age_long <- rbind(
  data.frame(age_group = q3_uptake_by_age$age_group, product = "Motor",  uptake = q3_uptake_by_age$motor_uptake),
  data.frame(age_group = q3_uptake_by_age$age_group, product = "Health", uptake = q3_uptake_by_age$health_uptake),
  data.frame(age_group = q3_uptake_by_age$age_group, product = "Travel", uptake = q3_uptake_by_age$travel_uptake)
)

ggplot(age_long, aes(x = age_group, y = uptake, fill = product)) +
  geom_col(position = "dodge") +
  labs(x = "Age group", y = "Uptake rate (share of customers)")

############################################
# PLOT 4 Motor claim rate by channel
############################################
ggplot(q4_motor_claims_by_channel, aes(x = ComChannel, y = claim_rate)) +
  geom_col() +
  labs(x = "Preferred channel", y = "Motor claim rate")

############################################
############################################
ggplot(abt, aes(x = veh_value)) +
  geom_histogram(bins = 30) +
  labs(x = "Vehicle value", y = "Count")



