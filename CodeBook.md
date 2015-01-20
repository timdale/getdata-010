---
title: "CodeBook.md"
output: html_document
---

# Code Book

## Raw Data Collection

The raw data was pulled from the UCI Machine Learning Laboratory.  Details on the data are found at [http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones]

The data itself was downloaded from [https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip], decompressed, and _installed in the same working directory as the script_.


## Raw Data Content

The observation data was split up by the provider between a training set and test set, whose data is found in the *test* and *train* subdirectories. 
- *test/Inertial Signals* and *train/Inertial Signals* are not used in this project.
- *test/X_test.txt* and *train/X_train.txt* contain the actual observations.  Each line of these files is a 561-feature vector (i.e., 561 columns of whitespace-separated numeric text, in scientific notation), normalized to -1..1
- *test/subject_test.txt* and *train/subject_train.txt* is a single column of subject IDs.  The observations were made by 30 subjects, with an ID from 1..30.  There is a row corresponding to each row in the respective *X* observation file, thus indicating which subject collected that respective observation.
- *test/y_test.txt* and *train/y_train.txt* is a single column of activity IDs.  Similar to the subject IDs, there is a row corresponding to each row in the respective *X* observation file, thus indicating which activity was being performed for that observation.  See *activity_labels.txt* below.
- *features.txt* is the feature name for each feature in the *X* observation files.  I.e., it contains the names for each column of data in the *X* files.  There are thus 561 names in this file, one for each column of data.
- *features_info.txt* contains the details for each feature, as provided by UCI.  This file is not used in creating the tidy data, but is informative for understanding the data.
- *activity_labels.txt* contains the mapping of activity IDs to a meaningful description:
```
1 WALKING
2 WALKING_UPSTAIRS
3 WALKING_DOWNSTAIRS
4 SITTING
5 STANDING
6 LAYING
```

## Tidying the Data

*run_analysis.R* is the script that performs the tidying of the data.  

### Merging the Test and Training Data

1. The observation data is first read from the *X* files and concatentated into a data frame with column names read and applied from *features.txt*.  There are now a total of 10299 observations.
2. Likewise the activity IDs are merged from the *y* files.
3. Likewise the subject IDs are merged from the *subject* files.

Note that all merging is done in order: test, training.


### Thatching 
This project is only concerned with features that contain means or standard deviations.  The pertinent columns will all have names that contain ```-mean()``` or ```-std()```, respectively.  All other columns are dropped from the observation data, leaving 79 columns.

### Preening
The observation column names are net made a little more readable.  This is a simple transformation:
 - All parens ```()``` are removed from the names
 - Names beginning with a single lowercase ```t``` are suffixed with ```time``` (and the ```t``` removed).
 - Names beginning with a single lowercase ```f``` are suffixed with ```freq``` (and the ```f``` removed).
 
### Joining the Subjects, Activities, and Observations
1. The descriptive activities  (e.g., "WALKING", "STANDING") are translated from the activity IDs, and left-pended to each observation, forming a column named "activity".  This makes the data easier for humans to read instead of a numeric ID for the activity.
2. The subject IDs are merged from the test and training sets, and are left-pended to each observation, forming a column named "subjectId".

The result is a data frame of 81 columns.  The first (left-most) column is "subjectId", followed by "activity", followed by the 79 named mean/stddev columns.




To run it, simply load it into R and 
```
run.analysis()
```
It will output 

This is an R Markdown document. Markdown is a simple formatting syntax for authoring HTML, PDF, and MS Word documents. For more details on using R Markdown see <http://rmarkdown.rstudio.com>.

When you click the **Knit** button a document will be generated that includes both content as well as the output of any embedded R code chunks within the document. You can embed an R code chunk like this:

```{r}
summary(cars)
```

You can also embed plots, for example:

```{r, echo=FALSE}
plot(cars)
```

Note that the `echo = FALSE` parameter was added to the code chunk to prevent printing of the R code that generated the plot.
