set /p user=Enter username:
set /p password=Enter password:

set outputFile=latest.log

echo Username used: %username%>%outputFile%
echo Password used: %password%>>%outputFile%

REM username>>%outputFile%
REM for now, this is the login password. However, a PAT may work, havent figured that out yet>>%outputFile%

REM dont change the directory unless you change the java programs too>>%outputFile%
set directory=%~dp0>>%outputFile%
Pushd %directory%>>%outputFile%

REM this gets all the data that has to do with the user's repos, but we dont really care>>%outputFile%
curl "https://api.github.com/users/%user%/repos">%cd%\Repos.txt>>%outputFile%

REM repo finder extracts the repo names so that we can do something with it>>%outputFile%
if not exist "out" mkdir out>>%outputFile%
if not exist "ParsedData" mkdir ParsedData>>%outputFile%
if not exist "ParsedData\Views" mkdir ParsedData\Views>>%outputFile%
if not exist "ParsedData\Clones" mkdir ParsedData\Clones>>%outputFile%
javac -d out src\com\github\jojo2357\githubviewslogger\*.java>>%outputFile%
java -cp %cd%\out\ com.github.jojo2357.githubviewslogger.RepoRefiner>>%outputFile%

REM for each repo, we get taffic, and then parse that data>>%outputFile%
for /f "delims=" %%x in (Repos.txt) do (
curl "https://api.github.com/repos/%user%/%%x/traffic/views" -u %user%:%password%>%cd%\%%x.txt>>%outputFile%
java -cp %cd%\out\ com.github.jojo2357.githubviewslogger.GitHubDataParser %%x Views %directory%>>%outputFile%
curl "https://api.github.com/repos/%user%/%%x/traffic/clones" -u %user%:%password%>%cd%\%%x.txt>>%outputFile%
java -cp %cd%\out\ com.github.jojo2357.githubviewslogger.GitHubDataParser %%x Clones %directory%>>%outputFile%
)
exit /b 0