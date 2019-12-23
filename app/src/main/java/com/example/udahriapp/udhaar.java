package com.example.udahriapp;

import android.Manifest;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.design.widget.FloatingActionButton;
import android.support.v4.app.ActivityCompat;
import android.support.v4.app.Fragment;
import android.os.Bundle;
import android.support.v4.content.ContextCompat;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.ListView;
import android.widget.ProgressBar;
import android.widget.SearchView;
import android.widget.TextView;

import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.ValueEventListener;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;

public class udhaar extends Fragment {

    private ListView listViewDebt;
    private TextView textView;
    private DatabaseReference databaseDebt;
    private DatabaseReference databaseName;
    private DatabaseReference databaseDebtRoot;
    private customArrayAdapter arrayAdapter;
    private FloatingActionButton addUdhaar;
    private ArrayList<contacts> debtMoney = new ArrayList<>();
    private String name;
    private ArrayList<String> money = new ArrayList<>();
    private ArrayList<String> phoneno = new ArrayList<>();
    private int i;
    private String [] listItems;
    private static final int CONTACTS_PERMISION_CODE = 79;
    private  ArrayList<historyItem> historyList;
    private ProgressBar progressBar;

    @Nullable
    @Override
    public View onCreateView( LayoutInflater inflater,  ViewGroup container,  Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.activity_udhaar, container, false);
        listViewDebt = view.findViewById(R.id.listview);
        textView=(TextView)view.findViewById(R.id.noItemText);
        addUdhaar = (FloatingActionButton)view.findViewById(R.id.floatingActionButton);
        progressBar = (ProgressBar) view.findViewById(R.id.progressBar2);
        arrayAdapter = new customArrayAdapter(getContext(), R.layout.adapter_view_layout, debtMoney);

        listViewDebt.setTextFilterEnabled(true);

        progressBar.setVisibility(View.VISIBLE);

        databaseDebtRoot = FirebaseDatabase.getInstance().getReference("Debt");
        databaseDebt = databaseDebtRoot.child(FirebaseAuth.getInstance().getCurrentUser().getPhoneNumber());//FirebaseAuth.getInstance().getCurrentUser().getPhoneNumber()

        boolean isConnected=false;
        ConnectivityManager CM = (ConnectivityManager) getActivity().getSystemService(Context.CONNECTIVITY_SERVICE);
        if(CM!=null) {
            NetworkInfo[] NI = CM.getAllNetworkInfo();
            for (NetworkInfo n : NI) {
                if (n!=null){
                    isConnected=isConnected||n.isConnected();
                }
            }
        }
        if(!isConnected) {
            progressBar.setVisibility(View.INVISIBLE);
            textView.setText("Check your net connection");
        }
        else
            getContent();

        listViewDebt.setOnItemLongClickListener(new AdapterView.OnItemLongClickListener() {
            @Override
            public boolean onItemLongClick(AdapterView<?> parent, View view, final int position, long id) {

               listItems = new String[]{"Cash","PayTM","Gpay","other"};
                AlertDialog.Builder mBuilder = new AlertDialog.Builder(getActivity());
                mBuilder.setTitle("Paid via")
                        .setSingleChoiceItems(listItems, -1, new DialogInterface.OnClickListener() {
                            @Override
                            public void onClick(DialogInterface dialog, int which) {
                                contacts get=debtMoney.remove(position);
                                arrayAdapter.notifyDataSetChanged();

                                historyList = FileManager.ReadFromFile(getContext());

                                historyItem hi = new historyItem(get.getName(),get.getAmount(),getDate(),listItems[which]);
                                historyList.add(hi);

                                FileManager.AddToFile(historyList,getContext());

                                databaseDebt.child(get.getPhone_number()).removeValue();
                                dialog.dismiss();
                            }
                        });

                AlertDialog mDialog = mBuilder.create();
                mDialog.show();
                return false;
            }
        });


        addUdhaar.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if(ContextCompat.checkSelfPermission(getActivity(),
                        Manifest.permission.READ_CONTACTS) == PackageManager.PERMISSION_GRANTED){
                    Intent intent = new Intent(getActivity(),add_udhaar.class);
                    startActivity(intent);
                }
                else {
                    ActivityCompat.requestPermissions(getActivity(), new String[]{Manifest.permission.READ_CONTACTS},
                            CONTACTS_PERMISION_CODE);
                }
            }
        });

        return view;
    }

    @Override
    public void onCreateOptionsMenu(Menu menu, MenuInflater inflater) {
        MenuInflater menuInflater = getActivity().getMenuInflater();
        menuInflater.inflate(R.menu.main_menu,menu);
        MenuItem search_item = menu.findItem(R.id.app_bar_search);
        SearchView searchView = (SearchView)search_item.getActionView();

        searchView.setOnQueryTextListener(new SearchView.OnQueryTextListener() {
            @Override
            public boolean onQueryTextSubmit(String query) {
                return false;
            }

            @Override
            public boolean onQueryTextChange(String newText) {

                arrayAdapter.getFilter().filter(newText);
                return false;
            }
        });
    }


    private void getContent() {
        databaseDebt.addValueEventListener(new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot dataSnapshot) {
                if(!dataSnapshot.exists()) {
                    textView.setText("nothing to show");
                    progressBar.setVisibility(View.INVISIBLE);
                }
                else
                    textView.setText("");
                String temp_phone;
                debtMoney.clear();
                money.clear();
                phoneno.clear();
                i = 0;

                for (DataSnapshot postSnapshot : dataSnapshot.getChildren()) {
                    money.add("Rs." + postSnapshot.getValue(String.class));
                    phoneno.add(postSnapshot.getKey());
                    temp_phone=postSnapshot.getKey();
                    databaseName = FirebaseDatabase.getInstance().getReference("Contacts").child(temp_phone).child("name");
                    databaseName.addValueEventListener(new ValueEventListener() {
                        @Override
                        public void onDataChange(@NonNull DataSnapshot dataSnapshot) {
                            name = dataSnapshot.getValue(String.class);
                            contacts c1 = new contacts(name, money.get(i),phoneno.get(i));
                            debtMoney.add(c1);
                            listViewDebt.setAdapter(arrayAdapter);
                            i++;
                            progressBar.setVisibility(View.INVISIBLE);
                        }

                        @Override
                        public void onCancelled(@NonNull DatabaseError databaseError) {

                        }
                    });

                }

            }

            @Override
            public void onCancelled(@NonNull DatabaseError databaseError) {

            }
        });

    }

    private String getDate()
    {
        Calendar calendar = Calendar.getInstance();
        SimpleDateFormat mdformat = new SimpleDateFormat("yyyy / MM / dd ");
        String strDate = mdformat.format(calendar.getTime());
        return strDate;
    }
}