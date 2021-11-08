# Clean workspace and console.
cat("\014")
rm(list=ls())

#code for setting working directory and project paths
#setwd("")
#source('project_paths.R')

#load in packages
library(RSelenium)
library(rvest)
library(stringr)


#Launch firefox 
rD <- rsDriver(browser = "firefox", port=4545L, verbose = F)
remDr <- rD[["client"]]
ptm <- proc.time()
url<-"https://comments.ustr.gov/s/docket?docketNumber=USTR-2019-0017"

#open up url
remDr$open()
remDr$navigate(url)
Sys.sleep(10)

#pull out html code and number of pages on the html table to scrape
html <- remDr$getPageSource()[[1]]
html <- read_html(html)
numpages<-html %>% html_nodes("b~ b+ b") %>% html_text()
numpages<-as.numeric(numpages)


scrapeframe<-data.frame()

i=1
repeat{
#Extract html and read it to parse with rvest
html <- remDr$getPageSource()[[1]]
if (i==1){
  Sys.sleep(10)
}

html <- read_html(html)

#Found selectors with selectorgadget

#Grab all items of the table
subid<- html %>% 
  html_nodes(".slds-truncate a") %>% 
  html_text()

orgname <- html %>% 
  html_nodes("th+ td lightning-base-formatted-text") %>% 
  html_text()

status <- html %>% 
  html_nodes("td:nth-child(3) lightning-base-formatted-text") %>% 
  html_text()

hts <- html %>% 
  html_nodes("td:nth-child(4) lightning-base-formatted-text") %>% 
  html_text()

productdesc <- html %>% 
  html_nodes("td:nth-child(5) lightning-base-formatted-text") %>% 
  html_text()

posted <- html %>% 
  html_nodes("td:nth-child(6) lightning-formatted-date-time") %>% 
  html_text()

respclose <- html %>% 
  html_nodes("td:nth-child(7) lightning-formatted-date-time") %>% 
  html_text()

temp<-data.frame(subid, orgname, status, hts, productdesc, posted, respclose)

#create dataframe
scrapeframe<-rbind(scrapeframe, temp)

#now just double check for consistency of pages on html table
currentpage<-respclose <- html %>% 
  html_nodes("b:nth-child(2)") %>% 
  html_text()
currentpage<-as.numeric(currentpage)
if (i!=currentpage | i==numpages){
  if(i!=currentpage){
  print(paste0("Error on page ", currentpage))
  }
  break
}
i=i+1

#go to next page of table
nextbut <- remDr$findElement(using = 'css selector', ".slds-p-right_x-small .slds-button_neutral")
nextbut$clickElement()

#Making scraper more 'polite'
Sys.sleep(10)
print(i)
}

#save(scrapeframe,file=paste0(PATH_IN_DATA, "/scraped4a.Rda"))
