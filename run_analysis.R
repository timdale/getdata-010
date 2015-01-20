#
# Getting and Cleaning Data course project
# timdale
# January 2015
#
#
#Instructions for project
#The purpose of this project is to demonstrate your ability to collect, work with, and clean a data set. The goal is to prepare tidy data that can be used for later analysis. You will be graded by your peers on a series of yes/no questions related to the project. You will be required to submit: 1) a tidy data set as described below, 2) a link to a Github repository with your script for performing the analysis, and 3) a code book that describes the variables, the data, and any transformations or work that you performed to clean up the data called CodeBook.md. You should also include a README.md in the repo with your scripts. This repo explains how all of the scripts work and how they are connected.#
#
#One of the most exciting areas in all of data science right now is wearable computing - see for example this article . Companies like Fitbit, Nike, and Jawbone Up are racing to develop the most advanced algorithms to attract new users. The data linked to from the course website represent data collected from the accelerometers from the Samsung Galaxy S smartphone. A full description is available at the site where the data was obtained:
#    
#    http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones
#
#Here are the data for the project:
#    
#    https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
#
#You should create one R script called run_analysis.R that does the following.
#
#Merges the training and the test sets to create one data set.
#Extracts only the measurements on the mean and standard deviation for each measurement.
#Uses descriptive activity names to name the activities in the data set
#Appropriately labels the data set with descriptive variable names.
#From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
#
#


library(base)
library(utils)
library(data.table)


#
# Run this once to download the data
#
download.data <- function() {
    zip.url <- 'https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip'
    zip.file <- 'dataset.zip'
    
    download.file(zip.url, destfile=zip.file, method='curl')
    unzip(zip.file)
}



rootPath <- file.path("UCI HAR Dataset")

filePath <- function(file) {
    paste(rootPath, "/", file, sep="")
}

typePath <- function(type, file) {
    filePath(paste(type, "/", file, "_", type, ".txt", sep=""))
}


testPath <- function(file) {
    typePath("test", file)
}

trainPath <- function(file) {
    typePath("train", file)
}



# Read the activity labels.
#
# Returns a table of two columns, e.g.:
#
#   activityId           activity
#            1            WALKING
#            2   WALKING_UPSTAIRS
#            3 WALKING_DOWNSTAIRS
#            :                  :
#
activityLabels <- function() {
    read.table(filePath("activity_labels.txt"), 
               stringsAsFactors=FALSE, 
               col.names=c('activityId', 'activity'))
}



# Get the activity IDs for the observations.  Each activity ID represents the activity being performed
# for each corresponding observation.  Why didn't they put this in with the obeservations???
#
# Returns a table of one column:
#     activityId
#              5
#              4
#              2
#              :
#
observationActivityIds <- function() {
    activityIds <- rbind(read.table(testPath("y"), stringsAsFactors=FALSE),
                         read.table(trainPath("y"), stringsAsFactors=FALSE))
    colnames(activityIds)[1] <- "activityId"
    activityIds
}



# Get the respective activity for each observation.
#
# Returns a table of activityId and activity, with each row corresponding to each respective row
# in the observations:
#
#   activityId activity
#            5 STANDING
#            5 STANDING
#            5 STANDING
#
observationActivities <- function() {
    
    # Join all the activities with their respective labels.  Use plyr.join because it maintains order
    library(plyr)
    join(observationActivityIds(), activityLabels(), by="activityId")
}



# Get the subject IDs for the observations.  Each subject ID represents which subject (person) performed
# each corresponding observation.  Why didn't they put this in with the obeservations???
#
# Returns a table of one column:
#      subjectId
#             30
#             24
#              2
#              :
#
observationSubjectIds <- function() {
    subjectIds <- rbind(read.table(testPath("subject"), stringsAsFactors=FALSE),
                        read.table(trainPath("subject"), stringsAsFactors=FALSE))
    colnames(subjectIds)[1] <- "subjectId"
    subjectIds
}



# Get the names of the observation table's columns.
#
# There are 561 columns in the observation table.
#
# Return a two-column table of the column number and the column name:
#
#  columnName             columnName
#           1      tBodyAcc-mean()-X
#           2      tBodyAcc-mean()-Y
#           3      tBodyAcc-mean()-Z
#           :                      :
#         559   angle(X,gravityMean)
#         560   angle(Y,gravityMean)
#         561   angle(Z,gravityMean)
#
columns <- function() {
    read.table(filePath("features.txt"), 
               stringsAsFactors=FALSE, 
               col.names=c('columnNum', 'columnName'))
} 



#
# Get the names of the features in which we are interested.
#
# We only care about the mean and stddev features
#
featureNames <- function() {
    grep("-(mean|std)[(]", columns()$columnName, value=TRUE)
}



# Get the raw observations
rawObservations <- function() {
    rbind(read.table(testPath("X"), head=FALSE), 
          read.table(trainPath("X"), head=FALSE))
}



# Get the observations, with "subjectId" and "activity" columns left-most:
#
#'data.frame':    10299 obs. of  68 variables:
# $ subjectId                  : int  2 2 2 2 2 2 2 2 2 2 ...
# $ activity                   : Factor w/ 6 levels "LAYING","SITTING",..: 3 3 3 3 3 3 3 3 3 3 ...
# $ tBodyAcc-mean()-X          : num  0.257 0.286 0.275 0.27 0.275 ...
# $ tBodyAcc-mean()-Y          : num  -0.0233 -0.0132 -0.0261 -0.0326 -0.0278 ...
# $ tBodyAcc-mean()-Z          : num  -0.0147 -0.1191 -0.1182 -0.1175 -0.1295 ...
# :
# :
#
observations <- function() {
    
    # Combine the test data and training data; just concatenate them
    message("Reading raw data...")
    obs <- rawObservations()
    
    message("Tidying the raw data...")
    
    # add the column names to the observations
    colnames(obs) <- columns()$columnName
    
    # keep just the columns that we desire
    obs <- subset(obs, select=featureNames())
    
    # clean up the column names so they are more readable
    names(obs) <- gsub('[()]', '', names(obs))   # get rid of ()
    names(obs) <- gsub("^t", "time", names(obs))
    names(obs) <- gsub("^f", "freq", names(obs))
    
    # Prepend the activity column as the left-most to the data
    obs <- cbind(activity=observationActivities()[,"activity"], obs)
    
    # Prepend the subject column as the left-most to the activity+data
    obs <- cbind(observationSubjectIds(), obs)
}




tidy2 <- function(tidyObservations) {
    message("Aggregating the mean by activity and subject")
    attach(tidyObservations)
    agg <- aggregate(tidyObservations, by=list(activity, subjectId), FUN=mean, na.rm=TRUE)
    
    # drop the post-aggregation unneeded columns
    agg <- subset(agg, select=-c(Group.2, activity))
    
    # rename Group.1 --> activity (it's our aggregation column)
    names(agg) <- gsub("Group.1", "activity", names(agg))
    str(agg)
    
    detach(tidyObservations)  
    agg
}



run.analysis <- function() {
    
    tidy <- observations()
    message("Writing tidy data file")
    write.csv(tidy, file='tidydata.csv', row.names=FALSE, quote=FALSE)
    
    
    agg <- tidy2(tidy)
    message("Writing tidy2 data file")
    write.csv(agg, file='tidydata2.csv', row.names=FALSE, quote=FALSE)
}




