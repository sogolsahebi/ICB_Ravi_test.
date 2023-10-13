# Format_downloaded_data.R

# Setup
# Define the paths to the source data files
file_path1 <- "C:/Users/sogol/OneDrive/Documents/BHK lab/Ravi/Source Data/Source Data/Clinical/SU2C-MARK_Harmonized_Clinical_Annotations_Supplement_v1.txt"
file_path2 <- "C:/Users/sogol/OneDrive/Documents/BHK lab/Ravi/Source Data/Source Data/Clinical/Table_S1_Clinical_Annotations.(csv).csv"

# Data Loading
# Read the ".txt" file into a data frame
clin_data1 <- read.table(file_path1, header = TRUE, sep = "\t")

# Read the ".csv" file into a data frame
clin_data2 <- read.csv(file_path2)

# Quick data overview for accuracy
head(clin_data1)
dim(clin_data1)
head(clin_data2)
dim(clin_data2)

# Data Cleaning
# For clin_data2: Set the column names and remove the first two rows
colnames(clin_data2) <- clin_data2[2,]
clin_data2 <- clin_data2[-c(1,2),]

# Data Merging
# Merge clin_data1 and clin_data2 using the Harmonized_SU2C_Participant_ID_v2 as the key
clin_merge_data <- merge(clin_data1, clin_data2, by = "Harmonized_SU2C_Participant_ID_v2")


# Output & Review
# View the merged data and its dimensions
head(clin_merge_data)
dim(clin_merge_data)

#Saving the merge data as a CSV file
write.csv(clin_merge_data , "C:/Users/sogol/OneDrive/Documents/BHK lab/Ravi/clin_merged.csv", row.names = FALSE)


