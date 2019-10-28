package com.example.udahriapp;

public class phoneContact {
    private String name;
    private String phone_number;

    public phoneContact(String name,String phone_number)
    {
        this.name=name;
        this.phone_number=phone_number;
    }

    public String getContactName(){
        return name;
    }
    public String getContactPhone_number(){
        return phone_number;
    }
}
