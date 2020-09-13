# Github Views Logger  
Uses java 8.
This is a mix of java and batch scripting that gets pertinent data from a user's repos and stores them.   
It is set up to get and store a day-by-day count of views and clones that does not simply go away after 24 hours.  
I'm not a superhero that can retrieve data that is more than 2 weeks old unless it has already been stored by the program, then it merely keeps going from the first time logging started.  

## Startup Guide:  
* Install Java 8  
### Windows:
* run `run_github_traffic_logger.bat` in the cmd using `run_github_traffic_logger` or by double clicking it  
* type in your username and password when asked    
* profit  
### Mac/Linux:
* make `run_github_traffic_logger` executable using `chmod +x run_github_traffic_logger`  
* run `run_github_traffic_logger` in the terminal using `./run_github_traffic_logger`
* type in your username and password when asked    
* profit  

### Optional:  
#### Windows:
you can set up a task in task scheduler to run the bat file once a week (or more or less often, whatever) and you will not have to touch it ever, just watch as the data collects up.  

## Notes:  
Github will be changing their api to no longer accept username+password.   
This means you will need to create an API key for this in May 2021.  
I do not know enough on the matter atm to fix it or anything so I will update this repo when I have more information.  
In the meantime, enjoy your data logger!  

along with that, I hope to create a data parser to combine views and clones from all repos into one .csv file, thus making graphs and charts much easier. 
(im no pro at scripting + excel so if anyone knows a way i can make it into a .xlsx or whatever it is, please reach out to me)

I chose not to include .class files in this upload because they frequently don't work properly because my JDK is a few years old and that stuff aint backwards or forwards compatible at this point.   
Also, as a good internet citizen, I try to spread precompiled files as infrequently as possible. Moreover, if you are interested in this, I sure home you have the knowhow to compile 2 files.  