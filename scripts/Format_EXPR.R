# RNA-seq Data Processing
# File: expr_format.R

# Load necessary libraries
install.packages("CePa")
install.packages("Rgraphviz")
library(CePa)

# Data Reading
# Define the path for the .gct file
gct_file_path <- "C:/Users/sogol/OneDrive/Documents/BHK lab/Ravi/Source Data/Source Data/RNA/SU2C-MARK_Harmonized_rnaseqc_tpm_v1.gct"

# Read the RNA-Seq data from the gct file
expr <- read.gct(gct_file_path)

# Data Cleaning
# Convert column names: replace periods with hyphens
new_colnames <- gsub("\\.", "-", colnames(expr))

# Remove trailing -T1 or -T2 from column names (representing time points)
new_colnames <- gsub("-T1$|-T2$", "", new_colnames)

# Reassign cleaned column names back to the dataset
colnames(expr) <- new_colnames

# Check the number of patient ids that match with the clinical dataset (assuming 'clin' is loaded elsewhere in your code)
sum(colnames(expr) %in% clin$patient)

# Identify and print any duplicate column names (should be 0 for clean data)
duplicate_colnames <- colnames(expr)[duplicated(colnames(expr))]
duplicate_colnames

# Sort the dataset by row names
expr <- expr[sort(rownames(expr)),]

# Confirm that all column values are numeric
is.numeric(expr)

# Data Filtering
# Define the path for the 'cased_sequenced.csv' file
file_path <- "C:/Users/sogol/OneDrive/Documents/BHK lab/Ravi/ICB_Ravi/data/cased_sequenced.csv"

# Read the 'case' dataset
case <- read.csv(file_path)

# Filter the 'expr' dataset to include only patients with expr value of 1 in the 'case' dataset
expr <- expr[ , case[case$expr %in% 1,]$patient]

# Check the range of data values
range(expr)

# Data Transformation
# Convert TPM data to log2-TPM for consistency with other data formats
expr <- log2(expr + 0.001)

# Check the updated range of data values
range(expr)

# Data Export
# Define the output path for the cleaned data.
output_file_path <- "C:/Users/sogol/OneDrive/Documents/BHK lab/Ravi/ICB_Ravi/data/EXPR.csv"

# Write the cleaned 'expr' dataset to a CSV file.
write.csv(expr, output_file_path, row.names = TRUE)



