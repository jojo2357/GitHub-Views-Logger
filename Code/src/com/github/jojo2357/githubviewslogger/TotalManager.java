package com.github.jojo2357.githubviewslogger;

import java.io.*;

class TotalManager{
	private static File viewFile;
	private static File cloneFile;
	private static FileWriter viewWriter;
	private static FileWriter cloneWriter;

	//erase old files, prepare for new ones
	public static void clearAndPrepare() throws IOException{
		viewFile = new File(System.getProperty("user.dir") + "/ParsedData/viewTotals.csv");
		cloneFile = new File(System.getProperty("user.dir") + "/ParsedData/cloneTotals.csv");
		viewWriter = new FileWriter(viewFile);
		cloneWriter = new FileWriter(cloneFile);
		viewWriter.append("Repo, total, unique\n");
		cloneWriter.append("Repo, total, unique\n");
		viewWriter.close();
		cloneWriter.close();
	}

	/*
	  purpose: formats and appends data to corresponding output file

	  @param reponame, Views or Clones AS String, total amount views/clones, 
	  total amount of unique viewers/cloners
	*/
	public static void append(String repo, String viewsOrClones, int views, int uniques) throws IOException{
		PrintWriter out;
		if (viewsOrClones.equals("Views")){ //only difference is which writer to use
    			out = new PrintWriter(new BufferedWriter(new FileWriter(System.getProperty("user.dir") + "/ParsedData/viewTotals.csv", true)));
		}else{
    			out = new PrintWriter(new BufferedWriter(new FileWriter(System.getProperty("user.dir") + "/ParsedData/cloneTotals.csv", true)));
		}
		out.println(repo + ": , " + views + ", " + uniques);
		out.close();
	}
}