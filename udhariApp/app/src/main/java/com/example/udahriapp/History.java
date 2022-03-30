package com.example.udahriapp;

import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.ListView;
import java.util.ArrayList;

public class History extends Fragment {
    private ListView listHistory;
    private ArrayList<historyItem> historyItems = new ArrayList<>();
    private ArrayList<String> putHistoryItems = new ArrayList<>();
    private ArrayAdapter<String> adapter;

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.history,container,false);

        listHistory = (ListView) view.findViewById(R.id.historyList);

        FileManager fm = new FileManager();
        historyItems=fm.ReadFromFile(getContext());

        for(historyItem c :historyItems){
            putHistoryItems.add(c.toString());
        }
        adapter = new ArrayAdapter<>(getContext(), android.R.layout.simple_list_item_1,putHistoryItems);

        listHistory.setAdapter(adapter);

        return view;
    }
}