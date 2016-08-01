require(reshape2)
require(plyr)

##setting up directory to hold files
if(!dir.exists("data")) {dir.create("data")}

##variables for easy use later in downloading the files and manipulating where they go
fileurl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
filedestination <- "./data/analysisdat.zip"

##downloading the file if it does not already exist + unzipping file
if(!file.exists(filedestination))
{
        download.file(fileurl, filedestination, mode = "wb")
        unzip(filedestination, exdir = "./data")
}

##reading in activity labels data & features
activitylabels <- read.table("./data/UCI HAR Dataset/activity_labels.txt")
activitylabels[,2] <- as.character(activitylabels[,2])
features <- read.table("./data/UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])

##finding only data on means and standard deviation + cleaning up variable names
featurestoextract <- grep(".*mean.*|.*std.*", features[,2])
featurenames <- features[featurestoextract,2]
featurenames <- gsub("-mean", "Mean", featurenames)
featurenames <- gsub("-std", "Std", featurenames)
featurenames <- gsub("[-()]", "", featurenames)

##loading main data data sets test and train
test <- read.table("./data/UCI HAR Dataset/test/X_test.txt")[featurestoextract]
testactivities <- read.table("./data/UCI HAR Dataset/test/Y_test.txt")
testsubjects <- read.table("./data/UCI HAR Dataset/test/subject_test.txt")
test <- cbind(testsubjects, testactivities, test)

train <- read.table("./data/UCI HAR Dataset/train/X_train.txt")[featurestoextract]
trainactivities <- read.table("./data/UCI HAR Dataset/train/Y_train.txt")
trainsubjects <- read.table("./data/UCI HAR Dataset/train/subject_train.txt")
train <- cbind(trainsubjects, trainactivities, train)

##merge all the data
mergeddata <- rbind(test,train)
colnames(mergeddata) <- c("subject", "activity", featurenames)

##make activities and subjects factors
mergeddata$activity <- factor(mergeddata$activity, levels = activitylabels[,1], labels = activitylabels[,2])
mergeddata$subject <- as.factor(mergeddata$subject)
melteddata <- melt(mergeddata, id = c("subject", "activity"))
meandata <- dcast(melteddata, subject + activity ~ variable, mean)
write.table(meandata, "./data/tidy/mean.txt", row.names = FALSE, quote = FALSE)
