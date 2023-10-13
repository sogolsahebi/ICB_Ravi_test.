# File: MultiAssay Object Creation

# This file:
# - Loads and processes gene expression data.
# - Constructs a SummarizedExperiment using gene features and clinical data.
# - Manages clinical data columns (renaming and merging).
# - Aggregates all data into a MultiAssayExperiment.

# Install the BiocManager package to use Bioconductor packages
if (!requireNamespace("BiocManager", quietly = TRUE)) {
  install.packages("BiocManager")
}

# Load the GenomicRanges library into the R session
library(GenomicRanges)
library(SummarizedExperiment)
library(MultiAssayExperiment)

# 1. Extract and preprocess gene features (using Gencode.v19)
expr <- read.csv("C:/Users/sogol/OneDrive/Documents/BHK lab/Ravi/ICB_Ravi/data/EXPR.csv")
# Set the gene_id column ("X") as row names and remove it from the dataframe
rownames(expr) <- expr[,1]
expr <- expr[,-1]

# Load "Gencode.v19.annotation"
load("~/BHK lab/Ravi/annotation gencodes/Gencode.v19.annotation (2).RData")

# Filter rows in 'expr' using row names from 'features_gene'
assay <- expr[rownames(expr) %in% rownames(features_gene), ]
gene_ids <- rownames(assay)


# Sort the rows of 'assay'
assay <- assay[order(rownames(assay)), ]

# 2. Construct the row_ranges object for SummarizedExperiment
assay_genes <- as.data.table(features_gene[rownames(features_gene) %in% gene_ids, ])
assay_genes <- assay_genes[order(rownames(assay_genes)), ]
assay_genes[, gene_id_no_ver := gsub("\\..*$", "", gene_id)]
assay_genes[is.na(start), c("start", "end", "length", "strand") := list(-1, -1, 0, "*")]
assay_genes <- assay_genes[order(assay_genes$gene_id), ]

row_ranges <- makeGRangesFromDataFrame(assay_genes, keep.extra.columns=TRUE)
names(row_ranges) <- row_ranges$rownames

# 3. Load, rename, and merge clinical data
renamed_cols <- list(
  drug_type = "treatment",
  primary = "cancer_type",
  t.pfs = "survival_time_pfs",
  pfs = "event_occurred_pfs",
  t.os = "survival_time_os",
  os = "event_occurred_os",
  patient = "patientid"
)
added_cols <- c(
  "TMB_raw", "nsTMB_raw", "indel_TMB_raw", "indel_nsTMB_raw", 
  "TMB_perMb", "nsTMB_perMb", "indel_TMB_perMb", "indel_nsTMB_perMb",
  "CIN", "CNA_tot", "AMP", "DEL"
)

clin_cols <- c(
  "patient", "sex", "age", "primary", "histo", "tissueid", "treatmentid", "stage", 
  "response.other.info", "recist", "response", "drug_type", 
  "dna", "rna", "t.pfs", "pfs", "t.os", "os", 
  "survival_unit", "survival_type"
)

for(renamed_col in names(renamed_cols)){
  colnames(clin)[colnames(clin) == renamed_col] <- renamed_cols[[renamed_col]]
}
rownames(clin) = clin$patient

added_df <- as.data.frame(matrix(NA, nrow = nrow(clin), ncol = length(added_cols)))
colnames(added_df) <- added_cols

clin <- read.csv("C:/Users/sogol/OneDrive/Documents/BHK lab/Ravi/ICB_Ravi/data/CLIN.csv")
clin <- data.frame(cbind(clin[, clin_cols], added_df, clin[, !colnames(clin) %in% clin_cols]))
coldata = subset(clin, rna == "tpm")

# 4. Create the SummarizedExperiment objects
se_list <- list()
se_list[["expr"]] <- SummarizedExperiment(assays=list("expr"=assay), colData=coldata, rowRanges=row_ranges)

# 5. Extract and combine column data from SummarizedExperiment objects
cols <- list()
for(assay_name in names(se_list)){
  cols[[assay_name]] <- data.frame(colData(se_list[[assay_name]]))
}

allcols <- unique(unlist(lapply(cols, function(col) { return(rownames(col)) })))
coldata <- NA
for(col in cols){
  if(!is.data.frame(coldata)){
    coldata <- col
  }
  missing <- allcols[!allcols %in% rownames(coldata)]
  filtered <- col[rownames(col) %in% missing, ]
  if(nrow(filtered) > 0){
    coldata <- rbind(coldata, filtered)
  }
}
coldata <- coldata[order(rownames(coldata)), ]

# 6. Create the final MultiAssayExperiment object
result <- MultiAssayExperiment(experiments=se_list, colData=coldata)

# Save the result object to an RData file.
path <- "C:/Users/sogol/OneDrive/Documents/BHK lab/Ravi/ICB_Ravi/data/result.RData"
save(result, file = path)

#checking our result
check_coldata <- data.frame(colData(result))
check_rowdata <- data.frame(rowData(result@ExperimentList$expr))
check_expr <- assay(result)

dim(check_coldata)
dim(check_expr)
