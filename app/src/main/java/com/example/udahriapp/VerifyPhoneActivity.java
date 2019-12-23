package com.example.udahriapp;

import android.content.Intent;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.v7.app.AppCompatActivity;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Toast;
import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.FirebaseException;
import com.google.firebase.auth.AuthResult;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.PhoneAuthCredential;
import com.google.firebase.auth.PhoneAuthProvider;
import java.util.concurrent.TimeUnit;

public class VerifyPhoneActivity extends AppCompatActivity {
    private Button signin;
    private EditText vcode;
    private FirebaseAuth mAuth;
    private String mVerificationId;
    private boolean OTPsent;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_verify_phone);

        OTPsent = false;
        mAuth = FirebaseAuth.getInstance();
        vcode = (EditText) findViewById(R.id.editText3);
        signin = (Button) findViewById(R.id.button2);

        String mobile = getIntent().getStringExtra("mobile");
        sendVerificationCode(mobile);

        signin.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if(OTPsent) {
                    String code = vcode.getText().toString();
                    verifyVerificationCode(code);
                }
                else
                {
                    Toast.makeText(VerifyPhoneActivity.this,"no OTP",Toast.LENGTH_LONG).show();
                }

            }
        });

    }
        private void sendVerificationCode(String mobile){
            PhoneAuthProvider.getInstance().verifyPhoneNumber("+91"+mobile,
                    60,
                    TimeUnit.SECONDS,
                    this,
                    mCallbacks);
            Toast.makeText(VerifyPhoneActivity.this,"OTP Sent Valid for 60 Seconds",Toast.LENGTH_LONG).show();


        }
        private PhoneAuthProvider.OnVerificationStateChangedCallbacks mCallbacks =new PhoneAuthProvider.OnVerificationStateChangedCallbacks() {
            @Override
            public void onVerificationCompleted(PhoneAuthCredential phoneAuthCredential) {
                String code=phoneAuthCredential.getSmsCode();
                if(code!=null)
                {
                    vcode.setText(code);
                    verifyVerificationCode(code);
                }
            }

            @Override
            public void onVerificationFailed(FirebaseException e) {

                Toast.makeText(VerifyPhoneActivity.this,"Failed to send OTP (check your internet) ",Toast.LENGTH_LONG).show();
                //disable the sign in button
            }
            @Override
            public void onCodeSent(String verificationId,PhoneAuthProvider.ForceResendingToken token){

                mVerificationId=verificationId;
                OTPsent = true;

            }
        };
        private void verifyVerificationCode(String code)
        {
            //creating the credential
            PhoneAuthCredential credential = PhoneAuthProvider.getCredential(mVerificationId, code);
            signInWithPhoneAuthCredential(credential);
        }
        private void signInWithPhoneAuthCredential(PhoneAuthCredential credential)
        {
            mAuth.signInWithCredential(credential)
                    .addOnCompleteListener(VerifyPhoneActivity.this, new OnCompleteListener<AuthResult>() {
                        @Override
                        public void onComplete(@NonNull Task<AuthResult> task) {
                            if (task.isSuccessful()) {
                                //verification successful we will start the profile activity
                                Intent intent = new Intent(VerifyPhoneActivity.this, ProfileActivity.class);
                                intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
                                String phone=getIntent().getStringExtra("mobile");
                                intent.putExtra("number",phone);
                                startActivity(intent);
                                finish();

                            } else {
                                Toast.makeText(VerifyPhoneActivity.this,"Invalid Code entered",Toast.LENGTH_LONG).show();
                                vcode.setText("");

                            }
                        }
                    });
        }
}