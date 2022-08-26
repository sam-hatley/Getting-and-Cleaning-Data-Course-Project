# Getting and Cleaning Data Course Project
Coursera, Data Science, Getting and Cleaning Data Course Project

## What the script does
This script is broken down by functions for readability. Overall, it:
- executes a function to import, label, and merge the relevant data sets;
- executes a function to extract only the means and standard deviations from each measurement;
- Uses descriptive activity names to name the activities in the data set
Appropriately labels the data set with descriptive variable names. 
From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

## Methodology

### Making sense of the data
The raw data was downloaded, unzipped, and put into the ./data folder of the repository, and came with a number of relevant files:
- README.txt: a description of what's in the data
- features.txt: a list of each feature
- features_info.txt: further information about the features
- activity labels.txt: labels provided for each activity

Further, both the test and train sets folders had three files:
- x_test/train.txt: data set
- y_test/train.txt: data labels
- subect_test/train.txt: subject

Looking at the actual text files, you can get an idea of what we need to do to start: the x files are long text files with multiple spaced entries per line, and thousands of lines. Both Y and subject are numeric indicators of something, one number per line. The same number of lines exist in each document.

With this in mind, it's reasonably clear what the purpose of each file is: _x_ supplies a set of data, which is supplemented by _features.txt_, the actual names of each row within _x_. _y_ provides additional context- what activity the subject was participating in, and is a factor variable supplemented by _activity\_labels.txt_. Subject, thankfully, is clear.


### Merging the test and training sets

Starting off, we need to import the data into the environment. Originally, I had copied the raw data in the repository's "./data" folder, for easy access. Importing is reasonably straightforward, though you do need to select which _kind_ of ```read()``` command to throw R. ```read.table()``` reads data from text files, and we'll use it for that purpose:

```R
x_test <- read.table("./data/test/X_test.txt")
y_test <- read.table("./data/test/Y_test.txt")
sub_test <- read.table("./data/test/subject_test.txt")
x_train <- read.table("./data/train/X_train.txt")
y_train <- read.table("./data/train/Y_train.txt")
sub_train <- read.table("./data/train/subject_train.txt")
```

At this point, we have six data frames with the raw data. I also want to import _features.txt_ to add context to the data and make it easier to work with down the line:
```R
feats <- read.table("./data/features.txt",col.names = c("id","feature"))
```

Just to be certain we're clear that these tables will actually align, it's worth checking the dimensions of each:
```
> dim(x_test)
[1] 2947  561
> dim(y_test)
[1] 2947    1
> dim(sub_test)
[1] 2947    1
> dim(feats)
[1] 561   2
```
Looks good: _x_, our main data set, has 2947 rows and 561 columns. I expected _y_ and _sub_ to add an additional row to the data in _x_, and they each have 2947 rows. _feats_ also fits our expectations, as I expected it to have a label for each column in _x_, and it provides us with 561 rows of data. There is an extra column within _dim_, so we will need to look at the data to understand what needs to label _x_ (from the txt file, it's clear that the first row is an identifier, and the second column is the actual label).

From the beginning, my initial thought is to start by combining each of the three sets of data, _x_, _y_, and _sub_.
```R
x <- rbind(x_test,x_train)
y <- rbind(y_test,y_train)
sub <- rbind(sub_test,sub_train)
```
Before actually combining these data, I would like to take the time to apply more descriptive labels for each of the columns. Thankfully, we do have most of that information from importing "features.txt".
```R
colnames(x) <- feats$feature
colnames(y) <- "activity_label"
colnames(sub) <- "subject"
```
With that in mind, we can merge and be done with this portion.
```R
dat <- cbind(sub,y,x)
```


### Extracting measurements on mean and standard deviation for each measurement

To start, it's worth taking a look at what measurements we have:
```R
names(dat)
```
```
  [1] "subject"                              "activity_label"                       "tBodyAcc-mean()-X"                    "tBodyAcc-mean()-Y"                   
  [5] "tBodyAcc-mean()-Z"                    "tBodyAcc-std()-X"                     "tBodyAcc-std()-Y"                     "tBodyAcc-std()-Z"                    
  [9] "tBodyAcc-mad()-X"                     "tBodyAcc-mad()-Y"                     "tBodyAcc-mad()-Z"                     "tBodyAcc-max()-X"                    
 [13] "tBodyAcc-max()-Y"                     "tBodyAcc-max()-Z"                     "tBodyAcc-min()-X"                     "tBodyAcc-min()-Y"                    
 [17] "tBodyAcc-min()-Z"                     "tBodyAcc-sma()"                       "tBodyAcc-energy()-X"                  "tBodyAcc-energy()-Y"                 
 [21] "tBodyAcc-energy()-Z"                  "tBodyAcc-iqr()-X"                     "tBodyAcc-iqr()-Y"                     "tBodyAcc-iqr()-Z"                    
 [25] "tBodyAcc-entropy()-X"                 "tBodyAcc-entropy()-Y"                 "tBodyAcc-entropy()-Z"                 "tBodyAcc-arCoeff()-X,1"              
 [29] "tBodyAcc-arCoeff()-X,2"               "tBodyAcc-arCoeff()-X,3"               "tBodyAcc-arCoeff()-X,4"               "tBodyAcc-arCoeff()-Y,1"              
 [33] "tBodyAcc-arCoeff()-Y,2"               "tBodyAcc-arCoeff()-Y,3"               "tBodyAcc-arCoeff()-Y,4"               "tBodyAcc-arCoeff()-Z,1"              
 [37] "tBodyAcc-arCoeff()-Z,2"               "tBodyAcc-arCoeff()-Z,3"               "tBodyAcc-arCoeff()-Z,4"               "tBodyAcc-correlation()-X,Y"          
 [41] "tBodyAcc-correlation()-X,Z"           "tBodyAcc-correlation()-Y,Z"           "tGravityAcc-mean()-X"                 "tGravityAcc-mean()-Y"    
```

There's quite a lot of extra information here, but it does give an idea of what to start looking at: columns with mean data are labeled with _\*-mean()_, and columns with standard deviation data are labeled with _\*-std()_. Writing a function to find this information isn't complicated: we'll use grep with an OR operator ("|") and ask it to return the values with ```value = T```.
```R
grep("mean|std",names(dat), value = T)
```
```    
[45] "fBodyAcc-std()-Y"                "fBodyAcc-std()-Z"                "fBodyAcc-meanFreq()-X"           "fBodyAcc-meanFreq()-Y"          
[49] "fBodyAcc-meanFreq()-Z"           "fBodyAccJerk-mean()-X"           "fBodyAccJerk-mean()-Y"           "fBodyAccJerk-mean()-Z"          
[53] "fBodyAccJerk-std()-X"            "fBodyAccJerk-std()-Y"            "fBodyAccJerk-std()-Z"            "fBodyAccJerk-meanFreq()-X"      
[57] "fBodyAccJerk-meanFreq()-Y"       "fBodyAccJerk-meanFreq()-Z"       "fBodyGyro-mean()-X"              "fBodyGyro-mean()-Y"             
[61] "fBodyGyro-mean()-Z"              "fBodyGyro-std()-X"               "fBodyGyro-std()-Y"               "fBodyGyro-std()-Z"              
[65] "fBodyGyro-meanFreq()-X"          "fBodyGyro-meanFreq()-Y"          "fBodyGyro-meanFreq()-Z"          "fBodyAccMag-mean()"             
[69] "fBodyAccMag-std()"               "fBodyAccMag-meanFreq()"          "fBodyBodyAccJerkMag-mean()"      "fBodyBodyAccJerkMag-std()"      
[73] "fBodyBodyAccJerkMag-meanFreq()"  "fBodyBodyGyroMag-mean()"         "fBodyBodyGyroMag-std()"          "fBodyBodyGyroMag-meanFreq()"    
[77] "fBodyBodyGyroJerkMag-mean()"     "fBodyBodyGyroJerkMag-std()"      "fBodyBodyGyroJerkMag-meanFreq()"
```

What stands out to me is that there are two values that complicates extracting the columns we need: _\*-mean()_ and _\*-meanFreq()_. We'll need to alter the regex to account for the parentheses following "mean".

Ultimately, what I'd like to do is create a list with the names of each column I want to keep, starting with "subject" and "activity_label" (the first two rows), which we'll send to our original data frame to extract only those columns.
```R
vars <- names(dat[1:2])
append(vars,grep("mean\\(\\)|std\\(\\)",names(dat), value = T))
select <- dat[vars]
```


