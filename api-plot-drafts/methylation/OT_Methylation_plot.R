#BiocManager::install("GenomicRanges")
#BiocManager::install("Gviz")
#BiocManager::install("BSgenome.Hsapiens.UCSC.hg19")
#BiocManager::install("IlluminaHumanMethylation450kanno.ilmn12.hg19")
#install.packages("RColorBrewer")
#BiocManager::install("plyranges")
#install.packages("reshape")
#BiocManager::install("IlluminaHumanMethylationEPICanno.ilm10b2.hg19")

library("GenomicRanges")
library("Gviz")
library(plyranges)
library(dplyr)


GTF_DATA = read.delim("../../../OpenPedCan-analysis/data/gencode.v39.primary_assembly.annotation.gtf.gz",header = F,skip = 5)


Methyl_ISOFORM_DATA = read.delim("/mnt/isilon/opentargets/wafulae/methylation-summary/results/isoform-methyl-beta-values-summary.tsv.gz")
#Methyl_GENE_DATA = read.delim("/mnt/isilon/opentargets/wafulae/methylation-summary/results/gene-methyl-beta-values-summary.tsv.gz")


### Test Parameters #
GENE_NAME = "BPTF"
GENE_NAME = "BPTF"
GENE_NAME = "ALK"
GENE_NAME = "B2M"
GENE_NAME = "CLK1"
Disease = "Neuroblastoma"
Disease = "High-grade glioma/astrocytoma"


TRANSCRIPT_pct_threshold = 10

### Test Parameters #

#### Function to generate plot####

GET_METHYLATION_PLOT = function(GENE_NAME, Disease = "Neuroblastoma", Dataset = "TARGET", TRANSCRIPT_pct_threshold =10)
{
  
  #Select Get Gene GTF information#'
  Custom_GENE_GTF = GTF_DATA[grep(paste("gene_name ",GENE_NAME,";",sep=""),GTF_DATA[,9]),]
  
  #Get GTF records with exon information#
  Custom_GENE_GTF_Exons =  Custom_GENE_GTF[grep("exon_id ENSE",Custom_GENE_GTF$V9),]
  
  
  #Get Information from GTF data necessary for GVIS Gene model visualization#
  custom_chromosome = as.character(unique(Custom_GENE_GTF_Exons$V1))
  custom_start = as.numeric(Custom_GENE_GTF_Exons$V4)
  custom_end = as.numeric(Custom_GENE_GTF_Exons$V5)
  custom_width = as.numeric(abs(as.numeric(custom_start) - as.numeric(custom_end)) +1)
  custom_strand = as.character(Custom_GENE_GTF_Exons$V7)
  custom_feature = as.character(Custom_GENE_GTF_Exons$V3)
  custom_gene = as.character(sapply(Custom_GENE_GTF_Exons$V9, function(X) strsplit(gsub("gene_id| ","",strsplit(X,split=";")[[1]][grep("gene_id ENSG",strsplit(X,split=";")[[1]])]),split="\\.")[[1]][1] ))     
  custom_exon = as.character(sapply(Custom_GENE_GTF_Exons$V9, function(X) strsplit(gsub("exon_id| ","",strsplit(X,split=";")[[1]][grep("exon_id ENSE",strsplit(X,split=";")[[1]])]),split="\\.")[[1]][1] ))     
  custom_transcript = as.character(sapply(Custom_GENE_GTF_Exons$V9, function(X) strsplit(gsub("transcript_id| ","",strsplit(X,split=";")[[1]][grep("transcript_id ENST",strsplit(X,split=";")[[1]])]),split="\\.")[[1]][1] ))     
  custom_symbol = as.character(sapply(Custom_GENE_GTF_Exons$V9, function(X) gsub("gene_name| ","",strsplit(X,split=";")[[1]][grep("gene_name ",strsplit(X,split=";")[[1]])]) ))  
  
  #Create Custom Gene model data frame for gene track visualization#
  Custom_Gene_Model = data.frame(chromosome = custom_chromosome,
                                 start = custom_start,
                                 end = custom_end,
                                 width = custom_width,
                                 strand = custom_strand,
                                 feature = custom_feature,
                                 exon = custom_exon,
                                 transcript = custom_transcript,
                                 symbol = custom_symbol)
  
  #Select only CDS and UTR data#
  Custom_Gene_Model_CDS.UTR = subset(Custom_Gene_Model,(feature %in% c("CDS","UTR")))
  
  #If the gene is non-coding, use exonic gene features#
  if(nrow(Custom_Gene_Model_CDS.UTR) == 0) Custom_Gene_Model_CDS.UTR = Custom_Gene_Model
  
  #Select gene transcripts for subsequent functions#
  custom_gene_transcripts = unique(custom_transcript)
  
  #Rename 'CDS' and 'UTR' to 'protein_coding' and 'utr5'/'utr3' which are recognizable by gviz#
  for(TRANSCRIPT in custom_gene_transcripts)  
  {
    if(unique(Custom_Gene_Model_CDS.UTR$strand)=="+")
    {
      UTR_MIN = min(Custom_Gene_Model_CDS.UTR[Custom_Gene_Model_CDS.UTR$transcript == TRANSCRIPT & Custom_Gene_Model_CDS.UTR$feature == "UTR","start"])
      UTR_MAX = max(Custom_Gene_Model_CDS.UTR[Custom_Gene_Model_CDS.UTR$transcript == TRANSCRIPT & Custom_Gene_Model_CDS.UTR$feature == "UTR","end"])
      
      Custom_Gene_Model_CDS.UTR$feature[Custom_Gene_Model_CDS.UTR$transcript == TRANSCRIPT & Custom_Gene_Model_CDS.UTR$feature == "UTR" & Custom_Gene_Model_CDS.UTR$start == UTR_MIN] <- "utr5"
      Custom_Gene_Model_CDS.UTR$feature[Custom_Gene_Model_CDS.UTR$transcript == TRANSCRIPT & Custom_Gene_Model_CDS.UTR$feature == "UTR" & Custom_Gene_Model_CDS.UTR$end == UTR_MAX] <- "utr3"
      Custom_Gene_Model_CDS.UTR$feature[Custom_Gene_Model_CDS.UTR$transcript == TRANSCRIPT & Custom_Gene_Model_CDS.UTR$feature == "CDS"] <- "protein_coding"
    }#if(unique(Custom_Gene_Model_CDS.UTR$strand)=="+")
    
    if(unique(Custom_Gene_Model_CDS.UTR$strand)=="-")
    {
      UTR_MIN = min(Custom_Gene_Model_CDS.UTR[Custom_Gene_Model_CDS.UTR$transcript == TRANSCRIPT & Custom_Gene_Model_CDS.UTR$feature == "UTR","start"])
      UTR_MAX = max(Custom_Gene_Model_CDS.UTR[Custom_Gene_Model_CDS.UTR$transcript == TRANSCRIPT & Custom_Gene_Model_CDS.UTR$feature == "UTR","end"])
      
      Custom_Gene_Model_CDS.UTR$feature[Custom_Gene_Model_CDS.UTR$transcript == TRANSCRIPT & Custom_Gene_Model_CDS.UTR$feature == "UTR" & Custom_Gene_Model_CDS.UTR$start == UTR_MIN] <- "utr3"
      Custom_Gene_Model_CDS.UTR$feature[Custom_Gene_Model_CDS.UTR$transcript == TRANSCRIPT & Custom_Gene_Model_CDS.UTR$feature == "UTR" & Custom_Gene_Model_CDS.UTR$end == UTR_MAX] <- "utr5"
      Custom_Gene_Model_CDS.UTR$feature[Custom_Gene_Model_CDS.UTR$transcript == TRANSCRIPT & Custom_Gene_Model_CDS.UTR$feature == "CDS"] <- "protein_coding"
    }#if(unique(Custom_Gene_Model_CDS.UTR$strand)=="-")
  }#for(TRANSCRIPT in custom_gene_transcripts)  
  

  #Subset methylation data based on gene, disease, cohort, and transcript percent threshold#
  Methylation_data_subset = Methyl_ISOFORM_DATA[which(Methyl_ISOFORM_DATA$Gene_symbol == GENE_NAME & Methyl_ISOFORM_DATA$Disease == Disease & Methyl_ISOFORM_DATA$Dataset== Dataset & Methyl_ISOFORM_DATA$Transcript_Representation >= TRANSCRIPT_pct_threshold),]
  

  #Include traascript percntages in annotation (parentheses)#
  Methylation_data_subset$transcripts = paste(Methylation_data_subset$transcript_id," (",round(Methylation_data_subset$Transcript_Representation),"%)",sep="")
  
  #Get transcript correlation data for correlation datatrack#
  Methylation_transcript_corr_Locations = sort(unique(Methylation_data_subset$Location))
  
  Methylation_transcript_corr = sapply(unique(Methylation_data_subset$transcript_id), function(X){
    
    Methylation_Transcript = Methylation_data_subset[which(Methylation_data_subset$transcript_id == X),]
    
    return(Methylation_Transcript$RNA_Correlation[match(Methylation_transcript_corr_Locations,Methylation_Transcript$Location)])
  })
  

  #Subset GTF trnascripts with transcripts available in methylation data#
  Custom_Gene_Model_CDS.UTR_subset = subset(Custom_Gene_Model_CDS.UTR,Custom_Gene_Model_CDS.UTR$transcript %in% Methylation_data_subset$transcript_id)
  
  #Add percent representation to gene model annotations#
  Custom_Gene_Model_CDS.UTR_subset$transcript_ID = Custom_Gene_Model_CDS.UTR_subset$transcript
  Custom_Gene_Model_CDS.UTR_subset$transcript = sapply(Custom_Gene_Model_CDS.UTR_subset$transcript_ID, function(X) unique(Methylation_data_subset$transcripts[which(Methylation_data_subset$transcript_id == X)]))
  
  
  #Create Gene model track#
  grtrack_custom <- GeneRegionTrack(Custom_Gene_Model_CDS.UTR_subset, genome = "hg38",
                                    chromosome = unique(Custom_Gene_Model_CDS.UTR_subset$chromosome), name = GENE_NAME,transcriptAnnotation = "transcript")
  
  #Create IdeogramTrack for chromosome#
  itrack <- IdeogramTrack(genome = "hg19", chromosome = custom_chromosome)
  
  #Create genome axis track for locus labeling#
  gtrack <- GenomeAxisTrack()
  
  
  #Get beta values for beta score track#
  Methylation_beta = t(sapply(Methylation_transcript_corr_Locations, function(X){
    
    #Methylation_data_subset[which(Methylation_data_subset$transcript_id == unique(Methylation_data_subset$transcript_id)[1]),"RNA_Correlation"]
    Methylation_Beta =   as.numeric(unique(Methylation_data_subset[which(Methylation_data_subset$Location == X),c("Beta_Q1","Beta_Median","Beta_Q5")]))
  
    return(Methylation_Beta)
  }))

  
  #Create Correlation GRanges object#
  Corr_Dataframe = data.frame(seqnames=custom_chromosome, start = Methylation_transcript_corr_Locations, end = Methylation_transcript_corr_Locations,strand = unique(Custom_Gene_Model_CDS.UTR$strand), Methylation_transcript_corr)
  Corr_DATA = makeGRangesFromDataFrame(Corr_Dataframe,keep.extra.columns = T)
  
  #Create beta score GRanges object#
  Beta_Dataframe = data.frame(seqnames=custom_chromosome, start = Methylation_transcript_corr_Locations, end = Methylation_transcript_corr_Locations,strand = unique(Custom_Gene_Model_CDS.UTR$strand), Methylation_beta)
  Beta_DATA = makeGRangesFromDataFrame(Beta_Dataframe,keep.extra.columns = T)
  
  #Generate data tracks#
  corr_all_Track <- DataTrack(Corr_DATA,start=Methylation_transcript_corr_Locations, end = Methylation_transcript_corr_Locations,genome = "hg38",chromosome = custom_chromosome, name = "Corr",groups = unique(Methylation_data_subset$transcript_id), type = c("a", "p", "confint"))
  Beta_DATA_Track <- DataTrack(Beta_DATA,start=Methylation_transcript_corr_Locations, end = Methylation_transcript_corr_Locations,genome = "hg38",chromosome = custom_chromosome, name = "Beta", type = c("a","confint"))

  return(plotTracks(list(itrack,gtrack,grtrack_custom,corr_all_Track,Beta_DATA_Track)))
  
}

GET_METHYLATION_PLOT("MYCN",Disease = "Neuroblastoma",Dataset = "TARGET",TRANSCRIPT_pct_threshold =10)
GET_METHYLATION_PLOT("ALK",Disease = "Neuroblastoma",Dataset = "TARGET",TRANSCRIPT_pct_threshold =10)
GET_METHYLATION_PLOT("BPTF",Disease = "Neuroblastoma",Dataset = "TARGET",TRANSCRIPT_pct_threshold =10)
GET_METHYLATION_PLOT("TP53",Disease = "Neuroblastoma",Dataset = "TARGET",TRANSCRIPT_pct_threshold =10)




