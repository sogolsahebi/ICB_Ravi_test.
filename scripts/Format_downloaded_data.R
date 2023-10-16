# Format_downloaded_data.R

# Setup
# Define the paths to the source data files
file_path1 <- "C:/Users/sogol/OneDrive/Documents/BHK lab/Ravi/Source Data/Source Data/Clinical/SU2C-MARK_Harmonized_Clinical_Annotations_Supplement_v1.txt"
file_path2 <- "C:/Users/sogol/OneDrive/Documents/BHK lab/Ravi/Source Data/Source Data/Clinical/Table_S1_Clinical_Annotations.(csv).csv"

# Data Loading
clin_data1 <- read.table(file_path1, header = TRUE, sep = "\t")
clin_data2 <- read.csv(file_path2)

# Quick data overview for accuracy
head(clin_data1)
dim(clin_data1)
head(clin_data2)
dim(clin_data2)

# Data Cleaning
colnames(clin_data2) <- clin_data2[2,]
clin_data2 <- clin_data2[-c(1,2),]

# Data Merging
clin_merge_data <- merge(clin_data1, clin_data2, by = "Harmonized_SU2C_Participant_ID_v2")

# Discrepancy checks
# 1. Check row counts before and after the merge, which all 393 rows.
cat("Rows in clin_data1:", nrow(clin_data1), "\n")
cat("Rows in clin_data2:", nrow(clin_data2), "\n")
cat("Rows in merged data:", nrow(clin_merge_data), "\n")

# 2. Check for duplicates , which here are none or "0"
cat("Duplicates in clin_data1 based on ID:", sum(duplicated(clin_data1$Harmonized_SU2C_Participant_ID_v2)), "\n")
cat("Duplicates in clin_data2 based on ID:", sum(duplicated(clin_data2$Harmonized_SU2C_Participant_ID_v2)), "\n")
cat("Duplicates in merged data based on ID:", sum(duplicated(clin_merge_data$Harmonized_SU2C_Participant_ID_v2)), "\n")

# 3. Check column counts
expected_cols <- (ncol(clin_data1) + ncol(clin_data2) - 1) 
actual_cols <- ncol(clin_merge_data)
cat("Expected number of columns in merged data:", expected_cols, "\n")
cat("Actual number of columns in merged data:", actual_cols, "\n")
if (expected_cols != actual_cols) {
  cat("There's a discrepancy in column counts!\n")
} else {
  cat("Column count looks good.\n")
}

# Output & Review
head(clin_merge_data)
dim(clin_merge_data)

# Saving the merged data
write.csv(clin_merge_data, "C:/Users/sogol/OneDrive/Documents/BHK lab/Ravi/clin_merged.csv", row.names = FALSE)
