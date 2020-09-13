package com.github.jojo2357.githubviewslogger;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Scanner;

public class GitHubDataParser {
    /**
     * parses the data and writes to the output file
     *
     * @param args the program arguments passed in
     */
    public static void main(String[] args) {
        // first argument is project name, second is clones or views
        if (args.length < 3) {
            throw new IllegalArgumentException("The project name and clones/views and calling dir is required!");
        }

        final String userDirectory = args[2];
        File inputFile = new File(userDirectory + args[0] + ".txt");
        File outputFile = new File(userDirectory + "ParsedData/" + args[1] + "/" + args[0] + ".csv");
        StringBuilder alreadyThere = new StringBuilder();// Stores all of the data that is already in the file that we are working in
        // just as a safeguard
        TimeStamp lastTimeStamp = null;// Last time stamp in the file, dont put any data in before this date

        FileWriter outputWriter = null;
        Scanner inputReader;
        try {
            inputReader = new Scanner(inputFile);
        } catch (FileNotFoundException exception) {
            throw new RuntimeException("No such file with the path " + inputFile.getAbsolutePath() + " exists!");
        }

        if (!outputFile.exists()) {
            try {
                //noinspection ResultOfMethodCallIgnored
                outputFile.createNewFile();
                outputWriter = new FileWriter(outputFile);
                outputWriter.write("Date, Total, Unique\n");
            } catch (IOException exception) {
                inputReader.close();
		exception.printStackTrace();
                throw new RuntimeException("Error making new output file");
            }
        } else {// now that it exists, we are going to take all of the data for safekeeping and
            // to prevent duping
            Scanner filePreserver;
            try {
                filePreserver = new Scanner(outputFile);
            } catch (FileNotFoundException exception) {
                throw new RuntimeException("Error reading from stored data");
            }
            String nextLine = filePreserver.nextLine(); // we need to read the first line since no matter what it will
            // be "Date, Total, Unique
            alreadyThere.append(nextLine);
            while (filePreserver.hasNextLine()) {
                nextLine = filePreserver.nextLine();
                alreadyThere.append("\n").append(nextLine);
                String[] holder = nextLine.split(",");
                lastTimeStamp = new TimeStamp(holder[0], holder[1], holder[2]);// we will just keep overwriting until we
                // stop and that will be the last time
                // stamp
            }
            filePreserver.close();
        }
        ArrayList<TimeStamp> timestamps = new ArrayList<>();
        while (inputReader.hasNextLine()) {// read every line that we got FROM GITHUB API (Effectively parsing it)
            String lineIn = inputReader.nextLine();
            if (lineIn.contains("\"timestamp\"")) {// if it has ""timestamp":"
                String views = inputReader.nextLine();// the format of the JSONs say that the next line WILL be
                // views/clones
                String uniques = inputReader.nextLine();// and the line after that in unique clones/views
                timestamps.add(new TimeStamp(lineIn, refine(views), refine(uniques)));// create timestamp and add to
                // list
            }
        } 
        Collections.sort(timestamps);// sort timestamps long ago > now
        try {
            if (outputWriter == null)
                outputWriter = new FileWriter(outputFile);
            if (alreadyThere.length() > 0)
                outputWriter.append(String.valueOf(alreadyThere)).append("\n");
            if (lastTimeStamp == null) {
                for (TimeStamp ts : timestamps) {
                    outputWriter.append(ts.toString()).append("\n");
                }
            } else {
                for (TimeStamp ts : timestamps) {
                    if (ts.compareTo(lastTimeStamp) > 0) {
                        outputWriter.append(ts.toString()).append("\n");
                    }
                }
            }
        } catch (IOException exception) {
            exception.printStackTrace();
        }
        try {
            if (outputWriter != null) outputWriter.close();
        } catch (IOException exception) {
            exception.printStackTrace();
        }
        inputReader.close();
        System.out.println(inputFile.delete());
    }

    /**
     * refines the views/unique views lines since they all are the same format
     *
     * @param viewsLines the views/unique views lines
     * @return the refined views/unique views lines
     */
    private static String refine(String viewsLines) {
        String[] holder = viewsLines.split(":");
        viewsLines = holder[1];
        holder = viewsLines.split(",");
        return holder[0];
    }
}
