# 5/29/14

#!/usr/bin/env Rscript

###### 
# This script will generate a plot of the reads sequenced per sample by phase
# input: 	file listing the lines of each fastq file for the DEP samples
# output: 	table of reads sequenced per sample 
#			plot of reads sequenced per sample
######

###### PARAMETERS ##########
# Set the parameters:
today <- Sys.Date()							# Set the date that will go on the end of the files generated by this script
today <- format(today, format="%m%d%y")
input.path <- c("../data/FC1/summaries/")	# path for all output to go into
#############################



##### Divide lines by 4:
lines <- read.table(file=paste(input.path, "lines_of_fastq_per_sample_052814ERD.txt", sep=""), sep="\n", header=FALSE)$V1

liners <- matrix(lines, ncol=2, byrow=TRUE)

liners[,1] <- gsub(".txt.gz", "", liners[,1])
liners[,2] <- as.numeric(liners[,2])/4
write.table(liners, paste("../results/1_general/reads_sequenced_per_sample_",today,"ERD.txt", sep=""), sep="\t", col.names=FALSE, row.names=FALSE, quote=FALSE)



##### Plot it up:
phase_cols <- function(sname) {
	if (grepl("phase1", sname)) {
		return("tomato")
	} else if (grepl("phase2", sname)) {
		return("orange")
	} else if (grepl("phase3", sname)) {
		return("darkolivegreen3")
	} else if (grepl("phase4", sname)) {
		return("lightblue")
	}
}

# sort by read depth:
sliners <- liners[order(as.numeric(liners[,2])),]

pdf(paste("../results/1_general/plot.sequencing.by.phase.",today,"ERD.pdf", sep=""))
barplot(as.numeric(sliners[,2]), col=sapply(sliners[,1], phase_cols), main="DEP sequencing by phase", xlab="sample", ylab="reads")
abline(h=median(as.numeric(sliners[grep("phase1", sliners[,1]),2])), col=sapply("phase1", phase_cols))
abline(h=median(as.numeric(sliners[grep("phase2", sliners[,1]),2])), col=sapply("phase2", phase_cols))
abline(h=median(as.numeric(sliners[grep("phase3", sliners[,1]),2])), col=sapply("phase3", phase_cols))
abline(h=median(as.numeric(sliners[grep("phase4", sliners[,1]),2])), col=sapply("phase4", phase_cols))
legend("topleft", legend=c("phase 1", "phase 2", "phase 3", "phase 4"), fill=sapply(c("phase1", "phase2", "phase3", "phase4"), phase_cols))

dev.off()
 
print("DONE!")
