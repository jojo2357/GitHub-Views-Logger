REM username
set user=""

REM for now, this is the login password. However, a PAT may work, havent figured that out yet
set password=""

REM dont change the directory unless you change the java programs too
set directory=%~dp0
Pushd %directory%

REM this gets all the data that has to do with the user's repos, but we dont really care
curl "https://api.github.com/users/%user%/repos">%cd%\Repos.txt

REM repo finder extracts the repo names so that we can do something with it
java RepoRefiner

REM for each repo, we get taffic, and then parse that data
for /f "delims=" %%x in (Repos.txt) do (
curl "https://api.github.com/repos/%user%/%%x/traffic/views" -u %user%:%password%>%cd%\%%x.txt
java GitHubDataParser %%x Views
curl "https://api.github.com/repos/%user%/%%x/traffic/clones" -u %user%:%password%>%cd%\%%x.txt
java GitHubDataParser %%x Clones
)
exit /b 0