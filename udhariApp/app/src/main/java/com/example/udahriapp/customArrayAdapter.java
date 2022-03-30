package com.example.udahriapp;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.TextView;
import java.util.ArrayList;

public class customArrayAdapter extends ArrayAdapter<contacts> {
    private Context mContext;
    private int mResource;

    public customArrayAdapter(Context context, int resource, ArrayList<contacts> objects) {
        super(context, resource, objects);
        mContext=context;
        mResource=resource;
    }

    @Override
    public View getView(int position,View convertView,ViewGroup parent) {
        String name=getItem(position).getName();
        String amount=getItem(position).getAmount();



        LayoutInflater inflater=LayoutInflater.from(mContext);
        convertView=inflater.inflate(mResource,parent,false);

        TextView tvname=(TextView)convertView.findViewById(R.id.textView);
        TextView tvamount=(TextView)convertView.findViewById(R.id.textView2);

        tvname.setText(name);
        tvamount.setText(amount);

        return convertView;
    }

}