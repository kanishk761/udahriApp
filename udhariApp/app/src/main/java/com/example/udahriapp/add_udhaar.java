package com.example.udahriapp;

import android.content.ContentResolver;
import android.content.DialogInterface;
import android.content.Intent;
import android.database.Cursor;
import android.provider.ContactsContract;
import android.support.annotation.NonNull;
import android.support.v7.app.AlertDialog;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.widget.AdapterView;
import android.widget.EditText;
import android.widget.ListView;
import android.widget.SearchView;
import android.widget.Toast;

import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.ValueEventListener;

import java.util.ArrayList;

public class add_udhaar extends AppCompatActivity {

    private ListView contact_list;
    private ArrayList<phoneContact> contactList = new ArrayList<>();
    private secondArrayAdapter arrayAdapter;
    private static String[] PROJECTION = new String[]{
            ContactsContract.CommonDataKinds.Phone.CONTACT_ID,
            ContactsContract.Contacts.DISPLAY_NAME,
    };
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_add_udhaar);

        contact_list = (ListView)findViewById(R.id.contacts);

        loadContacts();

        contact_list.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {

                String phone_num = arrayAdapter.getItem(position).getContactPhone_number();
                final String C_phone = repair_number(phone_num);
                Log.d("phone e", phone_num);
                LayoutInflater inflater = LayoutInflater.from(add_udhaar.this);
                View promptsView = inflater.inflate(R.layout.prompts,null);

                AlertDialog.Builder alertDialogBuilder = new AlertDialog.Builder(add_udhaar.this);

                alertDialogBuilder.setView(promptsView);
                final EditText amount_input = (EditText)promptsView.findViewById(R.id.edit_amount);

                alertDialogBuilder
                        .setCancelable(false)
                        .setPositiveButton("OK",
                                new DialogInterface.OnClickListener() {
                                    @Override
                                    public void onClick(DialogInterface dialog, int which) {
                                        DatabaseReference databaseReference = FirebaseDatabase.getInstance().getReference("Contacts").child(C_phone);
                                        databaseReference.addListenerForSingleValueEvent(new ValueEventListener() {
                                            @Override
                                            public void onDataChange(@NonNull DataSnapshot dataSnapshot) {
                                                if(dataSnapshot.exists()){
                                                    final DatabaseReference checkExist = FirebaseDatabase.getInstance().getReference("Debt").child(C_phone).child(FirebaseAuth.getInstance().getCurrentUser().getPhoneNumber());    //FirebaseAuth.getInstance().getCurrentUser().getPhoneNumber()
                                                    checkExist.addListenerForSingleValueEvent(new ValueEventListener() {
                                                        @Override
                                                        public void onDataChange(@NonNull DataSnapshot dataSnapshot) {
                                                            if(amount_input.getText().toString().length()==0)
                                                            {
                                                                Toast.makeText(add_udhaar.this,"Enter a amount",Toast.LENGTH_SHORT).show();
                                                            }
                                                            else {
                                                                if (dataSnapshot.exists()) {
                                                                    String prvAmount = dataSnapshot.getValue().toString();
                                                                    int totalAmount = Integer.parseInt(prvAmount) + Integer.parseInt(amount_input.getText().toString());
                                                                    checkExist.setValue(Integer.toString(totalAmount));

                                                                } else
                                                                    checkExist.setValue(amount_input.getText().toString());
                                                                Toast.makeText(add_udhaar.this,"Udhaar added successfully",Toast.LENGTH_SHORT).show();
                                                            }
                                                        }

                                                        @Override
                                                        public void onCancelled(@NonNull DatabaseError databaseError) {

                                                        }
                                                    });
                                                }
                                                else
                                                    Toast.makeText(add_udhaar.this,"Contact not registered",Toast.LENGTH_SHORT).show();

                                            }

                                            @Override
                                            public void onCancelled(@NonNull DatabaseError databaseError) {

                                            }
                                        });
                                        dialog.cancel();
                                    }
                                })
                        .setNegativeButton("Cancel",
                                new DialogInterface.OnClickListener() {
                                    @Override
                                    public void onClick(DialogInterface dialog, int which) {
                                        dialog.cancel();
                                    }
                                });

                AlertDialog alertDialog = alertDialogBuilder.create();

                alertDialog.show();

            }
        });
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        MenuInflater menuInflater = getMenuInflater();
        menuInflater.inflate(R.menu.menu_contacts,menu);
        MenuItem search_item = menu.findItem(R.id.app_bar_search);
        SearchView searchView = (SearchView)search_item.getActionView();

        searchView.setOnQueryTextListener(new SearchView.OnQueryTextListener() {
            @Override
            public boolean onQueryTextSubmit(String query) {
                return false;
            }

            @Override
            public boolean onQueryTextChange(String newText) {

                arrayAdapter.filter(newText);
                return false;
            }
        });
        return true;
    }

    private void loadContacts(){

       /* ContentResolver contentResolver = getContentResolver();
        Cursor cursor = contentResolver.query(ContactsContract.Contacts.CONTENT_URI, null, null, null, null);

        if(cursor.getCount()>0)//contacts exits
        {
            while(cursor.moveToNext())//iterate through contacts
            {
                String contact_id = cursor.getString(cursor.getColumnIndex(ContactsContract.Contacts._ID));//get id of contact
                String name = cursor.getString(cursor.getColumnIndex(ContactsContract.Contacts.DISPLAY_NAME));//get name of contact
                Log.d("name", name);
                int hasPhoneNumber = Integer.parseInt(cursor.getString(cursor.getColumnIndex(ContactsContract.Contacts.HAS_PHONE_NUMBER)));
                if(hasPhoneNumber>0)//check if contact has phone number
                {
                    Cursor phoneCursor = contentResolver.query(
                            ContactsContract.CommonDataKinds.Phone.CONTENT_URI
                            , null
                            , ContactsContract.CommonDataKinds.Phone.CONTACT_ID + " = ?"
                            , new String[]{contact_id}
                            , null);
                    if(phoneCursor.moveToNext())
                    {
                        String PhoneNumber = phoneCursor.getString(phoneCursor.getColumnIndex(ContactsContract.CommonDataKinds.Phone.NUMBER));

                        phoneContact addContact = new phoneContact(name,PhoneNumber);
                        contactList.add(addContact);

                    }

                    phoneCursor.close();

                }
            }
            //set adapter and all
            arrayAdapter = new secondArrayAdapter(add_udhaar.this,R.layout.contacts_adapter_layout,contactList);
            contact_list.setAdapter(arrayAdapter);
        }
        cursor.close();*/
        Cursor cursorPhones = getContentResolver().query(
                ContactsContract.CommonDataKinds.Phone.CONTENT_URI,
                new String[]{
                        ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME,
                        ContactsContract.CommonDataKinds.Phone.NUMBER,
                },
                ContactsContract.Contacts.HAS_PHONE_NUMBER + ">0 AND LENGTH(" + ContactsContract.CommonDataKinds.Phone.NUMBER + ")>0",
                null,
                ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME
        );
        while (cursorPhones.moveToNext()) {

            String displayName = cursorPhones.getString(cursorPhones.getColumnIndex(ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME));
            String number = cursorPhones.getString(cursorPhones.getColumnIndex(ContactsContract.CommonDataKinds.Phone.NUMBER));

            phoneContact addContact = new phoneContact(displayName,number);
            contactList.add(addContact);

        }
        cursorPhones.close();
        arrayAdapter = new secondArrayAdapter(add_udhaar.this,R.layout.contacts_adapter_layout,contactList);
        contact_list.setAdapter(arrayAdapter);
    }

    private String repair_number(String s){
        String mods="";
        if(!(s.charAt(0)=='+'&&s.charAt(1)=='9'&&s.charAt(2)=='1'))
            s="+91"+s;
        for(int i=0;i<s.length();i++)
        {
            if(s.charAt(i)==' '||s.charAt(i)==')'||s.charAt(i)=='('||s.charAt(i)=='-')
                continue;
            mods+=Character.toString(s.charAt(i));
        }
        return mods;
    }
}