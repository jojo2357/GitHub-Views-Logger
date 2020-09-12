import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Scanner;

public class RepoRefiner {
    public static String CWD = System.getProperty("user.dir") + "\\";

    public static void main(String args[]) throws IOException {
        File mainFile = new File(CWD + "Repos.txt");
        Scanner rawDataCollecter = new Scanner(mainFile);
        ArrayList<String> repoNames = new ArrayList<String>();
        do{
            String lineIn = rawDataCollecter.nextLine();
            if (lineIn.contains("\"full_name\":"))
                repoNames.add(lineIn);
        }while (rawDataCollecter.hasNextLine());
        rawDataCollecter.close();
        FileWriter outputWriter = new FileWriter(mainFile);
        for (String str : repoNames){
            String[] holder = str.split(":");
            str = holder[1];
            holder = str.split("\"");
            str = holder[1];
            holder = str.split("/");
            outputWriter.append(holder[1] + "\n");
        }
        outputWriter.close();
    }
}
