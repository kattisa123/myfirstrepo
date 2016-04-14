install.packages("stringdist")

library(devtools)
library(ngram)
library(reshape2)
library(stringdist)

surnames <- read.csv('app_c.csv', header = TRUE, stringsAsFactors = FALSE)
head(surnames)

sur_white <- surnames[1:10,c(1,6)]
head(sur_white)

# sur_white$new <- strsplit(sur_white[,1], "")
sur_white$new <- gsub("(.)", "\\1 \\2", sur_white[,1])

head(sur_white$new)

sur_white_new <- NULL


for (i in 1:length(sur_white[,3])){
  tmp <- ngram(sur_white[i,3], n=2)
  for (j in 1:length(get.ngrams(tmp))){
    sur_white_new <- rbind(sur_white_new, c(sur_white[i,1], get.ngrams(tmp)[j]))
  }
}

colnames(sur_white_new) <- c("surname", "bigram")
head(sur_white_new)

sur_white_new <- as.data.frame(sur_white_new)

sur_white_bin <- acast(sur_white_new, formula = surname ~ bigram, fun.aggregate = length)

sur_white[,4] <- phonetic(sur_white[,1])
colnames(sur_white) <- c("name", "pctwhite", "letters", "soundex")

sur_white_bin <- cbind(sur_white_bin, soundex = sur_white$soundex, percent = sur_white$pctwhite)
head(sur_white_bin)
