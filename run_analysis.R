# Load Packages and get the Data
library(data.table)
library(reshape2)
#OR: packages <- c("data.table", "reshape2")
#sapply(packages, require, character.only=TRUE, quietly=TRUE)
path <- getwd()
#url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
#download.file(url, file.path(path, "dataFiles.zip"))
#unzip(zipfile = "dataFiles.zip")

# Load activity labels + features
activityLabels <- fread(file.path(path, "UCI HAR Dataset/activity_labels.txt")
                        , col.names = c("classLabels", "activityName"))
features <- fread(file.path(path, "UCI HAR Dataset/features.txt")
                  , col.names = c("index", "featureNames"))
featuresWanted <- grep("(mean|std)\\(\\)", features[, featureNames])
measurements <- features[featuresWanted, featureNames]
measurements <- gsub('[()]', '', measurements)

# Load train datasets
train <- fread(file.path(path, "UCI HAR Dataset/train/X_train.txt"))[, featuresWanted, with = FALSE]
data.table::setnames(train, colnames(train), measurements)
trainActivities <- fread(file.path(path, "UCI HAR Dataset/train/Y_train.txt")
                         , col.names = c("Activity"))
trainSubjects <- fread(file.path(path, "UCI HAR Dataset/train/subject_train.txt")
                       , col.names = c("SubjectNum"))
train <- cbind(trainSubjects, trainActivities, train)

# Load test datasets
test <- fread(file.path(path, "UCI HAR Dataset/test/X_test.txt"))[, featuresWanted, with = FALSE]
data.table::setnames(test, colnames(test), measurements)
testActivities <- fread(file.path(path, "UCI HAR Dataset/test/Y_test.txt")
                        , col.names = c("Activity"))
testSubjects <- fread(file.path(path, "UCI HAR Dataset/test/subject_test.txt")
                      , col.names = c("SubjectNum"))
test <- cbind(testSubjects, testActivities, test)

# merge datasets
Data <- rbind(train, test)

# Convert classLabels to activityName basically. More explicit. 
Data[["Activity"]] <- factor(Data[, Activity]
                                 , levels = activityLabels[["classLabels"]]
                                 , labels = activityLabels[["activityName"]])

Data[["SubjectNum"]] <- as.factor(Data[, SubjectNum])
Data <- melt(data = Data, id = c("SubjectNum", "Activity"))
Data <- dcast(data = Data, SubjectNum + Activity ~ variable, fun.aggregate = mean)

fwrite(x = Data, file = "tidyData.txt", quote = FALSE)
