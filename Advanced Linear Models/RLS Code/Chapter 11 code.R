
# latest on COVID-19 projections
https://www.newsobserver.com/news/coronavirus/article241782606.html

# UNC/Duke model
https://files.nc.gov/ncdhhs/documents/files/covid-19/NC-Covid-Brief-1-4-6-20.pdf

# latest on University of Washington model
http://www.healthdata.org/covid/updates

# Reprise part of chapter 10 analysis

# Section 10.10
library(faraway)
library(ggplot2)
library(lme4)
data(jsp)
# drop everything outside year 2
jspr=jsp[jsp$year==2,]

# multiple regression approach with gender removed

# remove gender
glin1=lm(math~raven*social,jspr)
# remove interaction
glin2=lm(math~raven+social,jspr)
summary(glin2)
anova(glin1,glin2)
# remove social
glin3=lm(math~raven,jspr)
summary(glin3)
anova(glin1,glin3)

# interaction is significant but gender isn't

# both raven and social class are significant

# problem with this analysis: ignores grouping of students into schools and classes


# random effects model
mmod=lmer(math~raven*social*gender+(1|school)+(1|school:class),data=jspr)
summary(mmod)


# eliminate gender, use KR test
mmodr=lmer(math~raven*social+(1|school)+(1|school:class),data=jspr)
library(pbkrtest)
KRmodcomp(mmod,mmodr)

# gender effect not significant

summary(mmodr)

# eliminate interaction, use KR test
mmodr2=lmer(math~raven+social+(1|school)+(1|school:class),data=jspr)
library(pbkrtest)
KRmodcomp(mmodr,mmodr2)
# interaction is significant


# new model with gender eliminated: use centered raven score
jspr$craven=jspr$raven-mean(jspr$raven)
mmod=lmer(math~craven*social+(1|school)+(1|school:class),jspr)
sumary(mmod)


# adjusted school effects
adjscores=ranef(mmod)$school[[1]]

# compare with raw scores for each school
rawscores=coef(lm(math~school-1,jspr))
rawscores=rawscores-mean(rawscores)
par(mfrow=c(1,1),cex=1.2)
plot(rawscores,adjscores,pch=20)
sint=c(9,14,29)
text(rawscores[sint],adjscores[sint]+0.2,c('9','15','30'))

#some schools show marked differences between raw and adjusted scores

# test for significance of school or class effects
mmodc=lmer(math~craven*social+(1|school:class),jspr)
mmods=lmer(math~craven*social+(1|school),jspr)
library(RLRsim)
exactRLRT(mmodc,mmod,mmods)
exactRLRT(mmods,mmod,mmodc)
# class effect marginal, school effect is definitely there

# final conclusion: 
#
# which school you went to does have an effect
#
# taking this into account, the main effects "raven" and "social" AND their interactions
# are all significant
#
# and
#
# school rankings are different if you use "adjusted scores"
#
# this is a major political issue in Britain!

# Introduction to chapter 11

library(faraway)
data(psid)
dim(psid)
psid[1:50,]

# 85 individuals, total 1661 observations

# show income plot for first 20 individuals
library(dplyr)
psid20=filter(psid,person<=20)
library(ggplot2)
ggplot(psid20,aes(x=year,y=income))+geom_line()+facet_wrap(~person)

# income changes grouped by sex (log scale)
ggplot(psid20,aes(x=year,y=income+100,group=person))+geom_line()+facet_wrap(~sex)+scale_y_log10()

# look at straight line fit for one individual
lmod=lm(log(income)~I(year-78),subset=(person==1),psid)
coef(lmod)


# now look at straight line fit for all subjects
library(lme4)
m1=lmList(log(income)~I(year-78)|person,psid)
intercepts=sapply(m1,coef)[1,]
slopes=sapply(m1,coef)[2,]

# verify: first elements of intercepts and slopes are single-individual model previously
print(c(intercepts[1],slopes[1]))

# plot slopes v. intercepts
plot(intercepts,slopes,xlab='Intercept',ylab='Slope')

# show slopes for M and F
psex=psid$sex[match(1:85,psid$person)]
boxplot(split(slopes,psex))

# show intercepts for M and F
boxplot(split(intercepts,psex))

# test equality of slopes for men and women
t.test(slopes[psex=='M'],slopes[psex=='F'])

# same for intercepts
t.test(intercepts[psex=='M'],intercepts[psex=='F'])

# show statistically significant differences in both cases

# up to this point: an example of "response feature analysis"

# now do a more comprehensive analysis including additional covariates
#
# this is where we need to take into account that we have repeated measures on each individual
#
# handle this by including a random effect for person

library(lme4)
psid$cyear=psid$year-78
mmod=lmer(log(income)~cyear*sex+age+educ+(cyear|person),psid)
sumary(mmod,digits=3)


# KR test for interaction term (no need to refit with REML=F as in text)
library(pbkrtest)
mmodr=lmer(log(income)~cyear+sex+age+educ+(cyear|person),psid)
KRmodcomp(mmod,mmodr)

# confidence intervals for all parameters (alternative to bootstrap test for random effects)
confint(mmod,method='boot')

# may want to repeat this - slight variation from one table to the next

# some diagnostics given in text - we omit that



# vision acuity example

library(faraway)
data(vision)

vision$npower=rep(1:4,14)
ggplot(vision,aes(y=acuity,x=npower,linetype=eye))+geom_line()+
  facet_wrap(~subject,ncol=4)+scale_x_continuous('Power',
                                                 breaks=1:4,label=c('6/6','6/18','6/36','6/60'))

# trends of response v. power are similar for left and right eyes for most individuals
#
# individual 6 may contain outliers

# mixed model: fixed effect of interest is power, random effect for individual
# and left/right eye modeled as nested within individual
mmod=lmer(acuity~power+(1|subject)+(1|subject:eye),vision)
sumary(mmod)

#correlation between measurements on same subject
4.64^2/(4.64^2+3.21^2+4.076^2)


#correlation between measurements on same eye
(4.64^2+3.21^2)/(4.64^2+3.21^2+4.076^2)

# KR test for power effect
library(pbkrtest)
nmod=lmer(acuity~(1|subject)+(1|subject:eye),vision)
KRmodcomp(nmod,mmod)

# rerun without obs. 43

mmodr=lmer(acuity~power+(1|subject)+(1|subject:eye),vision,subset=-43)
sumary(mmodr)
# KR test for power effect
library(pbkrtest)
nmodr=lmer(acuity~(1|subject)+(1|subject:eye),vision,subset=-43)
KRmodcomp(nmodr,mmodr)


# "Helmert contrasts"
op=options(contrasts=c("contr.helmert","contr.poly"))
mmodr=lmer(acuity~power+(1|subject)+(1|subject:eye),vision,subset=-43)

sumary(mmodr)

options(op)

# show how Helmert contrasts are computed
contr.helmert(4)

# interpretation here: only the highest power (level 4) is significantly 
# different from the others

# some diagnostics
plot(resid(mmodr)~fitted(mmodr),xlab='Fitted',ylab='Residuals')
abline(h=0)

qqnorm(ranef(mmodr)$"subject:eye"[[1]],main='')
# still one outlier corresponding to individual #6


# added at end of class - another way to model the random effects which appears to
# be equivalent

op=options(contrasts=c("contr.helmert","contr.poly"))
mmodr2=lmer(acuity~power+(eye|subject),vision,subset=-43)
summary(mmodr2)

# compare with mmodr

# The analyses are very similar but do not appear to be quite identical

# This may just be due to imperfections in the numerical fitting algorithm
