#!/usr/bin/env Rscript

###### 
# This script will do a lmm for the DEP samples, with rank as a fixed effect and run as a random effect. This is for each phase individually.
# usage: ./lmm_DEP_all_taxa_each_phase_110314ERD.R
# input: 	abundance tables
#			table of possible confounders
# output: 	table of pvalues and qvalues for associations
#			histogram of p-values
######

###### PARAMETERS ##########
# Set the parameters:
today <- Sys.Date()							# Set the date that will go on the end of the files generated by this script
today <- format(today, format="%m%d%y")
input.path <- c("../results/3_data/")	
#############################



##### Load libraries:
suppressWarnings(suppressMessages(library("lme4")))
suppressWarnings(suppressMessages(library("qvalue")))
options(warn=2)


##### Read in table of covariates:
covs1 <- read.table(file=paste0(input.path, "table_covariates_DEP_103114ERD.txt"), sep="\t", header=TRUE)
# Change phase 4ish to phase 4:
covs1$Phase[grep("4ish", covs1$Phase)] <- "phase_4"



##### Do models for rank for each bacteria, each phase:
for (p in c("phase_1", "phase_2", "phase_3", "phase_4")) {
	print(p)
	assocs <- c()
	for (a in c("phylum", "class", "order", "family", "genus")) {
		print(a)
		taxa <- read.table(file=paste0(input.path, "table_DEP_standardized_abundances_",a,"_103014ERD.txt"), sep="\t", header=TRUE)
		
		# Examine only the relevant phase: 
		taxa <- taxa[,grep(p, covs1$Phase)]
		covs <- covs1[grep(p, covs1$Phase),]
	
		for (i in 1:dim(taxa)[1]) {
			# If the bacteria isn't in more than 1 person, skip to next:
			if (length(which(taxa[i,] != 0)) < 2) {
				next
			}
			bacteria <- rownames(taxa)[i]
			
			# If there is an error in the model, null, or LRT, then just don't run it:
			mytry <- try(nullmodel <- lmer(as.numeric(taxa[i,]) ~ (1|as.factor(covs$Run)), REML=FALSE), silent=TRUE)
			mytry2 <- try(mymodel <- lmer(as.numeric(taxa[i,]) ~ as.numeric(covs$Rank) + (1|as.factor(covs$Run)), REML=FALSE), silent=TRUE)
			mytry3 <- try(mylrt <- anova(nullmodel,mymodel), silent=TRUE)
			
			if ('try-error' %in% c(class(mytry), class(mytry2), class(mytry3))) {
				next
    		} else {
				mylrtp <- mylrt$"Pr(>Chisq)"[2]
				assocs <- rbind(assocs, c(bacteria, p, mylrtp))
			}
		}
	}

	qvalues <- qvalue(as.numeric(assocs[,3]))$qvalue
	assocs <- cbind(assocs, qvalues)
	colnames(assocs) <- c("bacteria", "phase", "pvalue", "qvalue")
	write.table(assocs, paste0("../results/6_lmm_phase/table_p_and_q_values_lmm_",p,"_",today,"ERD.txt"), sep="\t", row.names=FALSE, quote=FALSE)


	pdf(paste0("../results/6_lmm_phase/hist_lmm_pvalues_",p,"_",today,"ERD.pdf"))
	hist(as.numeric(assocs[,3]), col="gray", main="LMM pvalues")
	dev.off()
}

print("DONE!")