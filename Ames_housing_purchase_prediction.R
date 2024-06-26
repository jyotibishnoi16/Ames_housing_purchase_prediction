## This code tries to build multiple Linear Regression Models based of combination of different variables to predict purchase of houses and identifies the best combination of such variables which predicts housing purchase with best accuracy


# load libraries
library(readxl)
library(dplyr)
library(ggplot2)
library(tidyr)
library(psych)
library(dlookr)
library(openxlsx)
library(tidyverse)
library(Hmisc)
library(flextable)

# load data
ames <- read_excel("ames.xlsx")

# summary
summary(ames)
DQ1 <- diagnose(ames)  #gives missing value number in each variable with percentage
DQC <- diagnose_category(ames) #gives levels & frequency in each level  in character variables
diagnose_numeric(ames) #gives summary of numeric variables along with outliers

DQ2 <- ames%>%
  diagnose()%>%  #finds count of missing values in dataset
  select(-unique_count, -unique_rate)%>%  #dropping the extra columns generated in diagnose command
  filter(missing_count>0)%>% #filtering variables having NA values more than 0
  arrange(desc(missing_count))   # arranging variables in descending order

DQ3 <- diagnose_outlier(ames)   #gives outliers in numeric variables along with ratio of utliers

DQ3_clean <- DQ3%>%
  filter(outliers_cnt>0)%>% #filters variables with more than 0 outliers
  arrange(desc(outliers_cnt))

plot(as.factor(ames$Overall.Cond))
table(ames$Overall.Cond)

# plot outliers for all the numeric variables in separate box plots & histograms 
plot_outlier(ames)

# box plot of numeric variables only
plot_box_numeric(ames, each=TRUE) 

# converting categorical ordinal into numeric.
ames1 <- ames
ames1[sapply(ames1, is.character)] <- lapply(ames1[sapply(ames1, is.character)], 
                                             as.factor)

# bar plot of character variables.
plot_bar_category(ames1, each=TRUE)
plot_bar_category(ames, each=TRUE)

# plot between sales price and no of houses with abline of mean sale price
hist(ames$Sale.Price, col="pink")
abline(v=median(ames$Sale.Price), col="red", Iwd=10)

#'[running summary of all character variables after converting them in factor]
ames_1 <- ames%>%
  mutate_if(is.character, as.factor)  #'*converting character variables into factor*
summary(ames_1)


#'[creating plots of few categorical variables
dq1 <-boxplot(ames$MS.SubClass)$out
dq7 <-boxplot(ames$BsmtFin.SF.1)$out
dq14 <-boxplot(ames$Gr.Liv.Area)$out
boxplot(ames$Year.Remod.Add)$out

qplot(ames$Sale.Price)
qplot(ames$Bedroom.AbvGr)
qplot(as.factor(ames$Bedroom.AbvGr))
boxplot(ames$Year.Built)$out

# DATA QUALITY ISSUES ADDRESSING

#'*DQ in overall.cond*
ames2 <- ames
ames2$Overall.Cond[ames2$Overall.Cond==999]<-9  #replacing 999 with 9
table(ames2$Overall.Cond)
boxplot(ames2$Overall.Cond)$out

#subsetting outliers

boxplot(ames1$Lot.Area)$out
ames1 <- ames1[ames$Lot.Area<32000,]
ames1 <- ames1[ames$Gr.Liv.Area<4000,]
ames1 <- ames1[ames$Lot.Frontage<150,]
boxplot(ames2$BsmtFin.SF.1)$out    #14 outliers found
ames1$BsmtFin.SF.1[ames1$BsmtFin.SF.1>1835]<-NA  #subsetting outliers
boxplot(ames$Gr.Liv.Area)$out
ames1$Gr.Liv.Area[is.na(ames1$Gr.Liv.Area)]<-mean(ames$Gr.Liv.Area, na.rm = TRUE)
boxplot(ames2$BsmtFin.SF.1)$out

#'*subsetting outliers in sale price*
ames$Sale.Price[ames$Sale.Price>600000] <- NA
boxplot(ames$Sale.Price)$out

# visualisation using ggplot

# plot between Gr.Liv Are ans sale price showing positive relation
ggplot(ames1)+
  geom_point(mapping=aes(Gr.Liv.Area, Sale.Price))+
  geom_smooth(mapping=aes(Gr.Liv.Area, Sale.Price))
             
# plot between bedroom number and mean sale price
ggplot(ames1)+
  geom_bar(mapping=aes(Bedroom.AbvGr, Sale.Price), stat="summary", fun.y="mean")

# plot between MS.Zoning and sale price grouped by MS.Subclass
ggplot(ames1, mapping=aes(MS.Zoning, Sale.Price, fill=MS.SubClass))+
         geom_bar(position="dodge", stat="identity")

# plot between MS.Zoning and sale price grouped by Street
ggplot(ames1, mapping=aes(MS.Zoning, Sale.Price, fill=Street))+
  geom_bar(position="dodge", stat="identity")

# plot between Lot.Frontage and mean sale price
ggplot(ames1, mapping=aes(Lot.Frontage, Sale.Price))+
  geom_point(mapping=aes(colour=Central.Air))

# plot between Lot.Area and sale price
ggplot(ames1)+
  geom_point(mapping=aes(Lot.Area, Sale.Price))+
  geom_smooth(mapping=aes(Lot.Area, Sale.Price))

# correlation between input and target variables
cor(ames$Lot.Area, ames$Sale.Price, use="complete.obs", method="pearson")

install.packages("corrplot")
library(corrplot)
  
get_corr_mat(ames1, "SalePrice")
cormat <- cor(ames_num, method="pearson")   #correlation matrix between numeric variable

# identify variables of your interest 
#'*("Gr.Liv.Area","Bsmt.Full.Bath","BsmtFin.SF.1","Garage.Area","Garage.Cars",*
#'   *"Total.Bsmt.SF","Bedroom.AbvGr","Enclosed.Porch","Fireplaces",*
#'   *"Full.Bath","Half.Bath","Kitchen.AbvGr","Lot.Area","MS.SubClass",*
#'  * "Open.Porch.SF","Overall.Cond","Sale.Price",*
#' *  "TotRms.AbvGrd","Year.Built")*

# removing NA values from Dataframe for select numeric variables
ames2 <- ames[!is.na(ames$Gr.Liv.Area),]
ames2 <- ames2[!is.na(ames2$Bsmt.Full.Bath),]
ames2 <- ames2[!is.na(ames2$BsmtFin.SF.1),]
ames2 <- ames2[!is.na(ames2$Garage.Area),]
ames2 <- ames2[!is.na(ames2$Garage.Cars),]
ames2 <- ames2[!is.na(ames2$Total.Bsmt.SF),]

#crete a subdata of select variables plus target variable

subdata <- ames2[c("Gr.Liv.Area","Bsmt.Full.Bath","BsmtFin.SF.1","Garage.Area","Garage.Cars",
                   "Total.Bsmt.SF","Bedroom.AbvGr","Enclosed.Porch","Fireplaces",
                   "Full.Bath","Half.Bath","Kitchen.AbvGr","Lot.Area","MS.SubClass",
                   "Open.Porch.SF","Overall.Cond","Sale.Price",
                   "TotRms.AbvGrd","Year.Built")]

# calculate correlation between these variables
cor <- cor(subdata)

# sort the above correlation data to keep the variables of interest as rows and target variable as a column
cor_sort <- as.matrix(sort(cor[,'Sale.Price'], decreasing = TRUE))

# plot a correlation matrix using corplot
corrplot(cor,diag=FALSE, tl.col = "black", tl.pos = "lt",order = "hclust",hclust.method = "complete",tl.srt = 45,
         mar = c(0,0,0,0), tl.cex = 0.35, tl.offset = 0.5)
#'*tl.cex for fontsize, diag=FALSE for central diagnol for corr of variable with itself*

# change subdata into matrix to run rcorr() function to find p values
mdata=as.matrix(ames2[c("Gr.Liv.Area","Bsmt.Full.Bath","BsmtFin.SF.1","Garage.Area","Garage.Cars",
                        "Total.Bsmt.SF","Bedroom.AbvGr","Enclosed.Porch","Fireplaces",
                        "Full.Bath","Half.Bath","Kitchen.AbvGr","Lot.Area","MS.SubClass",
                        "Open.Porch.SF","Overall.Cond","Sale.Price",
                        "TotRms.AbvGrd","Year.Built")])

rcorr(mdata)

# now calculate correlation between each of the above chosen numeric variable and Sale price
cor.test(ames2$Gr.Liv.Area, ames2$Sale.Price,use="complete.obs", method="pearson")
cor.test(ames2$Garage.Cars, ames2$Sale.Price,use="complete.obs", method="pearson")
cor.test(ames2$Garage.Area, ames2$Sale.Price,use="complete.obs", method="pearson")
cor.test(ames2$Total.Bsmt.SF, ames2$Sale.Price,use="complete.obs", method="pearson")
cor.test(ames2$Year.Built, ames2$Sale.Price,use="complete.obs", method="pearson")
cor.test(ames2$Fireplaces, ames2$Sale.Price,use="complete.obs", method="pearson")
cor.test(ames2$BsmtFin.SF.1, ames2$Sale.Price,use="complete.obs", method="pearson")
cor.test(ames2$Full.Bath, ames2$Sale.Price,use="complete.obs", method="pearson")
cor.test(ames2$TotRms.AbvGrd, ames2$Sale.Price,use="complete.obs", method="pearson")

# calculate Coefficient of determinstaion R Squared 
#'*gives proportion of variability by independent variable on dependent variable*

cor(ames2$Gr.Liv.Area, ames2$Sale.Price)^2*100
cor(ames2$Garage.Cars, ames2$Sale.Price)^2*100
cor(ames2$Garage.Area, ames2$Sale.Price)^2*100
cor(ames2$Total.Bsmt.SF, ames2$Sale.Price)^2*100
cor(ames2$Year.Built, ames2$Sale.Price)^2*100
cor(ames2$Fireplaces, ames2$Sale.Price)^2*100
cor(ames2$BsmtFin.SF.1, ames2$Sale.Price)^2*100
cor(ames2$Full.Bath, ames2$Sale.Price)^2*100
cor(ames2$TotRms.AbvGrd, ames2$Sale.Price)^2*100

# calculate correlation between chosen character variable and sale price
cor(ames1$MS.SubClass, ames1$Sale.Price, method="spearman")

###### trial run ###############################
#'*running correlation between all 80 variables to filter out variables*
#'*before running correlation categorical variables are converted into factor*
ames2[sapply(ames2, is.character)] <- lapply(ames2[sapply(ames2, is.character)], 
                                             as.factor)

#'*since correlation function will not work for stringed nominal variables, we need to*
#'#'*convert them into numeric factors using unclass() function*
ames2 <- sapply(ames2, unclass)
str(ames2)
class(ames2)

#'*unclass() function will give a matrix on which cor() will not work hence change it to dataframe*
ames2 <- as.data.frame(ames2)

# subdata 1 to 4 forms subset of data between variables in sets of 20 approx
#subdata 5 forms subset of data between all 80 variables
subdata1 <- ames2[c(2,3,5,6,8,9,10,11,12,13,14,15,16,17,18,19,20,80)]
subdata2 <- ames2[c(21,22,23,24,25,28,29,30,35,37,38,39,40,41,42,43,80)]
subdata3 <- ames2[c(44,45,46,47,48,49,50,51,52,53,54,55,56,57,63,64,80)]
subdata4 <- ames2[c(65,67,68,69,70,71,72,73,76,77,78,79,80)]
subdata5 <- ames2[c(2:80)]

# calculate correlation between these variables
# cor1 to 4 calculates corr between variables in sets of 20 approx
# cor5 calculates corr between all 80 variables
cor1 <- cor(subdata1)
cor2 <- cor(subdata2)
cor3 <- cor(subdata3)
cor4 <- cor(subdata4)
cor5 <- cor(subdata5)

cor5 <- as.data.frame(cor5) #converting cor5 into dataframe so that we can write it in excel

# now sort this to keep the variables of interest as rows and target variable as a column
cor_sort1 <- as.matrix(sort(cor1[,'Sale.Price'], decreasing = TRUE))
cor_sort2 <- as.matrix(sort(cor2[,'Sale.Price'], decreasing = TRUE))
cor_sort3 <- as.matrix(sort(cor3[,'Sale.Price'], decreasing = TRUE))
cor_sort4 <- as.matrix(sort(cor4[,'Sale.Price'], decreasing = TRUE))
cor_sort5 <- as.matrix(sort(cor5[,'Sale.Price'], decreasing = TRUE))
cor_sort5 <- as.data.frame(cor_sort5)  #converting into dataframe to write into excel

# plot a correlation matrix using corplot

corrplot(cor1,diag=FALSE, tl.col = "black", tl.pos = "lt",order = "hclust",hclust.method = "complete",tl.srt = 45,
         mar = c(0,0,0,0), tl.cex = 0.35, tl.offset = 0.5)
corrplot(cor2,diag=FALSE, tl.col = "black", tl.pos = "lt",tl.srt = 45,
         mar = c(0,0,0,0), tl.cex = 0.35, tl.offset = 0.5)
corrplot(cor3,diag=FALSE,method = "number", tl.col = "black", tl.pos = "lt",order = "hclust",hclust.method = "complete",tl.srt = 45,
         mar = c(0,0,0,0), tl.cex = 0.35, tl.offset = 0.5,number.cex = 0.7)
corrplot(cor4,diag=FALSE, tl.col = "black", tl.pos = "lt",tl.srt = 45, mar = c(0,0,0,0), tl.cex = 0.35, tl.offset = 0.5)
#'*tl.cex for fontsize, diag=FALSE for central diagnol for corr of variable with itself*

# after checking correlation between all 79 variables against sale price following variabes are chosen
subdata6 <- ames2[c("Overall.Qual","Year.Built","Year.Remod.Add","Exter.Qual","Foundation",
                    "BsmtFin.SF.1","Total.Bsmt.SF","Heating.QC","X1st.Flr.SF","Gr.Liv.Area",
                    "Full.Bath","TotRms.AbvGrd","Fireplaces","Garage.Cars","Garage.Area")]

# run a correlation matrix between these variables
cor6 <- cor(subdata6)
cor6 <- as.data.frame(cor6)

# plot the above correlation matrix
corrplot(cor6,diag=FALSE, method="number",tl.col = "black", tl.pos = "lt",order = "hclust",hclust.method = "complete",tl.srt = 45,
         mar = c(0,0,0,0), tl.cex = 0.35, tl.offset = 0.5, number.cex = 0.5)

# REGRESSION MODELS ###

# split the data
library(caret)
set.seed(40385928) #'*to run random repetition*

# address any formatting or DQ
# kch$condition <- as.factor(kch$condition)

#'*splitting to be done based on taret variable, times=1 gives one set of data*
index <- createDataPartition(ames2$Sale.Price, times=1, p=0.8, list=FALSE)
#'*list=FALSE tells caret to return numeric vector rather thana list*

train <- ames2[index,]
test <- ames2[-index,]

#'*MODEL I*
formula <- Sale.Price~Overall.Qual+Full.Bath+Kitchen.Qual
model <- lm(formula=formula, data=train)

# model <- lm(price~sqft_living+condition+bathrooms, data=train)
summary(model)

# run the model on test data set
predict <- predict(model, test)
postResample(predict,test$Sale.Price)
test$predict <- predict

# plot the residuals
diag <- train
diag$residuals <- resid(model)
plot(diag$residuals)

#'*MODEL II*
formula1 <- Sale.Price~Gr.Liv.Area+Exter.Qual+BsmtFin.SF.1
model1 <- lm(formula=formula1, data=train)
summary(model1)

# run the model on test data set
predict1 <- predict(model1, test)
postResample(predict1,test$Sale.Price)
test$predict1 <- predict1

# plot the residuals
diag1 <- train
diag1$residuals <- resid(model1)
plot(diag1$residuals)
test_df <- as.data.frame(test)

#'*MODEL III*
formula2 <- Sale.Price~Garage.Area+X1st.Flr.SF+Fireplaces
model2 <-lm(formula=formula2, data=train)
summary(model2)

# run the model on test data set
predict2 <- predict(model2, test)
postResample(predict2,test$Sale.Price)
test$predict2 <- predict2

#plot the residuals
diag2 <- train
diag2$residuals <- resid(model2)
plot(diag2$residuals)

#'*MODEL IV*
  formula3 <- Sale.Price~Total.Bsmt.SF+TotRms.AbvGrd+Foundation
model3 <- lm(formula=formula3, data=train)
summary(model3)

# run the model on test data set
predict3 <- predict(model3, test)
postResample(predict3,test$Sale.Price)
test$predict3 <- predict3

#plot the residuals
diag3 <- train
diag3$residuals <- resid(model3)
plot(diag3$residuals)

#'*MODEL V*
formula4 <- Sale.Price~Year.Remod.Add+X1st.Flr.SF+Fireplaces
model4 <- lm(formula=formula4, data=train)
summary(model4)

# run the model on test data set
predict4 <- predict(model4, test)
postResample(predict4,test$Sale.Price)
test$predict4 <- predict4

#plot the residuals
diag4 <- train
diag4$residuals <- resid(model4)
plot(diag4$residuals)


#### MULTIPLE REGRESSION- MASTER MODEL ######

formula5 <- Sale.Price ~ Overall.Qual + Gr.Liv.Area + Garage.Area+Total.Bsmt.SF + Full.Bath+Year.Remod.Add + Fireplaces + BsmtFin.SF.1 + Foundation + Kitchen.Qual
model5 <- lm(formula=formula5, data=train)
summary(model5)

# run the model on test data set
predict5 <- predict(model5, test)
postResample(predict5,test$Sale.Price)
test$predict5 <- predict5

# plot the residuals
diag5 <- train
diag5$residuals <- resid(model5)
plot(diag5$residuals)

############## Assumption Checking ############
# It is necessary to check whether assumptions have been violated
# Violation of assumptions can make it questionable to generalise a model to the population
# However, they do not necessarily reduce predictive accuracy (we use a seperate test set to test this)

# linear regression relies on several assumptions:
#1. No non-zero variance predictors
#2. No perfect Multicolinearity
#3. Homoscedasticity of residuals
#4. Normally Distributed residuals
#5. Independent Residuals
#6. Influential Cases

# the following code demonstrates how to check these assumptions

# 1. Identifying zero variance predictors
# you would spot any non-zero variance predictors from the summary stats as the variable will contain only one value
summary(model5)

# 2. Checking for multicollinearity - check if any VIF > 3
install.packages("car")
library(car)
vif(model5)

# 3. Homoscedasticity - check if the residual plot looks like a random spread of points
# we don't want to see any sort of pattern e.g. 'fanning out' pattern
plot(model5) # the first plot shows the residuals against fitted values

# 4. Normally distributed residuals - check Q-Q residual plot - if normal, the points should be on the dotted line
plot(model5) # the second plot shows residuals against the normal distribution

# 5. Independent residuals - run the durban watson test: between 1.5 and 2.5 is ok
install.packages("lmtest")
library(lmtest)
dwtest(model5)

# 6. Influential cases - check cooks distance: >1 indicates a point is exerting too much influence on the regression line
cook<- cooks.distance(model5)
sum(cook > 1)



###### END #####
