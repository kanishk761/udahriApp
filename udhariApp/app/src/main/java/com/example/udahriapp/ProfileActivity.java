package com.example.udahriapp;

import android.content.Intent;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Toast;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;

public class ProfileActivity extends AppCompatActivity {
    private EditText usrName;
    private Button btn;
    private DatabaseReference mRootRef = FirebaseDatabase.getInstance().getReference();
    private DatabaseReference mConditionRef;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_profile);
        final Intent intent = getIntent();

        if(intent.getStringExtra("number") == null) {
            Intent udhaar = new Intent(ProfileActivity.this,Main2Activity.class);
            startActivity(udhaar);
            finish();
        }

        usrName=(EditText)findViewById(R.id.editText2);
        btn=(Button)findViewById(R.id.button3);
        btn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                    if(usrName.getText().toString().length()==0)
                    {
                        Toast.makeText(ProfileActivity.this,"enter a name",Toast.LENGTH_LONG).show();
                    }
                    else {

                        String mobile = intent.getStringExtra("number");
                        mConditionRef = mRootRef.child("Contacts").child("+91"+mobile).child("name");
                        mConditionRef.setValue(usrName.getText().toString());
                        mobile="+91"+mobile;
                        //String number = FirebaseAuth.getInstance().getCurrentUser().getPhoneNumber();
                        Intent udhaar = new Intent(ProfileActivity.this,Main2Activity.class);
                        startActivity(udhaar);
                        finish();

                    }
            }
        });
    }
}
