# Create one R script called run_analysis.R that does the following:
## 1. Merges the training and the test sets to create one data set.
## 2. Extracts only the measurements on the mean and standard deviation for each measurement.
## 3. Uses descriptive activity names to name the activities in the data set
## 4. Appropriately labels the data set with descriptive activity names.
## 5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject.

if (!require("data.table")) {
  install.packages("data.table")
}

if (!require("reshape2")) {
  install.packages("reshape2")
}

require("data.table")
require("reshape2")

# Load: activity labels
activiti_labels <- read.table("./UCI HAR Dataset/activity_labels.txt")[,2]

# Load: data column names
fitur <- read.table("./UCI HAR Dataset/features.txt")[,2]

# Extract only the measurements on the mean and standard deviation for each measurement.
extract_fitur <- grepl("mean|std", fitur)

# Load and process X_test & y_test data.
X_ujian <- read.table("./UCI HAR Dataset/test/X_test.txt")
y_ujian <- read.table("./UCI HAR Dataset/test/y_test.txt")
subject_ujian <- read.table("./UCI HAR Dataset/test/subject_test.txt")

names(X_ujian) = fitur

# Extract only the measurements on the mean and standard deviation for each measurement.
X_ujian = X_ujian[,extract_fitur]

# Load activity labels
y_ujian[,2] = activiti_labels[y_ujian[,1]]
names(y_ujian) = c("Activity_ID", "Activity_Label")
names(subject_ujian) = "subject"

# Bind data
ujian_data <- cbind(as.data.table(subject_ujian), y_ujian, X_ujian)

# Load and process X_train & y_train data.
X_latihan <- read.table("./UCI HAR Dataset/train/X_train.txt")
y_latihan <- read.table("./UCI HAR Dataset/train/y_train.txt")

subject_latihan <- read.table("./UCI HAR Dataset/train/subject_train.txt")

names(X_latihan) = fitur

# Extract only the measurements on the mean and standard deviation for each measurement.
X_latihan = X_latihan[,extract_fitur]

# Load activity data
y_latihan[,2] = activiti_labels[y_latihan[,1]]
names(y_latihan) = c("Activity_ID", "Activity_Label")
names(subject_latihan) = "subject"

# Bind data
latihan_data <- cbind(as.data.table(subject_latihan), y_latihan, X_latihan)

# Merge test and train data
data = rbind(ujian_data, latihan_data)

id_labels   = c("subject", "Activity_ID", "Activity_Label")
data_labels = setdiff(colnames(data), id_labels)
melt_data      = melt(data, id = id_labels, measure.vars = data_labels)

# Apply mean function to dataset using dcast function
tidy_data   = dcast(melt_data, subject + Activity_Label ~ variable, mean)

write.table(tidy_data, file = "./tidy_data.txt")