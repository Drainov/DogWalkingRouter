set PSQL="C:\Program Files\PostgreSQL\14\bin\psql"
set PGPORT=5432
set PGHOST=localhost
set PGPASSWORD=#here your password
cd foot
%PSQL% -U postgres -d $Database name here$ -f "$filename of the sql file from osm2po$.sql"
pause