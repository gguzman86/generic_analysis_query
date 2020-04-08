WITH MOD_TABLE AS 
(
SELECT ID, event_date, to_char(event_date, 'Day') DOW, substr(line,-24,7) Location, Level
FROM data1.table1
WHERE event_date >= DATE '2020-01-01'
AND Level in ('Level1', 'Level2', 'Level3')
)
SELECT * FROM MOD_TABLE
WHERE Location in ('Location1', 'Location2');
