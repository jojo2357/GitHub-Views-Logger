if "%1"=="" set /p user=Enter username:
if "%2"=="" set /p password=Enter password:
if "%1"=="" set /p generateCharts=Would you like to create charts as well? (Y/N):

set outputFile=latest.log
set archiveFolder=logs

echo Username used: %user%>%outputFile%
echo Password used: %password%>>%outputFile%

REM dont change the directory unless you change the java programs too>>%outputFile%

CALL :SetToCorrectDir>>%outputFile%

if "%1"=="" set /p createTask=Would you like to create a task that runs me every sunday at 20:00 with the username: %user% and %password% ? (Y/N) 

if "%createTask%"=="Y" SCHTASKS /CREATE /SC WEEKLY /D SUN /TN "GitHub views logger" /TR "%cd%/run_github_traffic_logger.bat %user%, %password%" /ST 20:00

CALL :AffirmFolders>>%outputFile%
CALL :CompileJavaFiles>>%outputFile%
CALL :GetAndParseRepos %user%>>%outputFile%
CALL :GetAndSaveAllRepoData %user%, %password%>>%outputFile%
if "%1"=="" if "%generateCharts%"=="Y" CALL :CreateCharts >>%outputFile%
CALL :ArchiveLastLog %outputFile%, %archiveFolder%

EXIT /B %ERRORLEVEL% 

:ArchiveLastLog
MOVE %cd%\%~1 %cd%\%~2\
CALL :GetTimestamp parsedTime
copy "%cd%\%~2\%~1" "%cd%\%~2\%parsedTime%.log"
EXIT /B 0

:GetTimestamp
set editedTime=%time%
set editedTime=%editedTime:.=_%
set editedTime=%editedTime::=;%
FOR /F %%A IN ('WMIC OS GET LocalDateTime ^| FINDSTR \.') DO @SET B=%%A
set %~1=%B:~0,4%-%B:~4,2%-%B:~6,2%,%editedTime%
EXIT /B 0

:SetToCorrectDir
set directory=%~dp0
Pushd %directory%
EXIT /B 0

:AffirmFolders
if not exist "Charts\Clones" mkdir Charts\Clones
if not exist "Charts\Views" mkdir Charts\Views
if not exist "logs" mkdir logs
if not exist "out" mkdir out
if not exist "ParsedData" mkdir ParsedData
if not exist "ParsedData\Views" mkdir ParsedData\Views
if not exist "ParsedData\Clones" mkdir ParsedData\Clones
EXIT /B 0

:CompileJavaFiles
javac -d out src\com\github\jojo2357\githubviewslogger\*.java
EXIT /B 0

:GetAndParseRepos
CALL :GetRepos %~1
CALL :ParseRepos
EXIT /B 0

:GetRepos
curl "https://api.github.com/users/%~1/repos">%cd%\Repos.txt
EXIT /B 0

:ParseRepos
java -cp %cd%\out\ com.github.jojo2357.githubviewslogger.RepoRefiner
EXIT /B 0

REM 1 = user, 2 = password
:GetAndSaveAllRepoData
for /f "delims=" %%x in (Repos.txt) do (
CALL :GetAndSaveRepoViews %%x, %~1, %~2
CALL :GetAndSaveRepoClones %%x, %~1, %~2
)
EXIT /B 0

:GetAndSaveRepoViews 
curl "https://api.github.com/repos/%~2/%~1/traffic/views" -u %~2:%~3>%cd%\%~1.txt
java -cp %cd%\out\ com.github.jojo2357.githubviewslogger.GitHubDataParser %~1 Views %cd%\
EXIT /B 0

:GetAndSaveRepoClones 
curl "https://api.github.com/repos/%~2/%~1/traffic/clones" -u %~2:%~3>%cd%\%~1.txt
java -cp %cd%\out\ com.github.jojo2357.githubviewslogger.GitHubDataParser %~1 Clones %cd%\
EXIT /B 0

:CreateCharts
for /f "delims=" %%x in (Repos.txt) do (
ChartMaker Views %%x
ChartMaker Clones %%x
)
EXIT /B 0