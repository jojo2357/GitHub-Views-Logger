package com.github.jojo2357.githubviewslogger;

import java.io.*;
import java.util.HashMap;

public class LanguageAverager {
    public static void main(String args[]) throws IOException {
        HashMap<String, Integer> languageCounts = new HashMap<String, Integer>();
        final String userDirectory = System.getProperty("user.dir") + "/";
        File mainFile = new File(userDirectory + "Repos.txt");
        FileReader mainReader = new FileReader(mainFile);
        char[] raw = new char[10000];
        mainReader.read(raw);
        String repos = new String(raw).trim();
        System.out.println(repos);
        for (String repo : repos.split("\n")) {
	    if (repo.equals(""))
		continue;
            FileReader reader = new FileReader(new File(userDirectory + repo + "_langs.txt"));
            raw = new char[10000];
            reader.read(raw);
            String rawData = new String(raw).trim();
            for (String str : rawData.split("[\n]")) {
		if (str.contains("Not Found"))
			break;
                if (str.contains(":"))
                    if (languageCounts.containsKey(str.split("[\"]")[1])) {
                        languageCounts.put(str.split("[\"]")[1], languageCounts.get(str.split("[\"]")[1]) + Integer.parseInt(str.split("[:]")[1].substring(1, str.split("[:]")[1].contains(",") ? str.split("[:]")[1].length() - 1 : str.split("[:]")[1].length())));
                    } else {
                        languageCounts.put(str.split("[\"]")[1], Integer.parseInt(str.split("[:]")[1].substring(1, str.split("[:]")[1].contains(",") ? str.split("[:]")[1].length() - 1 : str.split("[:]")[1].length())));
                    }
            }
            reader.close();
            new File(userDirectory + repo + "_langs.txt").delete();
        }
        mainReader.close();
        StringBuilder out = new StringBuilder("Language, Relative size");
        while (languageCounts.size() > 0) {
            int record = 0;
            String recordLang = "";
            for (String key : languageCounts.keySet()) {
                if (languageCounts.get(key) > record){
                    recordLang = key;
                    record = languageCounts.get(key);
                }
            }
            languageCounts.remove(recordLang);
            out.append("\n").append(recordLang).append(", ").append(record);
        }
        FileWriter outputStream = new FileWriter(new File(userDirectory + "language_totals.out"));
        outputStream.write(out.toString());
        System.out.println(out.toString());
        outputStream.close();
    }
}
