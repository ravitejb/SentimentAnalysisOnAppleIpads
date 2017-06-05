library(readxl) # to read the Excel
library(stringr) # to process strings
library(ggplot2) # for Plotting

# Read the data seperately
ipad2 <- read_excel("C:/Users/Tej/Desktop/Big_Data/Data_seperated.xlsx", sheet = "Apple iPad2")
ipad_air <- read_excel("C:/Users/Tej/Desktop/Big_Data/Data_seperated.xlsx", sheet = "Apple iPad AIR")
ipad3 <- read_excel("C:/Users/Tej/Desktop/Big_Data/Data_seperated.xlsx", sheet = "Apple iPad 3rd Gen")
ipad_mini <- read_excel("C:/Users/Tej/Desktop/Big_Data/Data_seperated.xlsx", sheet = "Apple iPad Mini")
ipad4 <- read_excel("C:/Users/Tej/Desktop/Big_Data/Data_seperated.xlsx", sheet = "Apple iPad 4th Gen")

#Take the summaries of the Data
sum1 = ipad2$summary
sum_air = ipad_air$summary
sum3 = ipad3$summary
sum_mini = ipad_mini$summary
sum4 = ipad4$summary

#Take the list of positive and negative words

posText <- read.delim("C:/Users/Tej/Desktop/Big_Data/positive-words.txt", header=FALSE, stringsAsFactors=FALSE)
posText <- posText$V1
posText <- unlist(lapply(posText, function(x) { str_split(x, "\n") }))
negText <- read.delim("C:/Users/Tej/Desktop/Big_Data/negative-words.txt", header=FALSE, stringsAsFactors=FALSE)
negText <- negText$V1
negText <- unlist(lapply(negText, function(x) { str_split(x, "\n") }))


all_iPads = c(sum1, sum_air, sum3, sum_mini, sum4)
all_lengths = c(length(sum1), length(sum_air), length(sum3), length(sum_mini), length(sum4))

#sentiment score function
score.sentiment = function(sentences, pos.words, neg.words, .progress='none')
{
  # Parameters
  # sentences: vector of text to score
  # pos.words: vector of words of positive sentiment
  # neg.words: vector of words of negative sentiment
  # .progress: passed to laply() to control of progress bar
  # create a simple array of scores with laply
  scores = laply(sentences,
                 function(sentence, pos.words, neg.words)
                 {
                   # remove punctuation
                   sentence = gsub("[[:punct:]]", "", sentence)
                   # remove control characters
                   sentence = gsub("[[:cntrl:]]", "", sentence)
                   # remove digits?
                   sentence = gsub('\\d+', '', sentence)
                   # define error handling function when trying tolower
                   tryTolower = function(x)
                   {
                     # create missing value
                     y = NA
                     # tryCatch error
                     try_error = tryCatch(tolower(x), error=function(e) e)
                     # if not an error
                     if (!inherits(try_error, "error"))
                       y = tolower(x)
                     # result
                     return(y)
                   }
                   # use tryTolower with sapply 
                   sentence = sapply(sentence, tryTolower)
                   # split sentence into words with str_split (stringr package)
                   word.list = str_split(sentence, "\\s+")
                   words = unlist(word.list)
                   # compare words to the dictionaries of positive & negative terms
                   pos.matches = match(words, pos.words)
                   neg.matches = match(words, neg.words)
                   # get the position of the matched term or NA
                   # we just want a TRUE/FALSE
                   pos.matches = !is.na(pos.matches)
                   neg.matches = !is.na(neg.matches)
                   # final score
                   score = sum(pos.matches) - sum(neg.matches)
                   return(score)
                 }, pos.words, neg.words, .progress=.progress )
  # data frame with scores for each sentence
  scores.df = data.frame(text=sentences, score=scores)
  return(scores.df)
}



scores = score.sentiment(all_iPads, posText,negText , .progress='text')
scores$all_iPads = factor(rep(c("ipad", "ipadair","ipad3","ipadmini","ipad4"), all_lengths))
scores$positive <- as.numeric(scores$score > 0)
scores$negative <- as.numeric(scores$score < 0)
scores$neutral <- as.numeric(scores$score == 0)


ipad2_scores <- subset(scores, scores$all_iPads=="ipad")
ipad_air_scores <- subset(scores,scores$all_iPads=="ipadair")
ipad3_scores <- subset(scores,scores$all_iPads=="ipad3")
ipad_mini_scores <- subset(scores, scores$all_iPads=="ipadmini")
ipad4_scores <- subset(scores,scores$all_iPads=="ipad4")

#Polarity Data
ipad2_scores$polarity <- ifelse(ipad2_scores$score > 0,"positive",ifelse(ipad2_scores$score < 0,"negative",ifelse(ipad2_scores$score==0,"Neutral",0)))
ipad_air_scores$polarity <- ifelse(ipad_air_scores$score > 0,"positive",ifelse(ipad_air_scores$score < 0,"negative",ifelse(ipad_air_scores$score==0,"Neutral",0)))
ipad3_scores$polarity <- ifelse(ipad3_scores$score > 0,"positive",ifelse(ipad3_scores$score < 0,"negative",ifelse(ipad3_scores$score==0,"Neutral",0)))
ipad_mini_scores$polarity <- ifelse(ipad_mini_scores$score > 0,"positive",ifelse(ipad_mini_scores$score < 0,"negative",ifelse(ipad_mini_scores$score==0,"Neutral",0)))
ipad4_scores$polarity <- ifelse(ipad4_scores$score > 0,"positive",ifelse(ipad4_scores$score < 0,"negative",ifelse(ipad4_scores$score==0,"Neutral",0)))

#Plotting the results
#For iPad2
qplot(factor(polarity), data=ipad2_scores, geom="bar", fill=factor(polarity))+xlab("Polarity Categories") + ylab("Frequency") + ggtitle("Customer Sentiments - Apple iPad 2") 
qplot(factor(score), data=ipad2_scores, geom="bar", fill=factor(score))+xlab("Sentiment Score") + ylab("Frequency") + ggtitle("Customer Sentiment Scores - Apple iPad 2")
#For iPad AIR
qplot(factor(polarity), data=ipad_air_scores, geom="bar", fill=factor(polarity))+xlab("Polarity Categories") + ylab("Frequency") + ggtitle("Customer Sentiments - Apple iPad AIR") 
qplot(factor(score), data=ipad_air_scores, geom="bar", fill=factor(score))+xlab("Sentiment Score") + ylab("Frequency") + ggtitle("Customer Sentiment Scores - Apple iPad AIR")
#For iPad3
qplot(factor(polarity), data=ipad3_scores, geom="bar", fill=factor(polarity))+xlab("Polarity Categories") + ylab("Frequency") + ggtitle("Customer Sentiments - Apple iPad 3") 
qplot(factor(score), data=ipad3_scores, geom="bar", fill=factor(score))+xlab("Sentiment Score") + ylab("Frequency") + ggtitle("Customer Sentiment Scores - Apple iPad 3")
#For iPad MINI
qplot(factor(polarity), data=ipad_mini_scores, geom="bar", fill=factor(polarity))+xlab("Polarity Categories") + ylab("Frequency") + ggtitle("Customer Sentiments - Apple iPad MINI") 
qplot(factor(score), data=ipad_mini_scores, geom="bar", fill=factor(score))+xlab("Sentiment Score") + ylab("Frequency") + ggtitle("Customer Sentiment Scores - Apple iPad MINI")
#For iPad4
qplot(factor(polarity), data=ipad4_scores, geom="bar", fill=factor(polarity))+xlab("Polarity Categories") + ylab("Frequency") + ggtitle("Customer Sentiments - Apple iPad 4") 
qplot(factor(score), data=ipad4_scores, geom="bar", fill=factor(score))+xlab("Sentiment Score") + ylab("Frequency") + ggtitle("Customer Sentiment Scores - Apple iPad 4")


#Summarizing Scores
df = ddply(scores, c("all_iPads"), summarise,
           pos_count=sum( positive ),
           neg_count=sum( negative ),
           neu_count=sum(neutral))
overall = colSums(df[,-1])
df$total_count = df$pos_count +df$neg_count + df$neu_count
df$pos_prcnt_score = round( 100 * df$pos_count / df$total_count )
df$neg_prcnt_score = round( 100 * df$neg_count / df$total_count )
df$neu_prcnt_score = round( 100 * df$neu_count / df$total_count )
overall$pos_ps = round( 100 * as.numeric(overall[1]) / sum(all_lengths))
overall$neg_ps = round( 100 * as.numeric(overall[2]) / sum(all_lengths))
overall$neu_ps = round( 100 * as.numeric(overall[3]) / sum(all_lengths))

#Comparison Charts
attach(df)
score_data <-paste(df$all_iPads,df$pos_prcnt_score)
score_data <- paste(score_data,"%",sep="")
pie(pos_prcnt_score, labels = score_data, col = rainbow(length(score_data)), main = "Positive Comparative Analysis - Apple iPads")


score_data <-paste(df$all_iPads,df$neg_prcnt_score)
score_data <- paste(score_data,"%",sep="")
pie(neg_prcnt_score, labels = score_data, col = rainbow(length(score_data)), main = " Negative Comparative Analysis - Apple iPads")
