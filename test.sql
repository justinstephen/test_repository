
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
		ISNULL((SELECT 
			        CAST(DATEDIFF(DAY, DateCreated, DateCompleted) AS VARCHAR)
				FROM Applications 
				WHERE ID = (SELECT MAX (ID) FROM Applications WHERE ChecklistID = EC.ID AND ChecklistID IS NOT NULL)), 'No Record') AS [Application],
		ISNULL((SELECT 
					CAST(DATEDIFF (Day, SubmittedAt, CompletedAt) AS VARCHAR)  
				FROM BackgroundChecks bc
				WHERE BC.ID = (SELECT MAX (BC.ID) FROM BackgroundChecks BC WHERE BC.EmployeeID = E.ID)), 'No Record') AS [Background Check],
		ISNULL((SELECT 
					CAST(DATEDIFF (Day, DateCreated, sDateSubmitted) AS VARCHAR) 
				FROM SuitabilityReport 
				WHERE ID = (SELECT MAX (ID) FROM SuitabilityReport WHERE ChecklistID = EC.ID AND ChecklistID IS NOT NULL)), 'No Record') AS [Suitability],
		ISNULL((SELECT 
					CAST(DATEDIFF (Day, DateCreated, DateSubmitted) AS VARCHAR)
				FROM NORs 
				WHERE ID = (SELECT MAX (ID) FROM NORs WHERE ChecklistID = EC.ID AND ChecklistID IS NOT NULL)), 'No Record') AS [NOR],
		ISNULL((SELECT 
					CAST(DATEDIFF (Day, DateCreated, DateSubmitted) AS VARCHAR) 
				FROM NOI 
				WHERE ID = (SELECT MAX (ID) FROM NOI WHERE ChecklistID = EC.ID AND ChecklistID IS NOT NULL)), 'No Record') AS [NOI]
	FROM Database.dbo.employees E
	LEFT JOIN EmployeeChecklists EC 
		ON E.ID = EC.cEmployeeID
	LEFT JOIN EmployeeTypes ET 
		ON E.etypeID = ET.ID
	LEFT JOIN Applications A 
		ON E.id = A.EmployeeID
	WHERE EC.ID IS NOT NULL
				
	UNION

	SELECT DISTINCT 
		E.eFirstName + ' ' + E.eLastName AS [Employee Name],
		E.ID AS [EmployeeID],
		E.eLicenseNumber AS [License Number],
		ET.EmployeeType AS [License Type],
		E.eTypeID AS [LicenseID],
		ISNULL(EC.Label,'Initial License') AS [Checklist],
		A.DateCompleted AS [DateCompleted],
		ISNULL((SELECT 
					CAST(DATEDIFF (Day, DateCreated, DateCompleted) AS VARCHAR) 
				FROM Applications 
				WHERE ID = (SELECT MAX (ID) FROM Applications WHERE EmployeeID = E.ID)), 'No Record') AS [Application],
		ISNULL((SELECT 
					CAST(DATEDIFF (Day, SubmittedAt, CompletedAt) AS VARCHAR) 
				FROM BackgroundChecks bc 
				WHERE ID = (SELECT MAX (ID) FROM BackgroundChecks WHERE BC.EmployeeID = E.ID)), 'No Record') AS [Background Check],
		ISNULL((SELECT 
					CAST(DATEDIFF (Day, DateCreated, sDateSubmitted) AS VARCHAR)
				FROM SuitabilityReport
				WHERE ID = (SELECT MAX (ID) ID FROM SuitabilityReport WHERE sEmployeeID = E.ID)), 'No Record') AS [Suitability],
		ISNULL((SELECT 
					CAST(DATEDIFF (Day, DateCreated, DateSubmitted) AS VARCHAR)
				FROM NORs
				WHERE ID = (SELECT MAX (ID) FROM NORs WHERE EmployeeID = E.ID)), 'No Record') AS [NOR],
		ISNULL((SELECT 
					CAST(DATEDIFF (Day, DateCreated, DateSubmitted) AS VARCHAR) 
				FROM NOI 
				WHERE ID = (SELECT MAX (ID) FROM NOI WHERE EmployeeID = E.ID)), 'No Record') AS [NOI]
	FROM Database.dbo.employees E
	LEFT JOIN EmployeeChecklists EC 
		ON E.ID = ec.cEmployeeID
	LEFT JOIN EmployeeTypes ET 
		ON E.etypeID = et.ID
	LEFT JOIN Applications A 
		ON E.id = A.EmployeeID
	WHERE EC.ID IS NULL
) 
t

WHERE T.[LicenseID] = @LicenseType 
  AND T.[DateCompleted] IS NOT NULL
  AND (@StartDate IS NOT NULL 
	AND @EndDate IS NOT NULL 
	AND T.[DateCompleted] BETWEEN @StartDate AND @EndDate)
  AND ([Application] <> 'No Record'
	OR [Background Check] <> 'No Record'
	OR [Suitability] <> 'No Record'
	OR [NOR] <> 'No Record'
	OR [NOI] <> 'No Record')
