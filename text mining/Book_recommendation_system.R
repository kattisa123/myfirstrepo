# install.packages("SnowballC")
# install.packages("tm")
# install.packages("stringi")
# install.packages("stringr")
# install.packages("plyr")

library(SnowballC)
library(tm)
require("stringi")
library(stringr)
require(plyr)

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#
#%%%%%%%%%%%%%%%%%%%%# MAIN PART #%%%%%%%%%%%%%%%%%%%%%%%%%#
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#

#%%%%%%%%%%%%%# READING THE LEXICON #%%%%%%%%%%%%%%%%%%%%%%#

lexicon <- read.table("emotion-lexicon.txt")
colnames(lexicon) <- c("word","emotion","present")

# getting categories of emotions

categories <- levels(lexicon$emotion)
categories <- categories[!categories %in% c("negative","positive")]

# creating 10 separate lexiconicones for each emotion 
# (this loop creates 10 dataframes)

for (i in 1:length(categories)){
  
  # take words corresponding to this emotion
  
  tmp <- lexicon$word[lexicon$emotion==categories[i] & lexicon$present==1]
  tmp <- data.frame(tmp)
  
  # stem words 
  
  tmp$stem <- NA
  tmp$stem <- wordStem(as.character(tmp$tmp), language = "english")
  tmp <- unique(tmp$stem)
  
  # create a dataframe called by the name of the emotion
  
  assign(categories[i], tmp)
}


#%%%%%%%%%%%%%# READING THE TEXTS #%%%%%%%%%%%%%%%%%#

# all texts are in one file, each on next line
# respective titles are in the other file

fileName <- 'texts.txt'
texts <- readChar(fileName, file.info(fileName)$size)
texts <- unlist(strsplit(texts, "\r\n"))

fileName <- 'titles.txt'
titles <- readChar(fileName, file.info(fileName)$size)
titles <- unlist(strsplit(titles, "\r\n"))


#%%%%%%%%%%%%%# CLEANING THE TEXTS #%%%%%%%%%%%%%%%%%#

texts <- gsub("[\']", " ", texts)
texts <- gsub('[[:punct:]]', '', texts)
texts <- tolower(texts)

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#
#%%%%%%%%%%%%%# FUNCTIONS #%%%%%%%%%%%%%%%%%%%%%#

# receives 1 tokenized text and emotion
# gives out number of matches of that text with that emotion

find_matches <- function(words, emotion) {
  matches <- match(words, emotion)
  # match() returns the position of the matched term or NA
  # getting a sum of NOT NA:
  matches = sum(!is.na(matches))
  return(matches)
}

# receives the text, tokenizes it, stems, 
# gives the row of emotions for one text

emotion <- function(text) {
  
  # split into words
  
  word.list = str_split(text, '\\s+')
  words = unlist(word.list)
  
  # stemming
  
  words = wordStem(words, language = "english")
  
  # building "emotion row" - matches of each emotion for one text
  
  emotion_row <- NULL
  for (i in 1:length(categories)){
    emotion_row <- cbind(emotion_row, find_matches(words, get(categories[i])))
  }
  return(emotion_row)
  
}

# euclidean distance

euc.dist <- function(x1, x2) {
  sqrt(sum((x1 - x2) ^ 2))
}

#%%%%%%%%%%%%%# END FUNCTIONS #%%%%%%%%%%%%%%%%%#
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#


# applying emotion function to all texts to get length(texts) emotion rows
emo <- laply(texts, emotion)
# emo is the matrix with numbers of WORDS matched in each category
# lets normalize it
emo <- t(apply(emo, 1, FUN = function(x) {(x/sum(x)*100)}))

colnames(emo) <- categories
rownames(emo) <- titles
# now it looks beautiful!

#%%%%%%%%%%%%%# CREATING SAMPLE PROFILE #%%%%%%%%%%%%%%%%%#

# define user profile 

profile <- data.frame("anger"=2, "anticipation"=10, "disgust"=0, "fear"=4, "joy"=10, 
         "sadness"=3, "surprise"=6, "trust"=10)
profile[1,] <- profile[1,]/sum(profile[1,])*100


#%%%%%%%%%%%%%# CALCULATE DISTANCE #%%%%%%%%%%%%%%%%%#

dist.mat <- matrix(0, nrow = 1, ncol = length(texts))
for (i in 1:length(texts)) {
  dist.mat[1,i] <- euc.dist(profile, emo[i,])
}

# find the column number of the minimum distance

minValue = min(dist.mat) 
cols = which(apply(dist.mat,2,min)==minValue)

# this is going to be the text to recommend

cat("We recommend you to read \"",titles[cols],"\"")








#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#
#%%%%%%%%# EXTENSION - CALCULATING USER PROFILE #%%%%%%%%%%#
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#

# assume we know the id's of books user already read

user_read_these_books <- c(1,3)

# creating empty user profile

user_profile <- data.frame(matrix(,nrow=0, ncol=length(categories)))
colnames(user_profile) <- categories

# emo[user_read_these_books,] would be emotional profiles of the 
# books user read already. Calculating average emotions - this is user profile

user_profile <- colSums(emo[user_read_these_books,])/sum(colSums(emo[user_read_these_books,]))*100

# vector of indices of all books

all_books <- c(1:length(texts))

# vector of indices of books user didn't read yet
# (because we dont want to recommend the ones he did,
# although they clearly would match user profile)

user_didnt_read_these <- !(all_books %in% user_read_these_books)

#creating distance matrix  size 1*(books_not_read)

dist.mat <- matrix(0, nrow = 1, ncol = length(emo[user_didnt_read_these,][,1]))
for (i in 1:length(emo[user_didnt_read_these,][,1])) {
  dist.mat[1,i] <- euc.dist(user_profile, emo[user_didnt_read_these,][i,])
}

# find the column number of the minimum distance

minValue = min(dist.mat) 
cols = which(apply(dist.mat,2,min)==minValue)

# this is going to be the text to recommend

texts <- data.frame(cbind(titles, texts), stringsAsFactors = F)

cat("We recommend you to read \"",titles[user_didnt_read_these][cols],"\"")

