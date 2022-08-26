# Getting and Cleaning Data: Course Project

## What the script does
This script is broken down by functions for readability. Overall, it:
- imports and merges the relevant data sets;
- extracts the means and standard deviations from each measurement;
- labels activities with the supplied activity names;
- returns \*.csv and a \*.txt files that have the average of each variable for each activity and subject

## What's included
There are three important files within this script, you can safely ignore _.gitignore_ and _Getting-and-Cleaning-Data-Course-Project.Rproj_.
- This file, _README.md_, which describes the script and the files in this repository;
- [run_analysis.R](https://github.com/sam-hatley/Getting-and-Cleaning-Data-Course-Project/blob/main/run_analysis.R), which is the script that does the work; and
- [CodeBook.md](https://github.com/sam-hatley/Getting-and-Cleaning-Data-Course-Project/blob/main/CodeBook.md), which describes the methodology used to clean up the data, and the variables that are returned from the above script.

Additionally, I've included [output.csv](https://github.com/sam-hatley/Getting-and-Cleaning-Data-Course-Project/blob/main/data/output.csv), which is the output of the script.

## Instructions
1. Download and unzip the [source data](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip) to the ./data directory
2. Run [run_analysis.R](https://github.com/sam-hatley/Getting-and-Cleaning-Data-Course-Project/blob/main/run_analysis.R)
