package com.example.udahriapp;

import android.content.Intent;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.support.design.widget.TabLayout;
import android.support.v4.view.ViewPager;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.widget.TextView;
import com.google.firebase.auth.FirebaseAuth;

import java.util.ArrayList;

public class Main2Activity extends AppCompatActivity {
     private ViewPager mViewPager;
     private SectionsPageAdapter mSectionsPageAdapter;
    private TextView textView;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main2);

        mViewPager=(ViewPager)findViewById(R.id.view_pager);
        mSectionsPageAdapter = new SectionsPageAdapter(getSupportFragmentManager());
        textView=(TextView)findViewById(R.id.noItemText);

         mSectionsPageAdapter.addFragment(new udhaar(), "Debt");
         mSectionsPageAdapter.addFragment(new History(), "History");

          mViewPager.setAdapter(mSectionsPageAdapter);

          TabLayout tabLayout = (TabLayout)findViewById(R.id.tabs);
          tabLayout.setupWithViewPager(mViewPager);
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        MenuInflater menuInflater = getMenuInflater();
        menuInflater.inflate(R.menu.main_menu,menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        if(item.getItemId()==R.id.refresh){
            finish();
            startActivity(new Intent(Main2Activity.this,ProfileActivity.class));
            return true;
        }
        else if(item.getItemId()==R.id.logout){
            FirebaseAuth.getInstance().signOut();
            startActivity(new Intent(Main2Activity.this, MainActivity.class)); //Go back to home page
            finish();
            return true;
        }
        else if(item.getItemId()==R.id.clear_history)
        {
            FileManager.AddToFile(new ArrayList<historyItem>(),this);
            finish();
            startActivity(new Intent(Main2Activity.this,ProfileActivity.class));
        }
        return super.onOptionsItemSelected(item);
    }
}
