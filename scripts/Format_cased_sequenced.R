# Set the file path for the clinical merged data
fpath <- "C:/Users/sogol/OneDrive/Documents/BHK lab/Ravi/clin.csv"

# Load the clinical merged data from the specified file path
clin <- read.csv(fpath)

# Extract unique patients and sort them.
patient <- sort(unique(clin$patient))

# Initialize a data frame for 'case' with the unique patients and default values
case <- as.data.frame(cbind(patient, rep(0, length(patient)), rep(0, length(patient)), rep(0, length(patient))))
colnames(case) <- c("patient", "snv", "cna", "expr")
rownames(case) <- patient

# Convert the case values to numeric
case$snv <- as.numeric(as.character(case$snv))
case$cna <- as.numeric(as.character(case$cna))
case$expr <- as.numeric(as.character(case$expr))

# Load the RNA data
expr <- read.gct("C:/Users/sogol/OneDrive/Documents/BHK lab/Ravi/Source Data/Source Data/RNA/SU2C-MARK_Harmonized_rnaseqc_tpm_v1.gct")

# Ensure the column names of the 'expr' (representing patient IDs) are consistent with the clinical data
# 1. Replace periods with hyphens
# 2. Remove trailing -T1 or -T2
new_colnames <- gsub("\\.", "-", colnames(expr))
new_colnames <- gsub("-T1$|-T2$", "", new_colnames)
colnames(expr) <- new_colnames

# Check for any duplicate column names after renaming
duplicate_colnames <- colnames(expr)[duplicated(colnames(expr))]
print(duplicate_colnames)  # Should ideally print nothing if there are no duplicates

# Sort the row names of 'expr'
expr <- expr[sort(rownames(expr)),]

# Check the overlap of patient IDs between the 'expr' and 'clin' data
print(sum(colnames(expr) %in% clin$patient))

# Check the overlap of patient IDs between the 'case' and 'expr' data
sum(rownames(case) %in% colnames(expr))


# Update the 'expr' column in 'case' based on the presence of patient IDs in the 'expr' data
for(i in 1:nrow(case)) {
  if(rownames(case)[i] %in% colnames(expr)) {
    case$expr[i] = 1
  }
}

# Save the updated 'case' data frame to a CSV file
write.csv(case, "C:/Users/sogol/OneDrive/Documents/BHK lab/Ravi/Ravi_Test/scripts/cased_sequenced.csv", row.names = FALSE)

