DECLARE @Startdate DATETIME
DECLARE @Enddate DATETIME
DECLARE @LicenseType BIGINT

SELECT @StartDate = {StartDate}
SELECT @EndDate = {EndDate}
SELECT @LicenseType = {LicenseType}

SELECT * FROM (
	SELECT DISTINCT 
		E.eFirstName + ' ' + E.eLastName AS [Employee Name],
		E.ID AS [EmployeeID],
		E.eLicenseNumber AS [License Number],
		ET.EmployeeType AS [License Type],
		E.eTypeID AS [LicenseID],
		EC.Label AS [Checklist],
		A.DateCompleted AS [DateCompleted],
		(SELECT 
				CAST(DATEDIFF(DAY, DateCreated, DateCompleted) AS VARCHAR)
		 FROM Applications 
		 WHERE ID =  CASE WHEN EC.ID IS NULL 
							THEN (SELECT MAX (ID) FROM Applications WHERE EmployeeID = E.ID)
						  ELSE (SELECT MAX (ID) FROM Applications WHERE ChecklistID = EC.ID)
					 END AS [Application],
		(SELECT 
			CAST(DATEDIFF (Day, SubmittedAt, CompletedAt) AS VARCHAR)  
		 FROM BackgroundChecks BC
		 WHERE ID = (SELECT MAX (ID) FROM BackgroundChecks WHERE BC.EmployeeID = E.ID) AS [Background Check],
		(SELECT 
					CAST(DATEDIFF (Day, DateCreated, sDateSubmitted) AS VARCHAR) 
				FROM SuitabilityReport 
				WHERE ID = CASE WHEN EC.ID IS NULL
									THEN (SELECT MAX (ID) FROM SuitabilityReport WHERE sEmployeeID = E.ID)
								ELSE (SELECT MAX (ID) FROM SuitabilityReport WHERE ChecklistID = EC.ID))
							END	AS [Suitability],
		(SELECT 
					CAST(DATEDIFF (Day, DateCreated, DateSubmitted) AS VARCHAR)
				FROM NORs 
				WHERE ID = CASE WHEN EC.ID IS NULL
									THEN (SELECT MAX (ID) FROM NORs WHERE EmployeeID = E.ID)
								ELSE (SELECT MAX (ID) FROM NORs WHERE ChecklistID = EC.ID)) 
							END AS [NOR],
		(SELECT 
					CAST(DATEDIFF (Day, DateCreated, DateSubmitted) AS VARCHAR) 
				FROM NOI 
				WHERE ID = CASE WHEN EC.ID IS NULL 
								THEN (SELECT MAX (ID) FROM NOI WHERE EmployeeID = E.ID)
							ELSE (SELECT MAX (ID) FROM NOI WHERE ChecklistID = EC.ID)) 
							END AS [NOI]
	FROM Database.dbo.employees E
	LEFT JOIN EmployeeChecklists EC 
		ON E.ID = EC.cEmployeeID
	LEFT JOIN EmployeeTypes ET 
		ON E.etypeID = ET.ID
	LEFT JOIN Applications A 
		ON E.id = A.EmployeeID
	WHERE EC.ID IS NOT NULL
) 
t

WHERE T.[LicenseID] = @LicenseType 
  AND T.[DateCompleted] IS NOT NULL
  AND (@StartDate IS NOT NULL 
	AND @EndDate IS NOT NULL 
	AND T.[DateCompleted] BETWEEN @StartDate AND @EndDate)
  AND ([Application] IS NOT NULL
	OR [Background Check] IS NOT NULL
	OR [Suitability] IS NOT NULL
	OR [NOR] IS NOT NULL
	OR [NOI] IS NOT NULL)
