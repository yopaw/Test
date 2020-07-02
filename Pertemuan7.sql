USE BluejackSkyline

CREATE FUNCTION GetDomain(@input VARCHAR(30))
RETURNS VARCHAR(30)
AS
	BEGIN
		DECLARE @domain VARCHAR(30)
		SET	@domain = @input
		SET @domain = 
		REPLACE(@domain, 
		SUBSTRING(@domain,1,CHARINDEX('@',@domain)),'')
		SET @domain = LEFT(@domain,CHARINDEX('.',@domain)-1)
		RETURN @domain
	END
SELECT
	[Name]  = UserFullname,
	[Domain] = dbo.GetDomain(UserEmail)
FROM [User]


CREATE TRIGGER TriggerUpdateUser
	ON [User]
AFTER UPDATE
AS
	IF UPDATE(UserName)
		PRINT 'Username Updated'

CREATE FUNCTION Fibo(@input int)
RETURNS INT
AS
BEGIN
	IF @input <= 1
		return @input
	return dbo.Fibo(@input-1) + dbo.Fibo(@input-2)
END

SELECT dbo.Fibo(3)

--7.	Create procedure named ‘GenerateReport’ that receive year as parameter to display transaction data that consist of Transaction ID (obtained from TransactionId), TransactionDate (obtained from TransactionDate in ‘dd Mon yyyy’ format), Buyer (obtained from Buyer’s full name), City (obtained from city’s name), and transaction detail with following format:

ALTER PROC GenerateReport @year INT
AS
	DECLARE reportCursor CURSOR
	FOR(
		SELECT 
			T.TransactionId,
			CONVERT(VARCHAR,T.TransactionDate,106),
			U.UserFullname,
			C.CityName
		FROM [User] U
		JOIN [Transaction] T
		ON U.UserId = T.UserBuyerId
		JOIN City C
		ON C.CityId = T.CityId
		WHERE YEAR(TransactionDate) = @year
	)
	DECLARE @transactionID CHAR(5), @transactionDate VARCHAR(30)
	DECLARE @buyer VARCHAR(50), @city VARCHAR(50)
	DECLARE @buildingName VARCHAR(50), @buildingTypeName VARCHAR(50)
	DECLARE @buildingPrice INT, @quantity INT, @price INT
	OPEN reportCursor
		FETCH NEXT FROM reportCursor INTO @transactionId,
		@transactionDate,@buyer,@city
		WHILE @@FETCH_STATUS = 0
			BEGIN
				PRINT '==================================================================================='
				PRINT 'Transaction ID : '+@transactionId
				PRINT 'Transaction Date : '+@transactionDate
				PRINT 'Buyer : '+@buyer
				PRINT 'City : '+@city
				DECLARE transactionCursor CURSOR
				FOR(
					SELECT 
						B.BuildingName,
						BT.BuildingTypeName,
						B.BuildingPrice,
						TD.Quantity,
						B.BuildingPrice * TD.Quantity
					FROM TransactionDetail TD
					JOIN Building B
					ON TD.BuildingId = B.BuildingId
					JOIN BuildingType BT
					ON BT.BuildingTypeId = B.BuildingTypeId
					WHERE TD.TransactionId = @transactionID
				)
				OPEN transactionCursor
				FETCH NEXT FROM transactionCursor
				INTO @buildingName,@buildingTypeName,@buildingPrice,
				@quantity,@price
					WHILE @@FETCH_STATUS = 0
						BEGIN
							PRINT '---------------------+---------------------+-----------------+------------+---------'
				PRINT  ' '+@buildingName +'     | '+@buildingTypeName+'  | '+CAST(@buildingPrice AS VARCHAR)+' | '+CAST(@quantity AS VARCHAR)+' | '+CAST(@price AS VARCHAR)+'  '
				FETCH NEXT FROM transactionCursor
				INTO @buildingName,@buildingTypeName,@buildingPrice,
				@quantity,@price
						END
				CLOSE transactionCursor
				DEALLOCATE transactionCursor
				
				FETCH NEXT FROM reportCursor INTO @transactionId,
		@transactionDate,@buyer,@city
			END
		PRINT '==================================================================================='
	CLOSE reportCursor
	DEALLOCATE reportCursor

EXEC GenerateReport 2012

GRANT insert,select on [user]  TO public

ALTER TRIGGER DDLTrigger
ON DATABASE
AFTER CREATE_TABLE,CREATE_INDEX,ALTER_TABLE
AS
	IF IS_MEMBER('db_owner') = 1	
		BEGIN
			PRINT 'You dont have a permission to CREATE TABLE'
			ROLLBACK
		END
