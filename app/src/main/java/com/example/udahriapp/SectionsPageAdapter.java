package com.example.udahriapp;

import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentPagerAdapter;

import java.util.ArrayList;
import java.util.List;

public class SectionsPageAdapter extends FragmentPagerAdapter {
    private List<Fragment> mFragmentList = new ArrayList<>();
    private List<String> mFragmentNameList = new ArrayList<>();
    public void addFragment(Fragment fragment, String name)
    {
        mFragmentList.add(fragment);
        mFragmentNameList.add(name);
    }

    public SectionsPageAdapter(FragmentManager fragmentManager)
    {
        super(fragmentManager);
    }
    @Override
    public String getPageTitle(int i)
    {
        return mFragmentNameList.get(i);
    }

    @Override
    public Fragment getItem(int i) {
        return mFragmentList.get(i);
    }

    @Override
    public int getCount() {
        return mFragmentList.size();
    }
}

