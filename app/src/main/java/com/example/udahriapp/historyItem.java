package com.example.udahriapp;

import java.io.Serializable;

public class historyItem implements Serializable {
    private String name;
    private String amount;
    private String date;
    private String paidVia;

    public historyItem(String name,String amount,String date,String paidVia)
    {
        this.amount=amount;
        this.name=name;
        this.date=date;
        this.paidVia=paidVia;
    }
    public historyItem()
    {
        this.amount=null;
        this.name=null;
        this.date=null;
        this.paidVia=null;
    }
    public String getName()
    {
        return name;
    }
    public String getAmount()
    {
        return amount;
    }
    public String getDate() {return date;}
    public String getPaidVia() {return paidVia;}

    public void putName(String name)
    {
        this.name=name;
    }
    public void putAmount(String amount)
    {
        this.amount=amount;
    }
    public void putDate(String date) {
        this.date=date;
    }
    public void putpaidVia(String paidVia)
    {
        this.paidVia=paidVia;
    }


    @Override
    public String toString() {
        return new StringBuffer("paid ").append(this.name).append(" ").append(this.amount).append(" on ").append(this.date).append(" paid via ").append(this.paidVia).toString();
    }
}
