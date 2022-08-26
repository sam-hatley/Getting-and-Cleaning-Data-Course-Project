# Getting and Cleaning Data Course Project
Coursera, Data Science, Getting and Cleaning Data Course Project

## What the script does

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