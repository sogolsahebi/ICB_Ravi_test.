# Clinical Data Processing for Ravi_dataset

# Libraries and Source Files
# Access necessary functions from ICB_common codes.
source("https://raw.githubusercontent.com/BHKLAB-Pachyderm/ICB_Common/main/code/Get_Response.R")
source("https://raw.githubusercontent.com/BHKLAB-Pachyderm/ICB_Common/main/code/format_clin_data.R")

# Data Loading
# Define the path to the source data.
file_path <- "C:/Users/sogol/OneDrive/Documents/BHK lab/Ravi/clin_merged.csv"

# Load the clinical merged data from the given file path.
clin_merge_data <- read.csv(file_path)

# Rename specific columns for standardization.
colnames(clin_merge_data)[colnames(clin_merge_data) == "Harmonized_SU2C_Participant_ID_v2"] <- "patient"

# Data Curating

# Select the required columns for further analysis.
selected_cols <- c(
  "patient",
  "Patient_Age_at_Diagnosis",
  "Harmonized_Confirmed_BOR",
  "Harmonized_OS_Months",
  "Harmonized_PFS_Months",
  "Histology_Harmonized",
  "Initial_Stage",
  "Patient_Sex",
  "Harmonized_OS_Event",
  "Harmonized_PFS_Event",
  "WES_All",
  "RNA_All",
  "Agent_PD1"
)


# Combine selected columns with additional columns.
clin <- cbind(clin_merge_data[, selected_cols], "PD-1/CTLA4", "Lung", NA, NA, NA, NA, NA)

# Set new column names.
colnames(clin) <- c(
  "patient", "age", "recist", "t.os", "t.pfs", "histo", "stage", "sex", "os",
  "pfs", "dna", "rna", "treatmentid", "drug_type", "primary", "response.other.info", "response"
)


# Modify stage values for better clarity.
clin$stage <- ifelse(clin$stage == 1, "I",
                     ifelse(clin$stage == 2, "II",
                            ifelse(clin$stage == 3, "III",
                                   ifelse(clin$stage == 4, "IV", NA))))

# Assign 'tpm' and 'wes' values based on RNA_All and WES_All respectively.
clin$rna <- ifelse(clin_merge_data$RNA_All == 1, "tpm", NA)
clin$dna <- ifelse(clin_merge_data$WES_All == 1, "wes", NA)

# Calculate the response using Get_Response function.
clin$response = Get_Response(data = clin)

# Rename a few columns for clarity.
#colnames(clin)[colnames(clin) == "pfs"] <- "event_occurred_pfs"
#colnames(clin)[colnames(clin) == "t.pfs"] <- "survival_time_pfs"
#colnames(clin)[colnames(clin) == "patient"] <- "patientid"

# Additional Data Cleaning
clin$survival_unit <- "month"
clin$survival_type <- 'PFS/OS'
clin$tissueid <- "Lung"


# Reorder columns.
clin <- clin[, c(
  "patient", "sex", "age", "primary", "histo", "tissueid", "treatmentid", "stage", 
  "response.other.info", "recist", "response", "drug_type", "dna", "rna", "t.pfs", 
  "pfs", "t.os", "os", "survival_unit", "survival_type"
)]

# Use the format_clin_data function for further formatting.
clin <- format_clin_data(clin_merge_data, "patient", selected_cols, clin)

# Replace empty string values with NA.
clin[clin == ""] <- NA

# Save the processed data.
# save 'clin' as a CSV file called Ravi_clin
write.csv(clin , "C:/Users/sogol/OneDrive/Documents/BHK lab/Ravi/ICB_Ravi/data/CLIN.csv", row.names = FALSE)





