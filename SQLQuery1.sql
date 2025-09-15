CREATE DATABASE AGE_CARE;

USE AGE_CARE;
GO

SELECT * FROM Residents_Details;

CREATE VIEW Residents_Risk_Level AS
SELECT *,
  CASE
    WHEN Dementia = 1 OR Fall_Incident_Count >= 3 OR
         Mobility_Category IN ('Bedridden', 'Wheel Chair') OR Assist_Type = 'Double Assist'
      THEN 'High'
    WHEN Fall_Incident_Count BETWEEN 1 AND 2 OR Mobility_Category = 'Walker'
      THEN 'Medium'
    ELSE 'Low'
  END AS risk_level
FROM Residents_details;

Select * FROM Residents_Risk_Level;

-- Example: Risk distribution
SELECT risk_level, COUNT(*) FROM Residents_Risk_Level GROUP BY risk_level;

-- Residents by Age Group
Create View Age_Group AS
SELECT
  CASE 
    WHEN age BETWEEN 65 AND 74 THEN '65-74'
    WHEN age BETWEEN 75 AND 84 THEN '75-84'
    WHEN age BETWEEN 85 AND 94 THEN '85-94'
    ELSE '95+'
  END AS age_group,
  COUNT(*) AS count
FROM residents_Details
GROUP BY Age;

Select * from Age_Group;

-- Fall Incidents by Age Group
CREATE VIEW Fall_Incident_By_Group AS
SELECT
  CASE 
    WHEN age BETWEEN 65 AND 74 THEN '65-74'
    WHEN age BETWEEN 75 AND 84 THEN '75-84'
    WHEN age BETWEEN 85 AND 94 THEN '85-94'
    ELSE '95+'
  END AS age_group,
  SUM(Fall_Incident_Count) AS falls
FROM Residents_Details GROUP BY Age;

Select * FROM Fall_Incident_By_Group;

SELECT 
  ROUND(
    100.0 * 
    SUM(CASE WHEN Dementia = 1 AND (
      Dementia = 1 OR Fall_Incident_Count >= 3 OR 
      Mobility_Category IN ('Bedridden', 'Wheel Chair') OR Assist_Type = 'Double Assist'
    ) THEN 1 ELSE 0 END) / 
    NULLIF(SUM(CASE WHEN 
      Dementia = 1 OR Fall_Incident_Count >= 3 OR 
      Mobility_Category IN ('Bedridden', 'Wheel Chair') OR Assist_Type = 'Double Assist'
    THEN 1 ELSE 0 END), 0),
  2
) AS [percent]
FROM Residents_Details;

-- Fall Incidents by Location
CREATE VIEW Fall_Incident_By_Location AS
SELECT Fall_Location, COUNT(*) AS incidents
FROM Residents_Details
WHERE Fall_Incident_Count > 0
GROUP BY Fall_Location;


-- Mobility vs Risk Level
Create View Mobility_RiskLevel AS
SELECT Mobility_Category, risk_level, COUNT(*) AS total
FROM [dbo].[Residents_Risk_Level]
GROUP BY Mobility_Category, risk_level;

-- Assist Type vs Risk Level
SELECT Assist_Type, risk_level, COUNT(*) AS total
FROM Residents_Risk_Level GROUP BY Assist_Type, risk_level;

-- High-Risk Residents needing Double Assist
CREATE VIEW High_risk_Residents AS
SELECT * FROM Residents_Risk_Level
WHERE risk_level = 'High' AND Assist_Type = 'Double Assist';

-- Fall Incidents by Age Group
-- Fall Incidents by Age Group

-- Top 10 Residents with Most Falls
SELECT TOP 10 Resident_Name, Fall_Incident_Count
FROM Residents_Details
ORDER BY Fall_Incident_Count DESC;