#---
#title: "TAD1"
#output: html_document
#---
  
# Introduction and Workflow
  
### Kenneth Benoit
  
#This file demonstrates a basic workflow to take some pre-loaded texts and perform 
#elementary text analysis tasks quickly. The `quanteda` packages comes with a built-in set
#of inaugural addresses from US Presidents. We begin by loading quanteda and examining 
#these texts. The `summary` command will output the name of each text along with the 
#number of types, tokens and sentences contained in the text. Below we use R's indexing 
#syntax to selectivly use the summary command on the first five texts.

require(quanteda)

summary(data_corpus_inaugural)
summary(data_corpus_inaugural[1:5])

data_corpus_inaugural[1]
cat(data_corpus_inaugural[2])


ndoc(data_corpus_inaugural)
docnames(data_corpus_inaugural)

nchar(data_corpus_inaugural[1:7])
ntoken(data_corpus_inaugural[1:7])
ntoken(data_corpus_inaugural[1:7], remove_punct = TRUE)
ntype(data_corpus_inaugural[1:7])

#One of the most fundamental text analysis tasks is tokenization. 
#To tokenize a text is to split it into units, most commonly words, which can be counted 
#and to form the basis of a quantitative analysis. The quanteda package has a function 
#for tokenization: `tokens`, which constructs a **quanteda** tokens object consisting of 
#the texts segmented by their terms (and by default, other elements such as punctuation,
#numbers, symbols, etc.).  Examine the manual page at `?tokens` for this details about 
#this function:

?tokens

#**quanteda**'s `tokens` function can be used on a simple character vector, a vector of 
#character vectors, or a corpus. Here are some examples:
  
tokens('Today is Thursday in Canberra. It is yesterday in London.')

vec <- c(one = 'This is text one', 
         two = 'This, however, is the second text')
tokens(vec)

#Consider the default arguments to the `tokens()` function. 
#To remove punctuation, you should set the `remove_punct` argument to be `TRUE`. 
#We can combine this with the `char_tolower()` function to get a cleaned and tokenized 
#version of our text.

tokens(char_tolower(vec), remove_punct = TRUE)

#The way that `char_tolower()` is named reflects the [logic of **quanteda**'s 
#function grammar](http://quanteda.io/articles/pkgdown_only/design.html). 
#The first part (before the underscore `_`) names the both class of object that is input 
#to the function and is returned by the function.  To lowercase an R `character` class 
#object, for instance, you use `char_tolower()`, and to lowercase a **quanteda** `tokens` 
#class object, you use `tokens_tolower()`.  Some object classes are defined in base R, 
#and some have been defined by packages that extend R's functionality (**quanteda** is 
#one example -- there are [well over 10,000 contributed packages](https://cran.r-project.org/web/packages/) on the CRAN archive alone. 
#CRAN stands for Comprehensive R Archive Network and is where the **quanteda** package is published.)

#Using this function with the inaugural addresses:
  
inaugTokens <- tokens(data_corpus_inaugural, remove_punct = TRUE)
tokens_tolower(inaugTokens[2])    

#Here, we supplied one of the optional *arguments* to the `tokens()` function:`remove_punct`.  
#This functon takes a ["logical" type value](https://stat.ethz.ch/R-manual/R-devel/library/base/html/logical.html) (`TRUE` or `FALSE`) and 
#specifies whether punctuation characters should be removed or not. 
#The help page for `tokens()`, which you can access using the command `?tokens`, 
#details all of the function arguments and their valid values.  

#Every function in R and its contributed packages has a help page, and this is the first place to look when examining a function.  Well-written help pages will also contain examples that you can run to see how a function operates.  For **quanteda**, the main functions also have help pages with the results of executing their examples on http://quanteda.io/reference/.

#Returning to tokenization:
#Once each text has been split into words, we can use the `dfm` function to create a matrix of counts of the occurrences of each word in each document:
  
inaugDfm <- dfm(inaugTokens)
trimmedInaugDfm <- dfm_trim(inaugDfm, min_docfreq = 5, min_termfreq  = 10)
weightedTrimmedDfm <- dfm_tfidf(trimmedInaugDfm)

require(magrittr)

inaugDfm2 <- dfm(inaugTokens) %>% 
  dfm_trim(min_docfreq = 5, min_termfreq = 10) %>% 
  dfm_tfidf()

#Note that `dfm()` works on a variety of object types, including character vectors, corpus objects, and tokenized text objects.  This gives the user maximum flexibility and power, while also making it easy to achieve similar results by going directly from texts to a document-by-feature matrix.

#To see what objects for which any particular *method* (function) is defined, you can use the `methods()` function:

methods(dfm)


#If we are interested in analysing the texts with respect to some other variables, we can create a corpus object to associate the texts with this metadata. For example, consider the last six inaugural addresses:
  
summary(data_corpus_inaugural[52:57])

#We can use the `docvars` option to the `corpus` command to record the party with which each text is associated:
  
dv <- data.frame(Party = c('dem', 'dem', 'rep', 'rep', 'dem', 'dem'))

recentCorpus <- corpus(data_corpus_inaugural[52:57], docvars = dv)

summary(recentCorpus)

#We can use this metadata to combine features across documents when creating a document-feature matrix:

partyDfm <- dfm(recentCorpus, groups = 'Party', remove = (stopwords('english')))

                