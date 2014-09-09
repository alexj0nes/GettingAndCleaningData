###############################################################################################

## You should create one R script called run_analysis.R that does the following. 

  ## 1. Merges the training and the test sets to create one data set.
  ## 2. Extracts only the measurements on the mean and standard deviation for each measurement.
  ## 3. Uses descriptive activity names to name the activities in the data set
  ## 4. Appropriately labels the data set with descriptive variable names.
  ## 5. From the data set in step 4, creates a second, independent tidy data set with the 
  ##    average of each variable for each activity and each subject.

###############################################################################################

## load libraries
library(data.table)
library(tidyr)

## import the three train datasets
train_measurements = read.table("train/X_train.txt") ## import the train measurements
train_subject_id = read.table("train/subject_train.txt") ## import the train subject_ids
train_activity_id = read.table("train/Y_train.txt") ## import the train activity_ids

## combine the columns of the three train datasets
train_merged = cbind(train_subject_id, train_activity_id, train_measurements)

## import the three test datasets
test_measurements = read.table("test/X_test.txt") ## import the test measurements
test_subject_id = read.table("test/subject_test.txt") ## import the test subject_ids
test_activity_id = read.table("test/Y_test.txt") ## import the test activity_ids

## combine the columns of the three test datasets
test_merged = cbind(test_subject_id, test_activity_id, test_measurements)

## merge the train and test datasets
merged = rbind(train_merged, test_merged)

## label the columns in the merged dataset
measurement_names = read.table("features.txt") ## import measurement names dataset
measurement_names = measurement_names[,2] ## subset the measurement_names dataset to only include the labels themselves
measurement_names = as.character(measurement_names) ## convert the resulting factor to character

## label the columns in the merged dataset with descriptive variable names
colnames(merged) = c("subject_id","activity_id",measurement_names)

## import activity labels dataset and apply appropriate column names to the data frame
activity_labels = read.table("activity_labels.txt")
colnames(activity_labels) = c("activity_id", "activity_name")

## merge activity labels dataset onto merged dataset
merged = merge(merged, activity_labels, by="activity_id")

## extract only the measurements on the mean and standard deviation for each measurement
merged_subset = merged[,c("subject_id","activity_name",colnames(merged[,grepl("*mean()",colnames(merged))]),colnames(merged[,grepl("*std()",colnames(merged))]))]

## sorting dataset by subject_id & activity_name
merged_subset = arrange(merged_subset,subject_id,activity_name)

## converting dataset to data table for use with data.table package
merged_subset.DT = data.table(merged_subset)

## creating initial data table with means of each activity measurement by subject_id & activity_name
output = merged_subset.DT[, lapply(.SD,mean), by=c("subject_id","activity_name")]

## tidying output data table with the average of each activity measurement by subject_id & activity_name
output_tidy = gather(output, measurement, measurement_mean, -subject_id,-activity_name)

## outputting tidy data table
write.table(output_tidy, file = "alex_jones_getdata_007.txt", row.names=FALSE)
