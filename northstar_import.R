# load_libraries ----------------------------------------------------------

library(readr) #importing csv files
library(dplyr) #general analysis 
library(ggplot2) #making charts
library(lubridate) #date functions
library(reshape2) #use this for melt function to create one record for each team
library(tidyr)
library(janitor) #use this for doing crosstabs
library(scales) #needed for stacked bar chart axis labels
library(knitr) #needed for making tables in markdown page
#library(car)
library(aws.s3)
library(htmltools)#this is needed for Rstudio to display kable and other html code
library(rmarkdown)
library(readxl)
library(DT) #needed for making  searchable sortable data tble
library(kableExtra)
library(ggthemes)
library(waffle)
library(readxl)
library(RMySQL)


# import_data -------------------------------------------------------------

#UPDATE RANGES

#UPDATE FILE NAMES

#

thisyear <-  '17-18'



schools_identified <-  read_excel("./data/2018 North Star Accountability File.xlsx", 
                                  sheet='Identified Schools', 
                                  range="a7:ae925")

colnames(schools_identified) <-  c('id_year','district_number','district_type','district_name','school_number',
                                   'school_name','school_type','school_classification','titleI','level_support',
                                   'reason_identification','student_group','support','reason','group','stage1_math_achieve',
                                   'stage1_match_ach_ID','stage1_reading_achieve','stage1_reading_ach_ID','stage1_ELP_prog',
                                   'stage1_elp_prog_ID','stage2_math_progress','stage2_math_prog_ID','stage2_reading_progress',
                                   'stage2_reading_prog_ID','stage2_fouryr_grad','stage2_fouryr_grad_ID','stage2_sevenyr_grad',
                                   'stage2_sevenyr_grad_ID','stage3_cons_att','stage3_cons_att_ID')                                  
                                  

districts_identified <-  read_excel("./data/2018 North Star Accountability File.xlsx", 
                                    sheet='Identified Districts', 
                                    range="a4:t54")

colnames(districts_identified) <-  c('id_year','district_number','district_type','district_name',
                                     'stage1_math_achieve','stage1_match_ach_ID','stage1_reading_achieve',
                                     'stage1_reading_ach_ID','stage1_ELP_prog','stage1_elp_prog_ID',
                                     'stage2_math_progress','stage2_math_prog_ID','stage2_reading_progress',
                                     'stage2_reading_prog_ID','stage2_fouryr_grad','stage2_fouryr_grad_ID',
                                     'stage2_sevenyr_grad','stage2_sevenyr_grad_ID','stage3_cons_att','stage3_cons_att_ID')                                  

all_schools <-  read_excel("./data/2018 North Star Accountability File.xlsx", 
                           sheet='School', 
                           range="a5:ad49274")

colnames(all_schools) <-  c('id_year','district_number','district_type','district_name','school_number',
                            'school_type','school_classification','school_name','titleI','student_group','group',
                            'stage1_math_achieve','stage_1_math_achieve_count','stage1_reading_achieve',
                            'stage1_reading_achieve_count','stage1_ELP_prog','stage1_ELP_target','stage1_ELP_prog_count',
                            'stage2_math_progress','stage2_math_progress_pct','stage2_math_progress_count',
                            'stage2_reading_progress','stage2_reading_progress_pct','stage2_reading_progress_count',
                            'stage2_fouryr_grad','stage2_fouryr_grad_cohort','stage2_sevenyr_grad',
                            'stage2_sevenyr_grad_cohort','stage3_cons_att','stage3_cons_att_count')



all_districts <-  read_excel("./data/2018 North Star Accountability File.xlsx", 
                           sheet='District', 
                           range="a5:y14229")


colnames(all_districts) <-  c('id_year','district_number','district_type','district_name',
                            'student_group','group',
                            'stage1_math_achieve','stage_1_math_achieve_count','stage1_reading_achieve',
                            'stage1_reading_achieve_count','stage1_ELP_prog','stage1_ELP_target','stage1_ELP_prog_count',
                            'stage2_math_progress','stage2_math_progress_pct','stage2_math_progress_count',
                            'stage2_reading_progress','stage2_reading_progress_pct','stage2_reading_progress_count',
                            'stage2_fouryr_grad','stage2_fouryr_grad_cohort','stage2_sevenyr_grad',
                            'stage2_sevenyr_grad_cohort','stage3_cons_att','stage3_cons_att_count')


recognition <-  read_excel("./data/2018 North Star Accountability File.xlsx", 
                           sheet='Recognition-Tableau', 
                           range="a1:e1037")

# Pull schoollist and districtlist from server ----------------------------


con <- dbConnect(RMySQL::MySQL(), host = Sys.getenv("host"), dbname="Schools",user= Sys.getenv("userid"), password=Sys.getenv("pwd"))


data1 <- dbSendQuery(con, "select * from DistrictList")

#this turns that data into a R data frame
#the -1 means to pull all records; can change that to pull only a certain number
districtlist <- fetch(data1, n=-1)
dbClearResult(data1)

districtlist <-  districtlist %>% clean_names()


data2 <- dbSendQuery(con, "select * from schoollist")
schoollist <- fetch(data2, n=-1)
dbClearResult(data2)

schoollist <-  schoollist %>% clean_names()

data3 <-  dbSendQuery(con, "select schoolid, pctpoverty, povertycategory from enroll_special
                      where DataYear='17-18' and grade='All Grades'")
poverty <-  fetch(data3, n=-1)
dbClearResult(data3)

poverty <-  poverty %>% clean_names()

dbDisconnect(con)


# create ID numbers -------------------------------------------------------

all_districts <-  all_districts %>% 
  mutate(districtid=paste(district_number, district_type,"000", sep="-"))

districts_identified <-  districts_identified %>%
  mutate(districtid=paste(district_number, district_type,"000", sep="-"))

all_schools <-  all_schools %>%
  mutate(schoolid=paste(district_number, district_type, school_number, sep="-"))

schools_identified <-  schools_identified %>%
  mutate(schoolid=paste(district_number, district_type, school_number, sep="-"))




# Join to school list -----------------------------------------------------

#NEED TO TEST THIS PART

#grab just a few of the columns from schoollist


all_schools <-  left_join(all_schools, schoollist %>%
                            select(schoolid,  metro7_strib, 
                                   location_strib), by=c("schoolid"="schoolid"))



schools_identified <-  left_join(schools_identified, schoollist %>%
                                   select(schoolid, metro7_strib, location_strib), by=c("schoolid"="schoolid")) 


# Join to district list ---------------------------------------------------

#names(districtlist)

#grab just a few of the columns from districtlist
all_districts <- left_join(all_districts, districtlist %>%
                             select(1,3,10,11,12), by=c("districtid"="id_number"))

districts_identified <- left_join(districts_identified, districtlist %>% 
                                    select(1,3,10,11,12), by=c("districtid"="id_number"))




