require(ggplot2)
library(dplyr)
dat_amd <- read.csv("../1998-amdk6.csv")
dat_intel <- read.csv("../2019-intel.csv")

amd_sat <- dat_amd[dat_amd$Sat!="INDETERMINATE",]
intel_sat <- dat_intel[dat_intel$Sat!="INDETERMINATE",]

amd_sat <- cbind(amd_sat, data.frame(CPU=rep("1998", nrow(amd_sat))))
intel_sat <- cbind(intel_sat, data.frame(CPU=rep("2019", nrow(intel_sat))))

dat_combined <- rbind(amd_sat, intel_sat)

dat_combined$ConflictsPerSecond <- dat_combined$Time*dat_combined$ConflictsPerSecond


ggplot(dat_combined[dat_combined$Time != 0 & dat_combined$ConflictsPerSecond != 0,], 
       aes(x=Time, y=ConflictsPerSecond, color=CPU)) + 
  geom_point() + scale_x_log10() + scale_y_log10() +
  ylab("Conflicts Per Second") +
  ggtitle("Conflicts Per Second")

sat_instances_table <- table(dat_combined[,c("Option", "CPU")])
sat_instances <- data.frame(sat_instances_table)

sat_instances$Freq <- as.numeric(sat_instances$Freq)
ggplot(sat_instances, aes(x=Option, fill=CPU, y=Freq)) + 
  geom_bar(stat="identity", position="dodge", width=0.7) +
  ggtitle("Total Completed Instances") + ylab("Instances") + 
  theme(axis.text.x=element_text(angle=45, hjust=1))

chisq.test(sat_instances_table)

ggplot(dat_combined, aes(x=Time, color=CPU)) +
  geom_density() + scale_x_log10() +
  ylab("Density") + ggtitle("SAT Runtime") + xlab("Time (seconds)")

log_amd <- log10(dat_combined[dat_combined$CPU==1998, "Time"])
log_amd <- log_amd[is.finite(log_amd)]
log_intel <- log10(dat_combined[dat_combined$CPU==2019, "Time"])
log_intel <- log_intel[is.finite(log_intel)]
wilcox.test(log_amd, log_intel)

amd_mediantimes <- dat_amd%>%group_by(Option)%>%summarise(Median=median(Time))
intel_mediantimes <- dat_intel%>%group_by(Option)%>%summarise(Median=median(Time))

ggplot(dat_combined[dat_combined$CPU=="2019",], aes(x=Time, color=Option)) +
  geom_density() + scale_x_log10() +
  ylab("Density") + ggtitle("SAT Runtime") + xlab("Time (seconds)")
