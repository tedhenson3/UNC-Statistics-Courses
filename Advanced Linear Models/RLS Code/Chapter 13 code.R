
# Rcode for Section 13.3: balance and vision data
library(faraway)
library(ggplot2)
data (ctsib)


dim(ctsib)
ctsib[1:30,]

ctsib[12*(1:40),]

# 40 individuals each measured 12 times:
#   2 standing positions (normal or foam)
#   3 types of vision (eyes open, eyes closed, dome over head)
#   2 measurements in each combination
#   measurements codes 1-4, but recorded 0 or 1 for this analysis 
#   0 means not stable, 1 means stable

ctsib$stable=ifelse(ctsib$CTSIB==1,1,0)
xtabs(stable~Surface+Vision,ctsib)/80

library(dplyr)
subsum=ctsib %>% group_by(Subject) %>% summarise(Height=Height[1],
                                                 Weight=Weight[1], stable=mean(stable), Age=Age[1], Sex=Sex[1])
library(ggplot2)
ggplot(subsum,aes(x=Height,y=stable))+geom_point()

ggplot(subsum,aes(x=Weight,y=stable))+geom_point()

ggplot(subsum,aes(x=Age,y=stable))+geom_point()

ggplot(subsum,aes(x=Sex,y=stable))+geom_boxplot()

# fit model ignoring within-subject correlations
gf=glm(stable~Sex+Age+Height+Weight+Surface+Vision,binomial,data=ctsib)
summary(gf)

# Two variants on the fixed effects model don't help

gf1=glm(stable~Sex+Age+Height+Weight+Surface+Vision,quasibinomial,data=ctsib)
summary(gf1)
# not really any different

gf2=glm(stable~Sex+Age+Height+Weight+Surface+Vision+factor(Subject),binomial,data=ctsib)
summary(gf2)
# too much confounding - esstimates don't make any sense

# glmm1: pql method
library(MASS)
modpq1=glmmPQL(stable~Sex+Age+Height+Weight+Surface+Vision,random=~1|Subject,
               family=binomial, data=ctsib)
summary(modpql)

# conclusions from this model: strongly significant surface and vision effects,
# others marginal

# now use lme4 package

library(lme4)
modlap=glmer(stable~Sex+Age+Height+Weight+Surface+Vision+(1|Subject),binomial,data=ctsib)
summary(modlap)

library(lme4)
modgh=glmer(stable~Sex+Age+Height+Weight+Surface+Vision+(1|Subject),nAGQ=25,
            binomial,data=ctsib)
summary(modgh)

# all three random effects models so far give similar answers

# Are subject-specific effects significant?

modgh2=glmer(stable~Surface+Vision+(1|Subject),nAGQ=25,binomial,data=ctsib)
summary(modgh2)
anova(modgh,modgh2)

# the text says "We have the same reasons as with LMMs to view these results with some
# scepticism" - I assume they are referring to the failure of the chi-square approximation
# in many instances

# try a bootstrap but this doesn't seem to work
T1=Sys.time()
nsim=10
blrt=rep(NA,nsim)
for(i in 1:nsim){
  y=unlist(simulate(modgh2))
  sum(y)
  modgh2b=refit(modgh2,y)
  modghb=refit(modgh,y)
  blrt[i]=2*(summary(modghb)$logLik-summary(modgh2b)$logLik)
}
T2=Sys.time()
T2-T1



# some diagnostics
dd=fortify(modgh2)
ggplot(dd,aes(sample=.resid))+stat_qq()+facet_grid(Surface~Vision)

library(INLA)
formula=stable~Surface+Vision+f(Subject,model='iid')
result=inla(formula,family='binomial',data=ctsib)


### some exploration of what "result" really contains (not in the next)

names(result)

# some of these variables are self-contained arrays or tables, for example

result$summary.fixed

result$summary.hyperpar

# others are complocated objects in their own right, for example

names(result$marginals.fixed)

# let's try one of these out

d1=result$marginals.fixed$"Visionopen"
plot(d1,type='l',main='Posterior density for Visionopen')

plot(d1,type='l',main='Posterior density for Visionopen',xlim=c(3,10))

# Here's another one

d1=result$marginals.fixed$"Visiondome"
plot(d1,type='l',main='Posterior density for Visiondome')

plot(d1,type='l',main='Posterior density for Visiondome',xlim=c(-1,2.5))

# And another: 
names(result$marginals.random)

names(result$marginals.random$Subject)

d1=result$marginals.random$Subject$index.34
plot(d1,type='l',main='Posterior Density for Subject 34')
plot(d1,type='l',main='Posterior Density for Subject 34',xlim=c(-5,5))


names(result$marginals.hyperpar)
d1=result$marginals.hyperpar$"Precision for Subject"
plot(d1,type='l',main='Posterior for Subject Effect Precision')
plot(d1,type='l',main='Posterior for Subject Effect Precision',xlim=c(0,0.4))

# get some summary statistics as follows

result$summary.hyperpar

# find posterior median of subject SD
1/sqrt(0.1140657)

# compare with
summary(modgh2)$varcor

### end of "exploration"

# now let's see what Faraway does


sigmaalpha=inla.tmarginal(function(x) 1/sqrt(x),result$marginals.hyperpar$"Precision for Subject")
# this is posterior density for sigma in correct scaling 

x=seq(0,7,length.out=100)
sdf=data.frame(yield=x,density=inla.dmarginal(x,sigmaalpha))
library(ggplot2)
ggplot(sdf,aes(x=yield,y=density))+geom_line()

restab=sapply(result$marginals.fixed,function(x) inla.zmarginal(x,silent=TRUE))
restab=cbind(restab,inla.zmarginal(sigmaalpha,silent=TRUE))
colnames(restab)=c("mu","norm","dome","open","alpha")
data.frame(restab)

x=seq(-2,11,length.out=100)
rden=sapply(result$marginals.fixed,function(y) inla.dmarginal(x,y))[,-1]
ddf=data.frame(yield=rep(x,3),density=as.vector(rden),treat=gl(3,100,labels=c("norm","dome","open")))
ggplot(ddf,aes(x=yield,y=density,linetype=treat))+geom_line()
# posterior densities of the three fixed effects

# test for "significance" of Visiondome effect

2*inla.pmarginal(0,result$marginals.fixed$Visiondome)

# Bayesian equivalent of a two-sided p-value





# Rcode for Section 13.4: epilepsy data

library(faraway)
data(epilepsy)


epilepsy$period=rep(0:4,59)
epilepsy$drug=factor(c("placebo","treatment")[epilepsy$treat+1])
epilepsy$phase=factor(c("baseline","experiment")[epilepsy$expind+1])
epilepsy[epilepsy$id<2.5,]


# group summaries
library(dplyr)
epilepsy %>% 
  group_by (drug,phase) %>%
  summarise(rate=mean(seizures/timeadj)) %>%
  xtabs(formula=rate~phase+drug)

library(ggplot2)
ggplot(epilepsy,aes(x=period,y=seizures,linetype=drug,group=id))+
  geom_line()+xlim(1,4)+scale_y_sqrt(breaks=(0:10)^2)+
  theme(legend.position='top',legend.direction='horizontal')

ratesum=epilepsy %>%
  group_by(id,phase,drug) %>%
  summarise(rate=mean(seizures/timeadj))
library(tidyr)
comsum=spread(ratesum,phase,rate)
ggplot(comsum,aes(x=baseline,y=experiment,shape=drug))+geom_point()+
  scale_x_sqrt()+scale_y_sqrt()+geom_abline(intercept=0,slope=1)+
  theme(legend.position='top',legend.direction='horizontal')


# Here is a direct way to produce the right-hand panel in fig. 13.5
rate1=matrix(nrow=59,ncol=3)
for(id in 1:59){
  rate1[id,1]=mean(epilepsy$seizures[epilepsy$id==id&epilepsy$expind==0]/
                     epilepsy$timeadj[epilepsy$id==id&epilepsy$expind==0])
  rate1[id,2]=mean(epilepsy$seizures[epilepsy$id==id&epilepsy$expind==1]/
                     epilepsy$timeadj[epilepsy$id==id&epilepsy$expind==1])
  rate1[id,3]=mean(epilepsy$treat[epilepsy$id==id&epilepsy$expind==1])
}
plot(sqrt(rate1[,1]),sqrt(rate1[,2]),xlab='baseline',ylab='experiment',type='n')
points(sqrt(rate1[rate1[,3]==0,1]),sqrt(rate1[rate1[,3]==0,2]),col='blue',pch=20)
points(sqrt(rate1[rate1[,3]==1,1]),sqrt(rate1[rate1[,3]==1,2]),col='red',pch=20)
abline(a=0,b=1)

# remove suspected outlier in subject 49
epilo=filter(epilepsy,id!=49)

# GLM fit - wrong model but do this first

modglm=glm(seizures~offset(log(timeadj))+expind+treat+I(expind*treat),family=poisson,epilo)
sumary(modglm)
# shows significant negative interaction but analysis doesn't allow for grouping

# we could also do this
modglmq=glm(seizures~offset(log(timeadj))+expind+treat+I(expind*treat),family=quasipoisson,epilo)
sumary(modglmq)
# large dispersion parameter but this doesn't account for true data structure


# PQL method
library(MASS)
modpql=glmmPQL(seizures~offset(log(timeadj))+expind+treat+I(expind*treat),
               random=~1|id,family=poisson,epilo)
summary(modpql)
# shows statistically significant result for the interaction but the PQL method may
# not be very appropriate in this case - see discussion on page 276

# Fitting with glmer - Gauss-Hermite quadrature
library(lme4)
modgh=glmer(seizures~offset(log(timeadj))+expind+treat+I(expind*treat)+(1|id),
            nAGQ=25,family=poisson,epilo)
summary(modgh)

# show proportional effect of treatment based on interaction term
exp(-0.302)

# answer 0.739...

# interpretation: treatment reduces frequency of seizures by about 26%

# also do it without removing the outlier
library(lme4)
modgh0=glmer(seizures~offset(log(timeadj))+expind+treat+I(expind*treat)+(1|id),
             nAGQ=25,family=poisson,epilepsy)
summary(modgh0)
# so the conclusion of the analysis depends on what you do with the outlier!


##########################################
STAN approach - will most likely omit this 
##########################################

# prep data for STAN
epilo$id[epilo$id==59]=49
xm=model.matrix(~expind+treat+I(expind*treat),epilo)
epildat=with(epilo,list(Nobs=nrow(epilo),Nsubs=length(unique(id)),
                        Npreds=ncol(xm),
                        y=seizures,
                        subject=id,
                        x=xm,offset=timeadj))

# compile and run stan

T1=Sys.time()
library(rstan)
# in the next line you'll need to adjust the path name for your own computer
#
# either put the file glmmpois.stan is your R home directory or include
# the full path 
#
rt=stanc('C:/Users/rsmith/jan16/UNC/STOR556/Classes/glmmpois.stan')
sm=stan_model(stanc_ret=rt,verbose=F)
fit=sampling(sm,data=epildat)
T2=Sys.time()
print(T2-T1)


# traceplot of results
traceplot(fit,pars='sigmasubj',inc_warmup=F)

ipars=data.frame(rstan::extract(fit,pars=c('sigmasubj','beta')))
colnames(ipars)=c("subject","intercept","expind","treat","interaction")

# posterior densities of two key quantities
ggplot(ipars,aes(x=subject))+geom_density()

ggplot(ipars,aes(x=interaction))+geom_density()+geom_vline(xintercept=0)

# Bayesian quantiles and p-values
bayespval=function(x){p=mean(x>0);2*min(p,1-p)}
smat=apply(ipars,2,function(x) c(mean(x),quantile(x,c(0.025,0.975)),bayespval(x)))
rownames(smat)=c('mean','LCB','UCB','pvalue')
t(smat)

##########################################
end of STAN approach
##########################################



# INLA approach


formula=seizures ~offset(log(timeadj))+expind+treat+I(expind*treat)+f(id,model='iid')
library('INLA')
result=inla(formula,family='poisson',data=epilo)
#result=inla(formula,family='poisson',data=epilepsy)

sigmaalpha=inla.tmarginal(function(x) 1/sqrt(x), result$marginals.hyperpar$"Precision for id")
restab=sapply(result$marginals.fixed,function(x) inla.zmarginal(x,silent=TRUE))
restab=cbind(restab,inla.zmarginal(sigmaalpha,silent=TRUE))
colnames(restab)=c("mu","expind","treat","interaction","alpha")
data.frame(restab)

# posterior probability that interaction effect is <0
1-inla.pmarginal(0,result$marginals.fixed$"I(expind * treat)")



# posterior density plots for sigma_alpha and the interaction effect
# (like fig 13.6 in the text)
x=seq(0.5,1,length.out=100)
sdf=data.frame(yield=x,density=inla.dmarginal(x,sigmaalpha))
ggplot(sdf,aes(x=yield,y=density))+geom_line()

x=seq(-0.6,0.0,length.out=100)
#x=seq(-0.3,0.1,length.out=100)
intn=result$marginals.fixed$"I(expind * treat)"
ddf=data.frame(yield=x,density=inla.dmarginal(x,intn))
ggplot(ddf,aes(x=yield,y=density))+geom_line()



# Start 4/20/2020

# GEE approach (section 13.5)

# ctsib data
library(faraway)
library(geepack)
data(ctsib)
ctsib$stable=ifelse(ctsib$CTSIB==1,1,0)
modgeep=geeglm(stable~Sex+Age+Height+Weight+Surface+Vision,id=Subject,
               corstr='exchangeable',scale.fix=T,data=ctsib,family=binomial)

summary(modgeep)

# test whether the two vision variables together are significant

modgeep2=geeglm(stable~Sex+Age+Height+Weight+Surface,id=Subject,
                corstr='exchangeable',scale.fix=T,data=ctsib,family=binomial)
anova(modgeep2,modgeep)


# try other correlations structures
modgeep3=geeglm(stable~Sex+Age+Height+Weight+Surface+Vision,id=Subject,
                corstr='ar1',scale.fix=T,data=ctsib,family=binomial)
modgeep4=geeglm(stable~Sex+Age+Height+Weight+Surface+Vision,id=Subject,
                corstr='unstructured',scale.fix=T,data=ctsib,family=binomial)

summary(modgeep3)
summary(modgeep4)

# ar1 seems ok but not unstructured

# what about testing for the subject-specific effects
modgeep6=geeglm(stable~Surface+Vision,id=Subject,
                corstr='exchangeable',scale.fix=T,data=ctsib,family=binomial)
anova(modgeep6,modgeep)

# p-value 0.056

# epilepsy data
# This is the model shown by Faraway
library(geepack)
modgeep=geeglm(seizures~offset(log(timeadj))+expind+treat+I(expind*treat),id=id,
               family=poisson,corstr='ar1',data=epilepsy,subset=(id!=49))
summary(modgeep)


library(geepack)
# The book by Diggle et al. does this
modgeep=geeglm(seizures~offset(log(timeadj))+expind+treat+I(expind*treat),id=id,
               family=poisson,corstr='exchangeable',data=epilepsy,subset=(id!=49))
summary(modgeep)

library(geepack)
# Here is a third possible GEE model
modgeep=geeglm(seizures~offset(log(timeadj))+expind+treat+I(expind*treat),id=id,
               family=poisson,corstr='unstructured',data=epilepsy,subset=(id!=49))
summary(modgeep)

# the p-values for the interaction term vary from model to model - not significant
# for the exchangeable model
#
# maybe we should be concerned about this


#some other models using glmer

# square root link - included only to illustrate that non-canonical link is possible
library(lme4)
modgh1=glmer(seizures~offset(log(timeadj))+expind+treat+I(expind*treat)+(1|id),
             family=poisson(link='sqrt'),epilo)
summary(modgh1)

# refit modgh with implicit nAGQ=1
library(lme4)
modgh2=glmer(seizures~offset(log(timeadj))+expind+treat+I(expind*treat)+(1|id),
             family=poisson,epilo)
summary(modgh2)

# add "period" as a random effect
library(lme4)
modgh3=glmer(seizures~offset(log(timeadj))+expind+treat+I(expind*treat)+(1+period|id),
             family=poisson,epilo)
summary(modgh3)

# add "expind" as a random effect (instead of period) (suggested by Diggle et al. book)
library(lme4)
modgh4=glmer(seizures~offset(log(timeadj))+expind+treat+I(expind*treat)+(1+expind|id),
             family=poisson,epilo)
summary(modgh4)

# also do without omitting outlier
modgh4a=glmer(seizures~offset(log(timeadj))+expind+treat+I(expind*treat)+(1+expind|id),
              family=poisson,epilepsy)
summary(modgh4a)

# coefficient of expind*treat is basically the same with and without outlier

# some tests of nested models
anova(modgh3,modgh2)
anova(modgh4,modgh2)

# either modgh3 or modgh4 improves on modgh2, with modgh4 looking best

# side comment - I also tried a modgh5 with (1+expind+period|id), but then
# we seem to get into fitting problems again


#  residual plots
par(mfrow=c(2,2),cex=0.9)
plot(fitted(modgh),residuals(modgh),xlab='Fitted Values',ylab='Residuals',
     pch=20,main='modgh')
plot(fitted(modgh4a),residuals(modgh4a),xlab='Fitted Values',ylab='Residuals',
     pch=20,main='modgh4a')
qqnorm(residuals(modgh),main='modgh',pch=20)
abline(0,1)
qqnorm(residuals(modgh4a),main='modgh4a',pch=20)
abline(0,1)


# conclusion: glmer seems to give more flexibility than gee

# including expind as a random effect, the difference on omitting the outlier
# seems very slight Diggle et al, "Model 2", page 189



