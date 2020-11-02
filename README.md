# Github Views Logger  
Uses java 8, but other versions may be compatible.
This is a mix of java and batch scripting that gets pertinent data from a user's repos and stores them. Now uses qb64 to create charts from the data (optional)
It is set up to get and store a day-by-day count of views and clones that does not simply go away after 2 weeks.  
I'm not a superhero that can retrieve data that is more than 2 weeks old unless it has already been stored by the program, then it merely keeps going from the first time logging started. 
If the data output has every repo with 0 views and clones, check the end of the latest.log and see if you can fix it.

## Startup Guide:  
* Install Java 8  
* Generate a PAT in github with these steps:
	1. Access your personal GitHub settings by clicking on your user icon, and then click Settings.
	2. Go to developer settings, then Personal Access Tokens
	3. Generate a new Token and select repo
	4. Generate the token and save it somewhere safe.
	Note: This token can be used in place of a github password
### Windows:
* run `run_windows_github_traffic_logger.bat` the way you would run any executeable
* type in your username and PAT when asked
* program will ask if you want to make charts of the data. type Y if you want it to, and N if you do not
* the program will ask if you want to set up a scheduled task that will run with your username and password every week on sunday at 20:00. type Y if you want that, N if you do not
* profit  
### Mac/Linux:
* make `run_mac-linux_github_traffic_logger` executable using `chmod +x run_mac-linux_github_traffic_logger`  
* run `run_mac-linux_github_traffic_logger` in the terminal using `./run_mac-linux_github_traffic_logger`
* type in your username and password when asked    
* profit  

### Optional:  
#### Windows:
you can set up a task in task scheduler to run the bat file once a week (or more or less often, whatever) and you will not have to touch it ever, just watch as the data collects up. The windows bat file now has the capability to create it for you! 

If you don't see the prompt to create charts from your data, either ChartMaker.exe is missing (which is OK, I wouldn't trust precompiled .exe's either).

You can also delete the .exe if you are not a fan of sketchy .exes being run on your computer and just manually open the .csv's is excel and chuck em into a chart.

If you don't see the prompt to set up a scheduled task and you are running the Windows bat file, try running it without passing in parameters. (this is a feature so that something like a scheduled task won't get asked for a bunch of stuff and can run without any user input).

if you choose to run `run_windows_github_traffic_logger.bat` from cmd, you can do `run_windows_github_traffic_logger <username>, <password>` and you wont be prompted at all!

if you want to create charts from the data that has built up, all you have to do is run `create_charts.bat` and enter your username (enter username just to make sure that Repos.txt is correct)

## Notes:  
In order to get language analysis of all of your repos, create a file called `PrivateRepos.txt` and in there, put repos that are private in the same format they appear in `Repos.txt`

Github will be changing their api to no longer accept username+password.   
This means you will need to create an API key for this in May 2021.  
I do know enough on the matter atm to fix it! Just stick a PAT in place of .  
In the meantime, enjoy your data logger!  

along with that, I hope to create a data parser to combine views and clones from all repos into one .csv file, thus making graphs and charts much easier. 
(im no pro at scripting + excel so if anyone knows a way I can parse a .csv into a .xlsx and make charts and stuff, please reach out to me)

I chose not to include .class files in this upload because they frequently don't work properly because my JDK is a few years old and that stuff aint backwards or forwards compatible at this point. 
  
Also, as a good internet citizen, I try to spread precompiled files as infrequently as possible. Moreover, if you are interested in this, I sure home you have the knowhow to compile 2 files. 
Unfortunately, until I rewrite the chart maker in java or some other language, I have to precompile it because QB64 is super unstandard and I am not going to ship a copy of the 500+ MB ide just so the user can compile it themselves. (Unlike most languages, qb64's standard library comes with so much stuff including, but not limited to: graphics, file I/O, dynamic arrays, and more which makes it the prime language for making a cuctom chart maker in hours with what I already have.