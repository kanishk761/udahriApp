package com.example.udahriapp;

import android.content.Intent;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Toast;

import com.google.firebase.auth.FirebaseAuth;

public class MainActivity extends AppCompatActivity {
    private EditText phone;
    private Button btn;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        FirebaseAuth auth=FirebaseAuth.getInstance();
        if(auth.getCurrentUser()!=null)
        {
            Intent intent=new Intent(MainActivity.this,ProfileActivity.class);
            startActivity(intent);
            finish();
        }
        phone=(EditText)findViewById(R.id.editText);
        btn=(Button)findViewById(R.id.button);
        btn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                String mobile=phone.getText().toString().trim();
                if(mobile.length()!=10)
                {
                    phone.requestFocus();
                    Toast.makeText(MainActivity.this,"enter correct phone",Toast.LENGTH_LONG).show();
                }
                else
                {
                   // Intent intent=new Intent(MainActivity.this,VerifyPhoneActivity.class);
                    //intent.putExtra("mobile",mobile);
                    //startActivity(intent);
                    Intent intent=new Intent(MainActivity.this,VerifyPhoneActivity.class);
                    intent.putExtra("mobile",mobile);
                    startActivity(intent);
                    finish();
                }
            }
        });
    }
}
