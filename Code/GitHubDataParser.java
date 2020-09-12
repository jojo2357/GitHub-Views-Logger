import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Scanner;

public class GitHubDataParser {

    public static String CWD = System.getProperty("user.dir") + "\\";

    public static void main(String args[]) {
        assert (args.length >= 1);
        File inputFile = new File(CWD + args[0] + ".txt");
        File outputFile = new File(CWD + "ParsedData\\" + args[1] + "\\" + args[0] + ".csv");
        Scanner inputReader = null;
        try {
            inputReader = new Scanner(inputFile);
        } catch (FileNotFoundException e) {
            throw new RuntimeException("Im so bad");
        }
        TimeStamp lastTimeStamp = null;
        FileWriter outputWriter = null;
        String alreadyThere = "";
        if (!(outputFile).exists()) {
            try {
                outputFile.createNewFile();
                outputFile = new File(CWD + "ParsedData\\" + args[1] + "\\" + args[0] + ".csv");
                outputWriter = new FileWriter(outputFile);
                outputWriter.write("Date, Total, Unique\n");
            } catch (IOException e) {
            }
        } else {
            Scanner filePreserver = null;
            try {
                filePreserver = new Scanner(outputFile);
            } catch (FileNotFoundException e) {
            }
            do {
                alreadyThere += filePreserver.nextLine();
                if (filePreserver.hasNextLine())
                    alreadyThere += "\n";
            } while (filePreserver.hasNextLine());
            lastTimeStamp = getLastTimeStamp(outputFile);
        }
        if (lastTimeStamp == null) {
            ArrayList<TimeStamp> timestamps = new ArrayList<TimeStamp>();
            do {
                String lineIn = inputReader.nextLine();
                if (lineIn.contains("\"timestamp\"")) {
                    String views = inputReader.nextLine();
                    String uniques = inputReader.nextLine();
                    timestamps.add(new TimeStamp(lineIn, refine(views), refine(uniques)));
                }
            } while (inputReader.hasNextLine());
            Collections.sort(timestamps);
            try {
                if (outputWriter == null)
                    outputWriter = new FileWriter(outputFile);
                if (!alreadyThere.isEmpty())
                    outputWriter.append(alreadyThere + "\n");
                for (TimeStamp ts : timestamps)
                    outputWriter.append(ts.toString() + "\n");
            } catch (IOException e) {
                e.printStackTrace();
            }
        } else {
            ArrayList<TimeStamp> timestamps = new ArrayList<TimeStamp>();
            do {
                String lineIn = inputReader.nextLine();
                if (lineIn.contains("\"timestamp\"")) {
                    String views = inputReader.nextLine();
                    String uniques = inputReader.nextLine();
                    timestamps.add(new TimeStamp(lineIn, refine(views), refine(uniques)));
                }
            } while (inputReader.hasNextLine());
            Collections.sort(timestamps);
            try {
                if (outputWriter == null)
                    outputWriter = new FileWriter(outputFile);
                if (!alreadyThere.isEmpty())
                    outputWriter.append(alreadyThere + "\n");
                for (TimeStamp ts : timestamps) {
                    if (ts.compareTo(lastTimeStamp) > 0) {
                        outputWriter.append(ts.toString() + "\n");
                    }
                }
            } catch (IOException e) {

            }
        }
        try {
            outputWriter.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
	inputReader.close();
	System.out.println(
        inputFile.delete());
    }

    private static TimeStamp getLastTimeStamp(File file) {
        Scanner outputReader = null;
        try {
            outputReader = new Scanner(file);
        } catch (FileNotFoundException e) {
            throw new RuntimeException("File not found or smthn");
        }
        String lastLine = "";
        do {
            lastLine = outputReader.nextLine();
        } while (outputReader.hasNextLine());
        outputReader.close();
        if (lastLine.contentEquals("Date, Total, Unique"))
            return null;
        String[] holder = lastLine.split(",");
        return new TimeStamp(holder[0], holder[1], holder[2]);
    }

    private static String refine(String in) {
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
