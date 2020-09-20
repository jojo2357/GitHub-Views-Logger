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
     * @param args the program arguments passed in {Repo name, Clone/Views, homedir}
     */
    public static void main(String[] args) {
        if (args.length < 3) {
            throw new IllegalArgumentException("The project name and clones/views and calling dir is required!");
        }
        ArrayList<TimeStamp> timestamps = new ArrayList<>();
        ArrayList<TimeStamp> alreadyFoundTimestamps = new ArrayList<>();

        final String userDirectory = args[2];
        File inputFile = new File(userDirectory + args[0] + ".txt");
        File outputFile = new File(userDirectory + "ParsedData/" + args[1] + "/" + args[0] + ".csv");

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
            String nextLine = filePreserver.nextLine(); 
            // we need to ignore the first line since no matter what it will be "Date, Total, Unique"
            while (filePreserver.hasNextLine()) {
                nextLine = filePreserver.nextLine();
                String[] holder = nextLine.split(",");
		alreadyFoundTimestamps.add(new TimeStamp(holder[0], holder[1], holder[2]));
            }
            filePreserver.close();
        }
        while (inputReader.hasNextLine()) {// read every line that we got FROM GITHUB API (Effectively parsing it)
            String lineIn = inputReader.nextLine();
            if (lineIn.contains("\"timestamp\"")) {// if it has ""timestamp":"
                String views = inputReader.nextLine();
                // the format of the JSONs say that the next line WILL be views/clones
                String uniques = inputReader.nextLine();// and the line after that in unique clones/views
                timestamps.add(new TimeStamp(lineIn, refine(views), refine(uniques)));
            }
        }
        Collections.sort(timestamps);// sort timestamps long ago -> now
	for (int foundIterator = alreadyFoundTimestamps.size() - 1; foundIterator >= 0; foundIterator--){
	    if (timestamps.size() > 0 && alreadyFoundTimestamps.get(foundIterator).compareTo(timestamps.get(0)) < 0){//if the timestap that we pulled from the file is from before the oldest new timestamp, we must add it to the list for reprinting
		timestamps.add(alreadyFoundTimestamps.get(foundIterator));
	    }
	}
	Collections.sort(timestamps);
        try {
            if (outputWriter == null)
                outputWriter = new FileWriter(outputFile);
            outputWriter.append("Date, Total, Unique\n");
            for (TimeStamp ts : timestamps) {
                outputWriter.append(ts.toString()).append("\n");
            }
        } catch (IOException exception) {
            exception.printStackTrace();
        }
        try {
            outputWriter.close();
        } catch (IOException exception) {
            exception.printStackTrace();
        }
        inputReader.close();
        inputFile.delete();
    }

    /**
     * refines the views/unique views lines since they all are the same format
     * by refine, we just mean get rid of the part of the string that isn't useable
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
