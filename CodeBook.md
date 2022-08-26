# Code Book
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
colnames(y) <- "activity"
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
  [1] "subject"                              "activity"                             "tBodyAcc-mean()-X"                    "tBodyAcc-mean()-Y"                   
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

Ultimately, what I'd like to do is create a list with the names of each column I want to keep, starting with "subject" and "activity" (the first two rows), which we'll send to our original data frame to extract only those columns.
```R
vars <- names(dat[1:2])
append(vars,grep("mean\\(\\)|std\\(\\)",names(dat), value = T))
select <- dat[vars]
```

### Naming the activities in the data set descriptively
As we saw in the beginning, the _activity_ column is effectively a factor variable, and the data we're given already contains adequate labels for this purpose in _activity\_labels.txt_. We just need to grab this list, and apply those to the data we already have.

We start by importing those labels into a table, much like what we did when importing the data originally:
```R
lbls <- read.table("./data/activity_labels.txt")
lbls <- lbls$V2
```

Since we've got an ordered list of labels, all that's left to do is make the original column into a factor, and apply our list of labels.
```R
dat$activity <- as.factor(dat$activity)
levels(dat$activity) <- lbls
```
We'll double-check to make sure that everything's been applied appropriately, and move on our way.
```
> class(dat$activity)
[1] "factor"
> summary(dat$activity)
           WALKING   WALKING_UPSTAIRS WALKING_DOWNSTAIRS            SITTING           STANDING             LAYING 
              1722               1544               1406               1777               1906               1944
```
### Appropriately labelling the data
We applied basic labels when we [merged the test and training sets](https://github.com/sam-hatley/Getting-and-Cleaning-Data-Course-Project/blob/main/CodeBook.md#merging-the-test-and-training-sets), but they're a bit difficult to read at a glance:
```
> names(dat)
 [1] "subject"                     "activity"                    "tBodyAcc-mean()-X"           "tBodyAcc-mean()-Y"           "tBodyAcc-mean()-Z"          
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

Unfortuately, they didn't describe what "Mag" did, but we'll just call it "Magnet"

Which gives us a clear path forward. We need to:
- replace the prefix "t" with "Time" and "f" with "FFT";
- replace "Acc" with "Accelerometer" and "Gyro" with "Gyroscope";
- replace "Mag" with "Magnet";
- replace "Jerk" with "JerkSignal";
- remove the "()" from "mean" and "std";
- clearly note breaks between important parts of the label; and
- keep the axis indicator at the end.

We'll do this with the ```gsub()``` function. Considering that we're working with functions and there are a lot of things to change, I'd rather do this with a ```for``` loop. We'll create an empty vector for the names to go to, make the changes, and append them to the vector.
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

### Creating a second, independent tidy data set with the average of each variable for each activity and each subject
What's important in this data set is that we have multiple entries for each subject and activity: 
```
dat[,1:5]
    subject     activity       Time_Body_Accelerometer_Mean-X Time_Body_Accelerometer_Mean-Y Time_Body_Accelerometer_Mean-Z
1         2           STANDING                     0.25717778                  -0.0232852300                    -0.01465376
2         2           STANDING                     0.28602671                  -0.0131633590                    -0.11908252
3         2           STANDING                     0.27548482                  -0.0260504200                    -0.11815167
4         2           STANDING                     0.27029822                  -0.0326138690                    -0.11752018
5         2           STANDING                     0.27483295                  -0.0278477880                    -0.12952716
6         2           STANDING                     0.27921995                  -0.0186203990                    -0.11390197
7         2           STANDING                     0.27974586                  -0.0182710260                    -0.10399988
8         2           STANDING                     0.27460055                  -0.0250351300                    -0.11683085
9         2           STANDING                     0.27252874                  -0.0209540130                    -0.11447249
10        2           STANDING                     0.27574570                  -0.0103719940                    -0.09977589
```

To make something _tidy_, we'll need to break the data down first by subject, then by activity, take the means of each subject/activity, and finally put that all back together. We'll do this with dplyr.

Frankly, this is more simple to do than it appears. Breaking the data down by subject and activity is a one-line command with dplyr, just remember to load it first:
```R
library(dplyr)
dat = group_by(dat,subject,activity)
```
With this finished, all we need to do is get the means. Again, this is one line of code with dplyr, using ```summarise_all()``` and passing "mean".
```R
dat = summarise_all(dat,mean)
```
Finally, we'll write this to a file. Personally, I prefer to work with *.csv files, so that's what we'll use here:
```R
write.csv(dat,file="./data/output.csv")
```
## Variables
### Variable Details
There are two variables, _subject_ and _activity_ that work to identify and categorise the other variables.

_subject_ is a numeric variable which designates which subject the observations come from.

_activity_ is a factor variable which desgignates which activity the subject was participating in at the time of the observation. It has the following levels:
```
WALKING
WALKING_UPSTAIRS
WALKING_DOWNSTAIRS
SITTING
STANDING
LAYING
```

All other variables have between 4 and 6 components:
- A prefix, "Time" or "FFT"
  - "Time" denotes a time domain signal that was captured at a rate of 50 Hz
  - "FFT" represents a variable which has had a Fast fourier Transform applied
- A note describing whether this is a "Body" or "Gravity" measurement
- "Accelerometer" or "Gyroscope" which describes the data input
- "Mean" or "STD" which tells you if the measurement is a mean of that subject and activity, or the standard deviation
- In some cases, a suffix "-X", "-Y", or "-Z" that describes which axis the measurement was taken from

Additional information about the how the data was captured can be found in README.txt.

### List of variables
subject

activity

Time_Body_Accelerometer_Mean-X

Time_Body_Accelerometer_Mean-Y

Time_Body_Accelerometer_Mean-Z

Time_Body_Accelerometer_STD-X

Time_Body_Accelerometer_STD-Y

Time_Body_Accelerometer_STD-Z

Time_Gravity_Accelerometer_Mean-X

Time_Gravity_Accelerometer_Mean-Y

Time_Gravity_Accelerometer_Mean-Z

Time_Gravity_Accelerometer_STD-X

Time_Gravity_Accelerometer_STD-Y

Time_Gravity_Accelerometer_STD-Z

Time_Body_Accelerometer_JerkSignal_Mean-X

Time_Body_Accelerometer_JerkSignal_Mean-Y

Time_Body_Accelerometer_JerkSignal_Mean-Z

Time_Body_Accelerometer_JerkSignal_STD-X

Time_Body_Accelerometer_JerkSignal_STD-Y

Time_Body_Accelerometer_JerkSignal_STD-Z

Time_Body_Gyroscope_Mean-X

Time_Body_Gyroscope_Mean-Y

Time_Body_Gyroscope_Mean-Z

Time_Body_Gyroscope_STD-X

Time_Body_Gyroscope_STD-Y

Time_Body_Gyroscope_STD-Z

Time_Body_Gyroscope_JerkSignal_Mean-X

Time_Body_Gyroscope_JerkSignal_Mean-Y

Time_Body_Gyroscope_JerkSignal_Mean-Z

Time_Body_Gyroscope_JerkSignal_STD-X

Time_Body_Gyroscope_JerkSignal_STD-Y

Time_Body_Gyroscope_JerkSignal_STD-Z

Time_Body_Accelerometer_Magnet_Mean

Time_Body_Accelerometer_Magnet_STD

Time_Gravity_Accelerometer_Magnet_Mean

Time_Gravity_Accelerometer_Magnet_STD

Time_Body_Accelerometer_JerkSignal_Magnet_Mean

Time_Body_Accelerometer_JerkSignal_Magnet_STD

Time_Body_Gyroscope_Magnet_Mean

Time_Body_Gyroscope_Magnet_STD

Time_Body_Gyroscope_JerkSignal_Magnet_Mean

Time_Body_Gyroscope_JerkSignal_Magnet_STD

FFT_Body_Accelerometer_Mean-X

FFT_Body_Accelerometer_Mean-Y

FFT_Body_Accelerometer_Mean-Z

FFT_Body_Accelerometer_STD-X

FFT_Body_Accelerometer_STD-Y

FFT_Body_Accelerometer_STD-Z

FFT_Body_Accelerometer_JerkSignal_Mean-X

FFT_Body_Accelerometer_JerkSignal_Mean-Y

FFT_Body_Accelerometer_JerkSignal_Mean-Z

FFT_Body_Accelerometer_JerkSignal_STD-X

FFT_Body_Accelerometer_JerkSignal_STD-Y

FFT_Body_Accelerometer_JerkSignal_STD-Z

FFT_Body_Gyroscope_Mean-X

FFT_Body_Gyroscope_Mean-Y

FFT_Body_Gyroscope_Mean-Z

FFT_Body_Gyroscope_STD-X

FFT_Body_Gyroscope_STD-Y

FFT_Body_Gyroscope_STD-Z

FFT_Body_Accelerometer_Magnet_Mean

FFT_Body_Accelerometer_Magnet_STD

FFT_BodyBody_Accelerometer_JerkSignal_Magnet_Mean

FFT_BodyBody_Accelerometer_JerkSignal_Magnet_STD

FFT_BodyBody_Gyroscope_Magnet_Mean

FFT_BodyBody_Gyroscope_Magnet_STD

FFT_BodyBody_Gyroscope_JerkSignal_Magnet_Mean

FFT_BodyBody_Gyroscope_JerkSignal_Magnet_STD