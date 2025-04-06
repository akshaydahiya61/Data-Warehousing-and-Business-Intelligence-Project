#install.packages("rvest")
#install.packages("xml2")
#install.packages("xlsx")
#Sys.setenv(JAVA_HOME='C:\\Program Files (x86)\\Java\\jre1.8.0_231') # for 64-bit version
# install.packages("odbc")
# install.packages("dplyr")
#library(rJava)
library(rvest)
#library(xml2)
#library(xlsx)
library(dplyr)
library(odbc)
library(DBI)


#################################################################################
###### Webscraping the Company data data 
url <- "https://www.ft.com/content/238174d2-3139-11e9-8744-e7016697f225" 
page <- read_html(url) #Creates an html document from URL
table <- html_table(page, fill = TRUE) #

company<-table[[1]]

names(company)[7] <- "Revenue_growth_2013-19(%)"
names(company)[8] <- "CAGR_2013-19(%)"
names(company)[9] <- "Revenue2019"
names(company)[10] <- "Employee_growth2013-19(%)"
names(company)[11] <- "Employees_2019"
names(company)[12] <- "Founded"

company$Employees_2019 = as.numeric(company$Employees_2019) 


company[,c(3,4)] <- NULL 

####################################################################################
### debt Data cleaning
debt <- read.csv("C:/Users/AkshayDahiya/Documents/Ireland/College NCI/DW Final Project/Europe_DW/Europ_GDP/csv/debt.csv")

debt_final <- cbind(1:nrow(debt),debt)
colnames(debt_final)[1] <- "Country_Code"

###################################################################################
#### Joinig The debt to company
company_final <- inner_join(company, debt_final, by = c("Country"))

company_final$Country <- NULL
company_final$NationaldebtinrelationtoGDP <- NULL


##################################################################################
#### Joinig The debt to economy

economy <- read.csv("C:/Users/AkshayDahiya/Documents/Ireland/College NCI/DW Final Project/Europe_DW/Europ_GDP/csv/economy.csv")
economy_Final <- inner_join(economy, debt_final, by = c("Country"))


economy_Final$Country <- NULL
economy_Final$NationaldebtinrelationtoGDP <- NULL



#####################################################################################
#### Joinig The debt to eu_population


eu_population <- read.csv("C:/Users/AkshayDahiya/Documents/Ireland/College NCI/DW Final Project/Europe_DW/Europ_GDP/csv/eu_population.csv")

# 
# colnames(eu_population)[3] <- "PercentoftotalEUpop"
# colnames(eu_population)[4] <- "Totalareakm2"
# colnames(eu_population)[5] <- "PercentoftotalEUarea"
# colnames(eu_population)[6] <- "Pop..densityPeoplekm2"
# 
# write.table(eu_population, file = "C:/Users/AkshayDahiya/Documents/Ireland/College NCI/DW Final Project/Europe_DW/Europ_GDP/csv/eu_population.csv",row.names=FALSE, na="", sep=",")

eu_population_final <- inner_join(eu_population, debt_final, by = c("Country"))

eu_population_final$Country <- NULL
eu_population_final$NationaldebtinrelationtoGDP <- NULL


#####################################################################################
#### Joinig The debt to council


council <- read.csv("C:/Users/AkshayDahiya/Documents/Ireland/College NCI/DW Final Project/Europe_DW/Europ_GDP/csv/council.csv")

council_final <- inner_join(council, debt_final, by = c("Country"))

council_final$Country <- NULL
council_final$NationaldebtinrelationtoGDP <- NULL


#write.table(council_final, file = "C:/Users/AkshayDahiya/Documents/Ireland/College NCI/DW Final Project/Europe_DW/Europ_GDP/csv/council.csv",row.names=FALSE, na="", sep=",")

#####################################################################################
######## Connection to SQL Database
con <- DBI::dbConnect(odbc::odbc(), 
                      Driver = "SQL Server", 
                      Server = "localhost\\SQLEXPRESS", 
                      Database = "europe_raw", 
                      Trusted_Connection = "True")

#####################################################################################
#### Removing the table or lodaing the raw data

if(dbExistsTable(con, "company_raw")){
  dbRemoveTable(con, "company_raw")
  dbWriteTable(con, "company_raw", company_final)
}else{
  dbWriteTable(con, "company_raw", company_final)
}
if(dbExistsTable(con, "council_raw")){
  dbRemoveTable(con, "council_raw")
  dbWriteTable(con, "council_raw", council_final)
}else{
  dbWriteTable(con, "council_raw", council_final)
}
if(dbExistsTable(con, "debt_raw")){
  dbRemoveTable(con, "debt_raw")
  dbWriteTable(con, "debt_raw", debt_final)
}else{
  dbWriteTable(con, "debt_raw", debt_final)
}
if(dbExistsTable(con, "economy_raw")){
  dbRemoveTable(con, "economy_raw")
  dbWriteTable(con, "economy_raw", economy_Final)
}else{
  dbWriteTable(con, "economy_raw", economy_Final)
}
if(dbExistsTable(con, "eu_population_raw")){
  dbRemoveTable(con, "eu_population_raw")
  dbWriteTable(con, "eu_population_raw", eu_population_final)
}else{
  dbWriteTable(con, "eu_population_raw", eu_population_final)
}