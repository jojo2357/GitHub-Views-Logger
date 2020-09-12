import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Scanner;

public class GitHubDataParser {

    public static String CWD = System.getProperty("user.dir") + "\\";

    public static void main(String args[]/* first argument is project name, second is clones or views */ ) {
        assert (args.length == 2);

        File inputFile = new File(CWD + args[0] + ".txt");
        File outputFile = new File(CWD + "ParsedData\\" + args[1] + "\\" + args[0] + ".csv");

        String alreadyThere = "";// Stores all of the data that is already in the file that we are working in
                                 // just as a safeguard
        TimeStamp lastTimeStamp = null;// Last time stamp in the file, dont put any data in before this date

        FileWriter outputWriter = null;
        Scanner inputReader = null;

        try {
            inputReader = new Scanner(inputFile);
        } catch (FileNotFoundException e) {
            throw new RuntimeException("Im so bad");
        }

        if (!(outputFile).exists()) {
            try {
                outputFile.createNewFile();
                outputFile = new File(CWD + "ParsedData\\" + args[1] + "\\" + args[0] + ".csv");
                outputWriter = new FileWriter(outputFile);
                outputWriter.write("Date, Total, Unique\n");
            } catch (IOException e) {
                inputReader.close();
                throw new RuntimeException("Error making new output file");
            }
        } else {// now that it exists, we are going to take all of the data for safekeeping and
                // to prevent duping
            Scanner filePreserver = null;
            try {
                filePreserver = new Scanner(outputFile);
            } catch (FileNotFoundException e) {
                throw new RuntimeException("Error reading from stored data");
            }
            String nextLine = filePreserver.nextLine(); // we need to read the first line since no matter what it will
                                                        // be "Date, Total, Unique
            alreadyThere += nextLine;
            while (filePreserver.hasNextLine()) {
                nextLine = filePreserver.nextLine();
                alreadyThere += "\n" + nextLine;
                String[] holder = nextLine.split(",");
                lastTimeStamp = new TimeStamp(holder[0], holder[1], holder[2]);// we will jsut keep overwriting until we
                                                                               // stop and that will be the last time
                                                                               // stamp
            }
            filePreserver.close();
        }
        ArrayList<TimeStamp> timestamps = new ArrayList<TimeStamp>();
        do {// read every line that we got FROM GITHUB API (Efectively parsing it)
            String lineIn = inputReader.nextLine();
            if (lineIn.contains("\"timestamp\"")) {// if it has ""timestamp":"
                String views = inputReader.nextLine();// the format of the jsons say that the next line WILL be
                                                      // views/clones
                String uniques = inputReader.nextLine();// and the line after that in unique clones/views
                timestamps.add(new TimeStamp(lineIn, refine(views), refine(uniques)));// create timestamp and add to
                                                                                      // list
            }
        } while (inputReader.hasNextLine());
        Collections.sort(timestamps);// sort timestamps long ago > now
        try {
            if (outputWriter == null)
                outputWriter = new FileWriter(outputFile);
            if (!alreadyThere.isEmpty())
                outputWriter.append(alreadyThere + "\n");
            if (lastTimeStamp == null) {
                for (TimeStamp ts : timestamps) {
                    outputWriter.append(ts.toString() + "\n");
                }
            } else {
                for (TimeStamp ts : timestamps) {
                    if (ts.compareTo(lastTimeStamp) > 0) {
                        outputWriter.append(ts.toString() + "\n");
                    }
                }
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
        try {
            outputWriter.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
        inputReader.close();
        System.out.println(inputFile.delete());
    }

    private static String refine(String in) {// refines the views/unique views lines since they all are the same format
        String[] holder = in.split(":");
        in = holder[1];
        holder = in.split(",");
        return holder[0];
    }

    private static class TimeStamp implements Comparable<TimeStamp> {
        private String timeStamp;
        public final int year;
        public final int month;
        public final int day;
        private String views;
        private String uniques;

        TimeStamp(String ts) {
            String[] holder = ts.split(":");
            if (holder.length > 1) {
                ts = holder[1];
                holder = ts.split("T");
                ts = holder[0];
                holder = ts.split("\"");
                ts = holder[1];
                this.timeStamp = ts;
            }
            holder = ts.split("-");
            year = Integer.parseInt(holder[0]);
            month = Integer.parseInt(holder[1]);
            day = Integer.parseInt(holder[2]);
        }

        TimeStamp(String ts, String views, String uniques) {
            this(ts);
            this.views = views;
            this.uniques = uniques;
        }

        public String toString() {
            return this.timeStamp + ", " + this.views + ", " + this.uniques;
        }

        @Override
        public int compareTo(GitHubDataParser.TimeStamp o) {
            if (this.year > o.year)
                return 1;
            if (this.year < o.year)
                return -1;
            if (this.month > o.month)
                return 1;
            if (this.month < o.month)
                return -1;
            if (this.day > o.day)
                return 1;
            if (this.day < o.day)
                return -1;
            return 0;
        }

    }
}
