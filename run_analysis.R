#Merge the training and test sets to create one data set

#Importing data sets
x_test <- read.table("./data/test/X_test.txt")
y_test <- read.table("./data/test/Y_test.txt")
sub_test <- read.table("./data/test/subject_test.txt")
x_train <- read.table("./data/train/X_train.txt")
y_train <- read.table("./data/train/Y_train.txt")
sub_train <- read.table("./data/train/subject_train.txt")

#Merging test and train data sets
x <- rbind(x_test,x_train)
y <- rbind(y_test,y_train)
sub <- rbind(sub_test,sub_train)

#Using the supplied column names to name the columns
#These will be replaced with descriptive labels later
vars <- read.table("./data/features.txt",col.names = c("id","feature"))
colnames(x) <- vars$feature
colnames(y) <- "activity_label"
colnames(sub) <- "subject"
rawdat <- cbind(sub,y,x)



#Extract measurements on mean and standard deviation for each measurement

names(rawdat[1:2])
grep("mean",names(rawdat), value = T)


#Describes the activities in the data set

#Labels variables

#Creates a second, independent tidy data set with the average of each variable for each activity and each subject