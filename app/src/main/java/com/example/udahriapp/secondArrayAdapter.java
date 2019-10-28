package com.example.udahriapp;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.Filter;
import android.widget.TextView;

import java.util.ArrayList;
import java.util.Locale;

public class secondArrayAdapter extends ArrayAdapter<phoneContact> {

    private Context mContext;
    private int mResource;
    private ArrayList<phoneContact> modellist;
    private ArrayList<phoneContact> arrayList;

    public secondArrayAdapter(Context context, int resource, ArrayList<phoneContact> objects) {
        super(context, resource, objects);
        mContext=context;
        mResource=resource;
        this.modellist = objects;
        arrayList = new ArrayList<>();
        arrayList.addAll(modellist);
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        String name = getItem(position).getContactName();
        String PhoneNum = getItem(position).getContactPhone_number();

        LayoutInflater inflater=LayoutInflater.from(mContext);
        convertView=inflater.inflate(mResource,parent,false);

        TextView TVname = convertView.findViewById(R.id.name_contact);
        TextView TVphoneNum = convertView.findViewById(R.id.phone_contact);

        TVname.setText(name);
        TVphoneNum.setText(PhoneNum);

        return convertView;
    }

    //filter
    public void filter(String charText){
        charText = charText.toLowerCase(Locale.getDefault());
        modellist.clear();
        if (charText.length()==0){
            modellist.addAll(arrayList);
        }
        else {
            for (phoneContact model : arrayList){
                if (model.getContactName().toLowerCase(Locale.getDefault())
                        .contains(charText)){
                    modellist.add(model);
                }
            }
        }
        notifyDataSetChanged();
    }
}
