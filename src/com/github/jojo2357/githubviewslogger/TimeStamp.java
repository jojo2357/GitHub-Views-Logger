package com.github.jojo2357.githubviewslogger;

/**
 * a timestamp which has day, month, and year fields
 */
public class TimeStamp implements Comparable<TimeStamp> {
    private String timeStamp;
    private final int year;
    private final int month;
    private final int day;
    private String views;
    private String uniques;

    private TimeStamp(String timeStamp) {
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

    public TimeStamp(String timeStamp, String views, String uniques) {
        this(timeStamp);
        this.views = views;
        this.uniques = uniques;
    }

    @Override
    public String toString() {
        return timeStamp + ", " + views + ", " + uniques;
    }

    @Override
    public int compareTo(TimeStamp timeStamp) {
        if (this.year > timeStamp.year) return 1;
        if (this.year < timeStamp.year) return -1;
        if (this.month > timeStamp.month) return 1;
        if (this.month < timeStamp.month) return -1;
        return Integer.compare(this.day, timeStamp.day);
    }
}
