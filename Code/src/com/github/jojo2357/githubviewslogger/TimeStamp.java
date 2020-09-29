package com.github.jojo2357.githubviewslogger;

/**
 * a timestamp object which has day, month, and year fields
 * sorts in chronological order with oldest date going first
 */
public class TimeStamp implements Comparable<TimeStamp> {
    private String timeStamp;// the un-parsed timestamp. not used for anything but debugging
    private int year;
    private int month;
    private int day;
    private String views;
    private String uniques;

    /*
	timeStamp is the raw github data (signified by ':' in the data) passing in raw data
	from ParsedData csv's will not result in an error because nothing will happen

	@param: raw github data 
    */
    private TimeStamp(String timeStamp) {
	if (timeStamp.contains(":")){
            String[] holder = timeStamp.split(":");
            if (holder.length > 1) {
                timeStamp = holder[1];
                holder = timeStamp.split("T");
                timeStamp = holder[0];
                holder = timeStamp.split("\"");
                timeStamp = holder[1];
                this.timeStamp = timeStamp;
            }
            holder = timeStamp.split("-");
            year = Integer.parseInt(holder[0]);
            month = Integer.parseInt(holder[1]);
            day = Integer.parseInt(holder[2]);
	}
    }

    public int getViews(){
	return Integer.parseInt(this.views.trim());
    }

    public int getUniques(){
	return Integer.parseInt(this.uniques.trim());
    }

    /*
    * @param String containing the time stamp raw data, views/clones, unique viewers
    */
    public TimeStamp(String timeStamp, String views, String uniques) {
        this(timeStamp);
	if (!timeStamp.contains(":")){// only run this if the other constructor did not
            this.timeStamp = timeStamp;
            String[] holder = timeStamp.split("-");
            year = Integer.parseInt(holder[0]);
            month = Integer.parseInt(holder[1]);
            day = Integer.parseInt(holder[2]);
	}
        this.views = views;
        this.uniques = uniques;
    }

    //used in printing a time stamp to ParsedData csv
    @Override
    public String toString() {
        return timeStamp + ", " + views + ", " + uniques;
    }

    // in a.compareTo(b), 1 means a came after b, 0 means they are the same day
    @Override
    public int compareTo(TimeStamp timeStamp) {
        if (this.year > timeStamp.year) return 1;
        if (this.year < timeStamp.year) return -1;
        if (this.month > timeStamp.month) return 1;
        if (this.month < timeStamp.month) return -1;
        return Integer.compare(this.day, timeStamp.day);
    }
}
