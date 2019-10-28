package com.example.udahriapp;

import android.content.Context;
import android.util.Log;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.util.ArrayList;

public class FileManager {
    private static String File="History.dat";


    public static void AddToFile(ArrayList<historyItem> item, Context context)
    {
        try {
            FileOutputStream fos = context.openFileOutput(File, Context.MODE_PRIVATE);
            ObjectOutputStream outS = new ObjectOutputStream(fos);
            outS.writeObject(item);
            outS.close();
        }
        catch(FileNotFoundException e)
        {
            Log.d("FILE write", "File not found");
        }
        catch(IOException e) {
            Log.d("File write", "Error occured");
        }
    }
    public static ArrayList<historyItem> ReadFromFile(Context context)
    {
        ArrayList<historyItem> itemsList=null;
        try{
            FileInputStream fin = context.openFileInput(File);
            ObjectInputStream inS = new ObjectInputStream(fin);
            itemsList = (ArrayList<historyItem>) inS.readObject();
            return itemsList;
        }
        catch(FileNotFoundException e){
            Log.d("FILE read", "File not found");
        }
        catch(IOException e)
        {
            System.out.print("IOExceptions");
        }
        catch(ClassNotFoundException e) {
            System.out.print("Class not found");
        }
        itemsList = new ArrayList<>();
        return itemsList;
    }
}
