# schools_NorthStar
MN Dept of Education data release on school accountability (North Star)

Data source: Minnesota Department of Education
Every two years MDE plans to release this data identifying schools that need additional help. It was released for the first time ever in 2018. This replaced old accountability systems (originally No Child Left Behind and later MMR). 

They provided it under an embargo in summer 2018, a few days before releasing the school test scores. We begged them to release the two files at the time, but they refused. 

This R project pulls the various data pieces from the Excel file that the state provides, then merges that with school and district information that I maintain on our mySQL server. When running this in the future, be sure to check the sheet names and ranges listed in the "northstar_import.R" script to make sure they are pulling the right chunks of data.  

The northstar_analysis.RMD file generates some tables that will be useful for the reporter working on the story, then spits out a csv file that can be shared with the reporter and/or used for online presentation. A lot of the code in there is not annotated and I'm pretty sure most of it was me and Erin Golden just making sense of the data. It will probably need to be overhauled when the next batch of data arrives in 2020.

Here's the story we published in 2018: http://www.startribune.com/minnesota-unveils-new-benchmarks-for-schools-identifies-485-for-additional-help/492046621/


