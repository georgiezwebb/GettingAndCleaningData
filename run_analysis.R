library(dplyr)
library(reshape2)
library(readr)

colNames <- read.table("UCI HAR Dataset/features.txt",header = FALSE)

# remove first coulumn of names
colNames <- colNames["V2"]

# variable names to lower case:
colNames <- tolower(colNames$V2)

# remove brackets and dashes
colNames <- gsub("\\(|\\)", "", colNames)
colNames <- gsub("-", "", colNames)

#read in test data, training data and activity labels
subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt")
X_test <- read.table("UCI HAR Dataset/test/X_test.txt", col.names = colNames)
y_test <- read.table("UCI HAR Dataset/test/y_test.txt")


subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt")
X_train <- read.table("UCI HAR Dataset/train/X_train.txt", col.names = colNames)
y_train <- read.table("UCI HAR Dataset/train/y_train.txt")

activity_labels <- read.table("UCI HAR Dataset/activity_labels.txt")

#better names 
names(y_test) <- "activity"
names(y_train) <- "activity"
names(subject_test) <- "subject"
names(subject_train) <- "subject"

#combine test data and training data columns to one dataframe for test and one for training
test <- cbind(subject_test, X_test, y_test)
train <- cbind(subject_train, X_train, y_train)

#merge the test and training data
merged <- rbind(test,train)

#find columns extracting measurements on mean and standard deviation, retain activty and subject column. Drop the rest of the dataframe
means <- grepl("mean|std|^activity$|^subject$", names(merged))
merged_set <- merged[,means]

#label activities with names, using activity_labels.txt
merged_set$activity <- factor(merged_set$activity,labels = as.character(activity_labels$V2))

#reshape the dataframe
melted_set <- melt(merged_set, id = c("subject", "activity"))

#cast molten dataframe with the average of each variable for each activity and each subject
final_tidy <- dcast(melted_set, subject+activity ~ variable, mean)

#write final dataframe
write.table(final_tidy, "final_tidy.txt", row.names=FALSE)
