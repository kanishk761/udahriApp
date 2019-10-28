package com.example.udahriapp;

public class contacts {
    private String name;
    private String amount;
    private String phone_number;

    public contacts(String name,String amount,String phone_number)
    {
        this.amount=amount;
        this.name=name;
        this.phone_number=phone_number;
    }
    public contacts()
    {
        this.amount=null;
        this.name=null;
        this.phone_number=null;
    }
    public String getName()
    {
        return name;
    }
    public String getAmount()
    {
        return amount;
    }
    public String getPhone_number() { return phone_number; }

    public void putName(String name)
    {
        this.name=name;
    }
    public void putAmount(String amount)
    {
        this.amount=amount;
    }
    public void putPhone_number(String phone_number){ this.phone_number=phone_number; }
}
