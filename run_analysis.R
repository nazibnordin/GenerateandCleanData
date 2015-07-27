# Download project data
library(data.table)

# 0. load test and training sets and the activities

fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl, destfile = "Dataset.zip", method = "libcurl")
unzip("Dataset.zip")

featureNames <- read.table("UCI HAR Dataset/features.txt")
activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt", header=FALSE)
testData <- read.table("./UCI HAR Dataset/test/X_test.txt",header=FALSE)
testData_act <- read.table("./UCI HAR Dataset/test/y_test.txt",header=FALSE)
testData_sub <- read.table("./UCI HAR Dataset/test/subject_test.txt",header=FALSE)
trainData <- read.table("./UCI HAR Dataset/train/X_train.txt",header=FALSE)
trainData_act <- read.table("./UCI HAR Dataset/train/y_train.txt",header=FALSE)
trainData_sub <- read.table("./UCI HAR Dataset/train/subject_train.txt",header=FALSE)

# Uses descriptive activity names to name the activities in the data set

activities <- read.table("./UCI HAR Dataset/activity_labels.txt",header=FALSE,colClasses="character")
testData_act$V1 <- factor(testData_act$V1,levels=activities$V1,labels=activities$V2)
trainData_act$V1 <- factor(trainData_act$V1,levels=activities$V1,labels=activities$V2)

# Appropriately labels the data set with descriptive activity names

features <- read.table("./UCI HAR Dataset/features.txt",header=FALSE,colClasses="character")
colnames(testData)<-features$V2
colnames(trainData)<-features$V2
colnames(testData_act)<-c("Activity")
colnames(trainData_act)<-c("Activity")
colnames(testData_sub)<-c("Subject")
colnames(trainData_sub)<-c("Subject")

# merge test and training sets into one data set, including the activities

testData<-cbind(testData,testData_act)
testData<-cbind(testData,testData_sub)
trainData<-cbind(trainData,trainData_act)
trainData<-cbind(trainData,trainData_sub)
bigData<-rbind(testData,trainData)

# extract only the measurements on the mean and standard deviation for each measurement

ColumnMeanSD <- grep(".*Mean.*|.*Std.*",names(bigData),ignore.case=TRUE)
requiredColumns <- c(ColumnMeanSD,562,563)
dim(bigData)
extractData <- bigData[,requiredColumns]
dim(extractData)

# Creates a second, independent tidy data set with the average of each variable for each activity and each subject.

extractData$Subject <- as.factor(extractData$Subject)
extractData <- data.table(extractData)
tidy <- aggregate(.~Subject + Activity, extractData, mean)
tidy <- tidy[order(tidy$Subject, tidy$Activity),]
write.table(tidy, file = "tidy.txt",sep = ",",row.names = FALSE)
