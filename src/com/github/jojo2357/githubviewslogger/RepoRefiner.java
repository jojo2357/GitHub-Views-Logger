package com.github.jojo2357.githubviewslogger;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Scanner;

public class RepoRefiner {
    /**
     * writes to the repos file the repository names
     *
     * @param args the program args that are passed in
     * @throws IOException when a problem with writing/reading from the repos file happens
     */
    public static void main(String[] args) throws IOException {
        String userDirectory = System.getProperty("user.dir") + "\\";
        File mainFile = new File(userDirectory + "Repos.txt");
        ArrayList<String> repoNames = new ArrayList<>();
        try (Scanner rawDataCollector = new Scanner(mainFile)) {
            do {
                String lineIn = rawDataCollector.nextLine();
                if (lineIn.contains("\"full_name\":")) repoNames.add(lineIn);
            } while (rawDataCollector.hasNextLine());
        }
        try (FileWriter outputWriter = new FileWriter(mainFile)) {
            for (String str : repoNames) {
                String[] holder = str.split(":");
                str = holder[1];
                holder = str.split("\"");
                str = holder[1];
                holder = str.split("/");
                outputWriter.append(holder[1]).append("\n");
            }
        }
    }
}
