package com.github.jojo2357;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Scanner;

public class RepoRefiner {
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
