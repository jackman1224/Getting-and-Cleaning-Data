#Download files

fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./Dataset.zip")

unzip(zipfile="./Dataset.zip",exdir="./")

path <- file.path("./" , "UCI HAR Dataset")
files<-list.files(path, recursive=TRUE)

#Pull data files into a table

df_activity_test <- read.table(file.path(path, "test", "y_test.txt"), header = FALSE)
df_activity_train <- read.table(file.path(path, "train", "y_train.txt"), header = FALSE)

df_subject_test <- read.table(file.path(path, "test", "subject_test.txt"), header = FALSE)
df_subject_train <- read.table(file.path(path, "train", "subject_train.txt"), header = FALSE)

df_features_test <- read.table(file.path(path, "test", "X_test.txt"), header = FALSE)
df_features_train <- read.table(file.path(path, "train", "X_train.txt"), header = FALSE)

#Combine files based on category

subject <- rbind(df_subject_test,df_subject_train)
activity <- rbind(df_activity_test, df_activity_train)
features <- rbind(df_features_test,df_features_train)


#Add labels and remove columns that don't measure mean or standard deviation

names(subject) <- c("subject")
names(activity) <- c("activity")
feature_names <- read.table(file.path(path, "features.txt"))
names(features) <- feature_names$V2
initial_comb <- cbind(subject,activity)
df <- cbind(features,initial_comb)
col_mean_std <- grep(".*Mean.*|.*Std.*", names(df), ignore.case = TRUE)
req_columns <- c(col_mean_std, 562, 563)
new_df <- df[,req_columns]
colnames(new_df)[88] <- "activity"
levels(new_df$activity) <- c("WALKING","WALKING_UPSTAIRS","WALKING_DOWNSTAIRS","SITTING","STANDING","LAYING")

activity_labels <- read.table(file.path(path, "activity_labels.txt"))

names(new_df)<-gsub("^t", "time", names(new_df))
names(new_df)<-gsub("^f", "frequency", names(new_df))
names(new_df)<-gsub("Acc", "Accelerometer", names(new_df))
names(new_df)<-gsub("Gyro", "Gyroscope", names(new_df))
names(new_df)<-gsub("Mag", "Magnitude", names(new_df))
names(new_df)<-gsub("BodyBody", "Body", names(new_df))

#Aggregate data and write file

Data <- aggregate(. ~ subject + activity,new_df,mean)
Data <- arrange(Data,subject,activity)
write.table(Data,file = "tidydata.txt",row.names = FALSE)