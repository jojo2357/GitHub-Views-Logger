if "%1"=="" set /p user=Enter username:

REM this file has two uses. First, it runs chartmaker for the main program and secondly, it can be used to manually create charts

CALL :SetToCorrectDir
CALL :AffirmFolders
if "%1"=="" (
CALL :GetRepos %user%
CALL :RunForEachRepo
) else (
CALL :RunForKnownRepo %1
)

EXIT /B %ERRORLEVEL% 

:AffirmFolders
if not exist "Charts\Clones" mkdir Charts\Clones
if not exist "Charts\Views" mkdir Charts\Views
EXIT /B 0

:SetToCorrectDir
set directory=%~dp0
Pushd %directory%
EXIT /B 0 

:RunForKnownRepo
start "Chart Maker" ChartMaker.exe Views %~1
start "Chart Maker" ChartMaker.exe Clones %~1
EXIT /B 0

:GetRepos
CALL :CompileJavaFiles
CALL :GetAndParseRepos %~1
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

:RunForEachRepo
for /f "delims=" %%x in (Repos.txt) do (
CALL :RunForKnownRepo %%x
)
EXIT /B 0