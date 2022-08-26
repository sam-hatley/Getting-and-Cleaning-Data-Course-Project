#Merge the training and test sets to create one data set
mergedata <- function(){
  #Importing data sets and variable names
  x_test <- read.table("./data/test/X_test.txt")
  y_test <- read.table("./data/test/Y_test.txt")
  sub_test <- read.table("./data/test/subject_test.txt")
  x_train <- read.table("./data/train/X_train.txt")
  y_train <- read.table("./data/train/Y_train.txt")
  sub_train <- read.table("./data/train/subject_train.txt")
  feats <- read.table("./data/features.txt",col.names = c("id","feature"))
  
  #Merging test and train data sets
  x <- rbind(x_test,x_train)
  y <- rbind(y_test,y_train)
  sub <- rbind(sub_test,sub_train)
  
  #Using the supplied column names to name the columns
  colnames(x) <- feats$feature
  colnames(y) <- "activity_label"
  colnames(sub) <- "subject"
  
  #Merge
  dat <- cbind(sub,y,x)
  return(dat)
}


#Extract measurements on mean and standard deviation for each measurement
extract <- function(dat){
  #Taking a list of the rows we want to keep
  vars <- names(dat[1:2])
  vars <- append(vars,grep("mean\\(\\)|std\\(\\)",names(dat), value = T))
  
  #Extracting those rows
  select <- dat[vars]
  return(select)
}


#Describes the activities in the data set
describe_activities <- function(df){
  #Import the existing labels and make them into a list
  lbls <- read.table("./data/activity_labels.txt")
  lbls <- lbls$V2
  
  #Make the column into a factor variable
  df$activity_label <- as.factor(df$activity_label)
  
  #Rename the activities to make them descriptive
  levels(df$activity_label) <- lbls

  return(df)
}
#Label variables descriptively
relabel <- function(dat){
  #Create an empty vector to add names to
  datlabels = vector()
  
  #Go through each name in the dataframe, make changes with regex, and append it to the vector
  for (label in names(dat)) {
    label = gsub("^t","Time_",
            gsub("^f","FFT_",
            gsub("Acc","_Accelerometer",
            gsub("Gyro","_Gyroscope",
            gsub("Mag","_Magnet",
            gsub("Jerk","_JerkSignal",
            gsub("-mean\\(\\)","_Mean",
            gsub("-std\\(\\)","_STD", label))))))))
    datlabels = append(datlabels,label)
  }
  #Apply those names to the dataframe
  colnames(dat) <- datlabels
  return(dat)
}

#Creates a second, independent tidy data set with the average of each variable for each activity and each subject

#Execution
dat = mergedata()
dat = extract(dat)
dat = describe_activities(dat)
dat = relabel(dat)
head(dat[,1:9])
