CREATE DATABASE insurance;
USE insurance;
SHOW tables IN insurance;
ALTER TABLE `Insurance`.`data 1_customer` 
RENAME TO  `Insurance`.`customers` ;
ALTER TABLE `Insurance`.`data 2_motor policies` 
RENAME TO  `Insurance`.`motor_policies` ;
ALTER TABLE `Insurance`.`data 3_health policies` 
RENAME TO  `Insurance`.`health_policies` ;
ALTER TABLE `Insurance`.`data 4_travel policies` 
RENAME TO  `Insurance`.`travel_policies` ;
SHOW tables IN insurance;
DESCRIBE Insurance.customers;
USE insurance;
DESCRIBE motor_policies;
DESCRIBE health_policies;
DESCRIBE travel_policies;
DROP TABLE IF EXISTS insurance.abt_insurance;
 
CREATE TABLE insurance.abt_insurance AS
SELECT
  c.CustomerID,
  c.Title,
  c.GivenName,
  c.MiddleInitial,
  c.Surname,
  c.CardType,
  c.Occupation,
  c.Gender,
  c.Age,
  c.Location,
  c.ComChannel,
 
  -- Motor
  m.PolicyStart     AS MotorPolicyStart,
  m.PolicyEnd       AS MotorPolicyEnd,
  m.MotorType,
  m.veh_value,
  m.Exposure        AS MotorExposure,
  m.clm             AS MotorClaimFlag,
  m.Numclaims       AS MotorNumClaims,
  m.v_body,
  m.v_age,
  m.LastClaimDate   AS MotorLastClaimDate,
 
  -- Health
  h.policyStart     AS HealthPolicyStart,
  h.policyEnd       AS HealthPolicyEnd,
  h.HealthType,
  h.HealthDependentsAdults,
  h.DependentsKids,
 
  -- Travel
  t.policyStart     AS TravelPolicyStart,
  t.PolicyEnd       AS TravelPolicyEnd,
  t.TravelType,
  t.MyUnknownColumn AS TravelUnknown
 
FROM insurance.customers c
LEFT JOIN insurance.motor_policies  m ON c.MotorID  = m.MotorID
LEFT JOIN insurance.health_policies h ON c.HealthID = h.HealthID
LEFT JOIN insurance.travel_policies t ON c.TravelID = t.TravelID;
 
-- 1. Row count
SELECT COUNT(*) AS total_customers
FROM insurance.abt_insurance;
 
-- 2. Missing values (example: Age)
SELECT COUNT(*) AS missing_age
FROM insurance.abt_insurance
WHERE Age IS NULL;
 
-- 3. Basic statistics
SELECT
  AVG(Age) AS avg_age,
  MIN(Age) AS min_age,
  MAX(Age) AS max_age
FROM insurance.abt_insurance;
 
-- 4. Claims summary
SELECT
  Gender,
  AVG(MotorNumClaims) AS avg_motor_claims
FROM insurance.abt_insurance
GROUP BY Gender;
 
-- 5. Policy uptake by type
SELECT
  COUNT(MotorPolicyStart)  AS motor_policies,
  COUNT(HealthPolicyStart) AS health_policies,
  COUNT(TravelPolicyStart) AS travel_policies
FROM insurance.abt_insurance;
 
-- 6. Average exposure (motor)
SELECT
  AVG(MotorExposure) AS avg_motor_exposure
FROM insurance.abt_insurance
WHERE MotorExposure IS NOT NULL;
 
-- 7. Claim frequency (motor)
SELECT
  SUM(MotorNumClaims) AS total_motor_claims,
  COUNT(*) AS total_customers
FROM insurance.abt_insurance
WHERE MotorNumClaims IS NOT NULL;
 
-- 8. Channel preference
SELECT
  ComChannel,
  COUNT(*) AS customers
FROM insurance.abt_insurance
GROUP BY ComChannel;
 
-- 9. Age vs policy ownership
SELECT
  CASE
    WHEN Age < 30 THEN 'Under 30'
    WHEN Age BETWEEN 30 AND 49 THEN '30–49'
    WHEN Age >= 50 THEN '50+'
  END AS age_group,
  COUNT(MotorPolicyStart) AS motor_policy_count
FROM insurance.abt_insurance
GROUP BY age_group;
 
-- 1) Row count and uniqueness
SELECT COUNT(*) AS abt_rows, COUNT(DISTINCT CustomerID) AS distinct_customers
FROM insurance.abt_insurance;
 
-- 2) Duplicate customers 
SELECT CustomerID, COUNT(*) n
FROM insurance.abt_insurance
GROUP BY CustomerID
HAVING n > 1;
 
-- 3) Product overall
SELECT
  SUM(MotorPolicyStart  IS NOT NULL)  AS motor_customers,
  SUM(HealthPolicyStart IS NOT NULL)  AS health_customers,
  SUM(TravelPolicyStart IS NOT NULL)  AS travel_customers
FROM insurance.abt_insurance;
 
-- 4) Key missingness 
SELECT
  SUM(Age IS NULL) AS missing_age,
  SUM(Gender IS NULL OR Gender='') AS missing_gender,
  SUM(Location IS NULL OR Location='') AS missing_location,
  SUM(ComChannel IS NULL OR ComChannel='') AS missing_comchannel
FROM insurance.abt_insurance;
 
-- 5) Date validity
SELECT
  SUM(MotorPolicyStart  IS NOT NULL AND MotorPolicyEnd  < MotorPolicyStart)  AS invalid_motor_dates,
  SUM(HealthPolicyStart IS NOT NULL AND HealthPolicyEnd < HealthPolicyStart) AS invalid_health_dates,
  SUM(TravelPolicyStart IS NOT NULL AND TravelPolicyEnd < TravelPolicyStart) AS invalid_travel_dates
FROM insurance.abt_insurance;
 
-- 6) Claims consistency
SELECT
  SUM(MotorNumClaims < 0) AS neg_numclaims,
  SUM(MotorClaimFlag NOT IN (0,1) AND MotorClaimFlag IS NOT NULL) AS invalid_claimflag
FROM insurance.abt_insurance;
 
 
 
 
 
 
 





