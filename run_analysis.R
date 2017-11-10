# To assemble the data of test and train in a single file with subject ID of test
#
library(data.table)
library(reshape2)
path <- getwd()
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url, file.path(path, "dataFiles.zip"))# Down load file from url to local disk
unzip(zipfile = "dataFiles.zip") # Unzip files

# Collecting actvity labels and labels
activityLabels <- fread(file.path(path, "UCI HAR Dataset/activity_labels.txt")
                        , col.names = c("classLabels", "activityName"))

head(activityLabels)#Check for file reading
variables<- fread(file.path(path,"UCI HAR Dataset/features.txt"), 
                          col.names  =c("SNO","Variable_name"))
head(variables)
str(variables)
Reqdvariables <- grep("(mean|std)\\(\\)",variables$Variable_name)
head(Reqdvariables)
str(Reqdvariables)
values <-variables[Reqdvariables,Variable_name]
head(values)# Check column format
str(values)# Check column format
values <- gsub('[()]','',values) # Remove () from column names
head(values)# Check column name format

# adding training datasets with new col names
trainx<-fread(file.path(path,"UCI HAR Dataset/train/X_train.txt"))
trainx<-trainx[,Reqdvariables,with=FALSE]
setnames(trainx,colnames(trainx),values)
trainy<- fread(file.path(path,"UCI HAR Dataset/train/y_train.txt"),
               col.names=c("activity"))
sub_train<- fread(file.path(path,"UCI HAR Dataset/train/subject_train.txt"),
                  col.names=c("subjectID"))
train<-cbind(sub_train,trainy,trainx)# Binding datasets
head(train)
# Adding testing datasets
testx<-fread(file.path(path,"UCI HAR Dataset/test/X_test.txt"))
testx<-testx[,Reqdvariables,with=FALSE]
setnames(testx,colnames(testx),values)
testy<- fread(file.path(path,"UCI HAR Dataset/test/y_test.txt"),
               col.names=c("activity"))
sub_test<- fread(file.path(path,"UCI HAR Dataset/test/subject_test.txt"),
                  col.names=c("subjectID"))
test<-cbind(sub_test,testy,testx)
head(test)
#combining test and trial data sets
merged <-rbind(test,train)
head (merged)
#Replacing lables with activity names
merged[["activity"]] <- factor(merged$activity,
                                 levels = activityLabels$classLabels,
                                 labels = activityLabels$activityName,
                                 exclude = NA)
head( merged)# Check for proper transfer of levels with labels
merged$subjectID<- as.factor(merged$subjectID) # conversion of integer to factor
combined <- melt(data=merged, id=c("subjectID","activity"))
head(combined)
combinedfinal<- dcast(data=combined, subjectID+activity~variable,mean)
head(combinedfinal)
View(combinedfinal)
fwrite(x=combinedfinal,file="merged_clean_mean.csv",quote= FALSE)