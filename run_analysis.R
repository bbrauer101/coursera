library(dplyr)
library(tidyr)

##Load data sets
x_test<- read.table("X_test.txt")
y_test<- read.table("y_test.txt")
sub_test<- read.table("subject_test.txt")
x_train<- read.table("X_train.txt")
y_train<- read.table("y_train.txt")
sub_train<- read.table("subject_train.txt")
feat<- read.table("features.txt")
act<- read.table("activity_labels.txt")

##Combine Test and Train data sets.
data<- bind_rows(x_test, x_train)

##Add feat$V2 as column headings to data
names(data)<- c(as.character(feat$V2))

##Clean data column headings in respect to R Style Guide
names(data)<- tolower(names(data))

##Subset with variables that have Means and Stds
data<- data[,grep("mean|std", names(data))]

## Combine Subjects from Train and Test data sets
combined_sub<- bind_rows(sub_test, sub_train)

##Rename column heading from "V1" to "Subject" of combined_sub
combined_sub<- rename(combined_sub, subject=V1)

## Add combined_sub to data as a variable
sub_data<- bind_cols(combined_sub, data)

##Combine activity data sets and reclassify activities from numeric to activity labels
act_codes<- bind_rows(y_test, y_train)
act<- act[,"V2"] ## Take out integer column
act<- as.character(act) ## Reclassify act as character variable
act_codes<- as.numeric(unlist(act_codes)) ##Coerce to numeric
activities<- act[act_codes] ## Change codes to easy-to-read character strings
activities<- as.data.frame(activities)

##Combine act_easy to sub_data to complete the data set.
complete<- bind_cols(activities, sub_data)

##Clean Complete variables to make grouping and summarization possible.
names(complete)<- sub("()","",names(complete), fixed = TRUE)
names(complete)<- gsub("-","",names(complete), fixed = TRUE)

##Group by subject and activity.  Any operation will take place on a per subject and activity basis.
by_subact<- group_by(complete, subject, activities)

##Averages for each subject and activity per variable that contains either "mean" or "std".
avg<- summarize_each(by_subact, 
                     funs(mean),
                     contains("mean", ignore.case=TRUE),
                     contains("std", ignore.case=TRUE)
)
