# Getting and Cleaning Data: Course Project

## What the script does
This script is broken down by functions for readability. Overall, it:
- imports and merges the relevant data sets;
- extracts the means and standard deviations from each measurement;
- labels activities with the supplied activity names;
- returns a csv that has the average of each variable for each activity and subject

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

At this point, we have six data frames with the raw data. I also want to import _features.txt_ to add context to the data and make it easier to work with down the line. This labels our data, and the names they've given us are descriptive enough to tell what kind of data we're looking at and it's purpose- the labels aren't _pretty_, but that's not a requirement for now.
```R
feats <- read.table("./data/features.txt",col.names = c("id","feature"))
```
Normally, I'd try to accomplish this stepwise, but it made far more sense to do this when we began to import the data, rather than after we'd already selected what variables we needed, as we'll rely on the labels to do so!
We'll actually apply these labels right before we merge everything together.

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

What stands out to me is that there are two values that complicate extracting the columns we need: _\*-mean()_ and _\*-meanFreq()_. We'll need to alter the regex to account for the parentheses following "mean".

Ultimately, what I'd like to do is create a list with the names of each column I want to keep, starting with "subject" and "activity_label" (the first two rows), which we'll send to our original data frame to extract only those columns.
```R
vars <- names(dat[1:2])
append(vars,grep("mean\\(\\)|std\\(\\)",names(dat), value = T))
select <- dat[vars]
```

### Naming the activities in the data set descriptively
As we saw in the beginning, the _activity\_label_ column is effectively a factor variable, and the data we're given already contains adequate labels for this purpose in _activity\_labels.txt_. We just need to grab this list, and apply those to the data we already have.

We start by importing those labels into a table, much like what we did when importing the data originally:
```R
lbls <- read.table("./data/activity_labels.txt")
lbls <- lbls$V2
```

Since we've got an ordered list of labels, all that's left to do is make the original column into a factor, and apply our list of labels.
```R
dat$activity_label <- as.factor(dat$activity_label)
levels(dat$activity_label) <- lbls
```
We'll double-check to make sure that everything's been applied appropriately, and move on our way.
```
> class(dat$activity_label)
[1] "factor"
> summary(dat$activity_label)
           WALKING   WALKING_UPSTAIRS WALKING_DOWNSTAIRS            SITTING           STANDING             LAYING 
              1722               1544               1406               1777               1906               1944
```
### Appropriately labelling the data
We applied basic labels when we [merged the test and training sets](https://github.com/sam-hatley/Getting-and-Cleaning-Data-Course-Project#labeling-the-data), but they're a bit difficult to read at a glance:
```
> names(dat)
 [1] "subject"                     "activity_label"              "tBodyAcc-mean()-X"           "tBodyAcc-mean()-Y"           "tBodyAcc-mean()-Z"          
 [6] "tBodyAcc-std()-X"            "tBodyAcc-std()-Y"            "tBodyAcc-std()-Z"            "tGravityAcc-mean()-X"        "tGravityAcc-mean()-Y"       
[11] "tGravityAcc-mean()-Z"        "tGravityAcc-std()-X"         "tGravityAcc-std()-Y"         "tGravityAcc-std()-Z"         "tBodyAccJerk-mean()-X"      
[16] "tBodyAccJerk-mean()-Y"       "tBodyAccJerk-mean()-Z"       "tBodyAccJerk-std()-X"        "tBodyAccJerk-std()-Y"        "tBodyAccJerk-std()-Z"       
[21] "tBodyGyro-mean()-X"          "tBodyGyro-mean()-Y"          "tBodyGyro-mean()-Z"          "tBodyGyro-std()-X"           "tBodyGyro-std()-Y"          
[26] "tBodyGyro-std()-Z"           "tBodyGyroJerk-mean()-X"      "tBodyGyroJerk-mean()-Y"      "tBodyGyroJerk-mean()-Z"      "tBodyGyroJerk-std()-X"      
[31] "tBodyGyroJerk-std()-Y"       "tBodyGyroJerk-std()-Z"       "tBodyAccMag-mean()"          "tBodyAccMag-std()"           "tGravityAccMag-mean()" 
```
It's worth looking at these and understanding how they've structured the names: now it's the variable, a "-", the kind of measurement, a "()", and in some cases, a "-" followed by the axis from which the measurement was taken. All of these are important, so we just need to replace each of these strings with something more appropriate.

It's not immediately clear what the prefix "t" or "f" do, but that's explained in _features\_info.txt_:
>The features selected for this database come from the accelerometer and gyroscope 3-axial raw signals tAcc-XYZ and tGyro-XYZ. These time domain signals (prefix 't' to denote time) were captured at a constant rate of 50 Hz. Then they were filtered using a median filter and a 3rd order low pass Butterworth filter with a corner frequency of 20 Hz to remove noise. Similarly, the acceleration signal was then separated into body and gravity acceleration signals (tBodyAcc-XYZ and tGravityAcc-XYZ) using another low pass Butterworth filter with a corner frequency of 0.3 Hz. 

And further down the line:
>Finally a Fast Fourier Transform (FFT) was applied to some of these signals producing fBodyAcc-XYZ, fBodyAccJerk-XYZ, fBodyGyro-XYZ, fBodyAccJerkMag, fBodyGyroMag, fBodyGyroJerkMag. (Note the 'f' to indicate frequency domain signals). 

So, the prefix "t" denotes time, whle "f" denotes a FFT.

"Acc" and "Gyro" are similarly described in the info document:
>The features selected for this database come from the accelerometer and gyroscope 3-axial raw signals tAcc-XYZ and tGyro-XYZ.

As is the term "Jerk":
>Subsequently, the body linear acceleration and angular velocity were derived in time to obtain Jerk signals

Which gives us a clear path forward. We need to:
- replace the prefix "t" with "Time" and "f" with "FFT";
- replace "Acc" with "Accelerometer" and "Gyro" with "Gyroscope";
- replace "Jerk" with "Jerk Signal";
- remove the "()" from "mean" and "std"; and
- keep the axis indicator at the end.

We'll do this with the ```gsub()``` function. Considering that we're working with functions and there are a lot of things to change, I'd rather do this with a ```for``` function. We'll create an empty vector for the names to go to, make the changes, and append them to the vector.
```R
for (label in names(dat)) {
  label = gsub("^t","Time_",
          gsub("^f","FFT_",
          gsub("Acc","_Accelerometer",
          gsub("Gyro","_Gyroscope",
          gsub("Mag","_Magnet",
          gsub("Jerk","_JerkSignal",
          gsub("-mean()","_Mean",
          gsub("-std()","_STD", label))))))))
  datlabels = append(datlabels,label)
  }
```
In the same function, we'll just need to apply those labels to our data:
```R
colnames(dat) <- datlabels
```



