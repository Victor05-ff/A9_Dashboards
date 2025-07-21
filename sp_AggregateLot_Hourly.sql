GO
CREATE OR ALTER PROCEDURE dbo.sp_InsertSimulatedMachineData
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @line INT = 1;
    DECLARE @component NVARCHAR(100);
    DECLARE @lotNumber NVARCHAR(50);
    DECLARE @now DATETIME;

    WHILE @line <= 4
    BEGIN
        DECLARE comp_cursor CURSOR FOR
            SELECT ComponentName FROM dbo.A9_LineComponents WHERE LineID = @line;
        OPEN comp_cursor;
        FETCH NEXT FROM comp_cursor INTO @component;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            SET @now = GETDATE();                              -- refresh per row
            DECLARE @hourBlock INT = DATEPART(HOUR, @now) / 3; -- 0‑7 blocks / day
            SET @lotNumber = 'LOT' + CONVERT(VARCHAR, @now, 112) + '_L' + CAST(@line AS VARCHAR) + '_' + CAST(@hourBlock AS VARCHAR);

            -- Randomised metrics (tuned for realistic ranges)
            DECLARE @totalCount INT  = FLOOR(RAND()*40 + 80);   -- 80‑120 parts
            DECLARE @yield      FLOAT = RAND()*0.3 + 0.5;       -- 50‑80 % good
            DECLARE @good       INT   = FLOOR(@totalCount * @yield);
            DECLARE @reject     INT   = @totalCount - @good;
            DECLARE @planned    INT   = 180;                    -- seconds per cycle
            DECLARE @runTime    INT   = FLOOR(@planned * (RAND()*0.2 + 0.4)); -- 40‑60 % plan
            DECLARE @down       INT   = FLOOR(RAND()*10);
            DECLARE @alarm      INT   = FLOOR(RAND()*5);
            DECLARE @wait       INT   = FLOOR(RAND()*5);
            DECLARE @reason     NVARCHAR(10) = 'R' + CAST(FLOOR(RAND()*5 + 1) AS VARCHAR);

            INSERT INTO dbo.A9_RawMachineData_Log (
                LotNumber, ComponentName, [Timestamp],
                GoodCount, RejectCount,
                RunTimeSeconds, PlannedTimeSeconds,
                DownTimeSeconds, AlarmTimeSeconds, WaitTimeSeconds,
                RejectReasonCode
            ) VALUES (
                @lotNumber, @component, @now,
                @good, @reject,
                @runTime, @planned,
                @down, @alarm, @wait,
                @reason
            );

            FETCH NEXT FROM comp_cursor INTO @component;
        END;
        CLOSE comp_cursor; DEALLOCATE comp_cursor;
        SET @line += 1;
    END;
END;
GO
