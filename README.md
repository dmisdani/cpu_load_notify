cpu_load_notify
===============

A bash script to raise notifications (notify-osd), about the proceses that consume too much cpu time. (it helps proactively)

This script has Urgency levels. The urgency level is calculated with the cpu usage of a process.
Then, based on the urgency level,it sets the frequency of notifications. (We don't want it to spam us for something not so urgent)

e.g Let's say we have a 4 cores cpu, that means my total power is 100%*4=400%.  The process Y cpu usage is 1.00 (100%), that means  25% of the machines CPU
What is the check_limit: If a process reach the check limit, it worths to raise a notify. (I set the check_limit to 1/4 of the total CPU. in my case 4.0/4 =1.0 --->25%                                              
What is the urgency level? If the Y process uses 25% of my cpu , then the urgency level is calculated: 25/check_limit (check limit=25)  so the urgency level is 25/25= 1·
So you will get a notification every 900 seconds

example 2: Let's say a process cpu usage is 300%.    75/25 =3.2 == 3     so the urgency level is 3 , you will get notifications every 2 minutes!

I hope you like it, it was very helpful to me.

Chears
