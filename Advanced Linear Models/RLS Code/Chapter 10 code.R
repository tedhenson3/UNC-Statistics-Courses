


library(faraway)
data(pulp)
op=options(contrasts=c('contr.sum','contr.poly'))
lmod=aov(bright~operator,pulp)
summary(lmod)

library(ggplot2)
ggplot(pulp,aes(x=operator,y=bright))+
  geom_point(position=position_jitter(width=0.1,height=0.0))

# some clarification of the estimates
mean(pulp$bright)
mean(pulp$bright[pulp$operator=='a'])
mean(pulp$bright[pulp$operator=='b'])
mean(pulp$bright[pulp$operator=='c'])
mean(pulp$bright[pulp$operator=='d'])

coef(lmod)

options(op)

(0.447-0.106)/5
# answer 0.068 = this is MOM of sigma^2-alpha

# fit the same model using lme4 - REML method

library(lme4)
mmod=lmer(bright~1+(1|operator),pulp)
summary(mmod)

# alternative display of results
sumary(mmod)

# compute exact MLE (default above was REML)
smod=lmer(bright~1+(1|operator),pulp,REML=F)
sumary(smod)

# estimated SDs are slightly smaller

# section 10.2

nullmod=lm(bright~1,pulp)
lrtstat=as.numeric(2*(logLik(smod)-logLik(nullmod)))
pvalue=pchisq(lrtstat,1,lower=F)
data.frame(lrtstat,pvalue)

# bootstrap test
# one sample
y=simulate(nullmod)

ggplot(pulp,aes(x=operator,y=y$sim_1))+
  geom_point(position=position_jitter(width=0.1,height=0.0))


# 1000 samples
lrtstat=numeric(1000)
y=simulate(nullmod)
set.seed(123) # you don't have to set the seed in advance - this is just for reproducbility
for(i in 1:1000){
  y=unlist(simulate(nullmod))
  bnull=lm(y~1)
  balt=lmer(y~1+(1|operator),pulp,REML=F)
  lrtstat[i]=as.numeric(2*(logLik(balt)-logLik(bnull)))
}

mean(lrtstat<0.00001)

mean(lrtstat>2.5684)

# here 0.019 was a simulated estimate - compute its standard erro

sqrt(0.019*0.981/1000)
# standard error was 0.004 - it looks like our 0.019 estimate was pretty accurate

# do the same test a different way
library(RLRsim)
exactLRT(smod,nullmod)

# here's another way again - note that this version uses the REML estimate, not MLE
exactRLRT(mmod)

# get the variances from mmod
VarCorr(mmod)

# same thing in a nother format
as.data.frame(VarCorr(mmod))

# now do a bootstrap simulation
bsd=numeric(1000)
for(i in 1:1000){
  y=unlist(simulate(mmod))
  bmod=refit(mmod,y)
  bsd[i]=as.data.frame(VarCorr(bmod))$sdcor[1]
}

quantile(bsd,c(0.025,0.975))


# alternative method fo confidence intervals, using bootstrap
confint(mmod,method='boot')

# section 10.3

# prediction of random effects
# recall earlier model mmod fitted by REML

r1=ranef(mmod)
# this computes random effects without conditional variances

r1=ranef(mmod,condVar=T)
# this computes random effects with the conditional variances

# it looks as though you have to do something like this to extract the conditional variances:
str(r1)

# construct a plot including the confidence intervals
library(lattice)
dotplot(r1)


# section 10.4

# prediction of future observations

# for known operator, combine fixed effects with known random effects for operator
fixef(mmod)+ranef(mmod)$operator


# alternatively use "predict" function

# this is for an unknown future operator
predict(mmod,re.form=~0)[1]

# this is for a known operator (here, operator a)
predict(mmod,newdata=data.frame(operator='a'))

# prediction interval for a new observation with an unknown operator
group.sd=as.data.frame(VarCorr(mmod))$sdcor[1]
resid.sd=as.data.frame(VarCorr(mmod))$sdcor[2]
pv=numeric(1000)
for(i in 1:1000){
  y=unlist(simulate(mmod))
  bmod=refit(mmod,y)
  pv[i]=predict(bmod,re.form=~0)[1]+rnorm(n=1,sd=group.sd)+rnorm(n=1,sd=resid.sd)
}
quantile(pv,c(0.025,0.975))

# do the same thing but suppress the error messages
# prediction interval for a new observation with an unknown operator
group.sd=as.data.frame(VarCorr(mmod))$sdcor[1]
resid.sd=as.data.frame(VarCorr(mmod))$sdcor[2]
pv=numeric(1000)
for(i in 1:1000){
  y=unlist(simulate(mmod))
  bmod=suppressMessages(refit(mmod,y))
  pv[i]=predict(bmod,re.form=~0)[1]+rnorm(n=1,sd=group.sd)+rnorm(n=1,sd=resid.sd)
}
quantile(pv,c(0.025,0.975))


# prediction interval for a new observation with a known operator ('a')
group.sd=as.data.frame(VarCorr(mmod))$sdcor[1]
resid.sd=as.data.frame(VarCorr(mmod))$sdcor[2]
pv=numeric(1000)
for(i in 1:1000){
  y=unlist(simulate(mmod,use.u=T))
  bmod=refit(mmod,y)
  pv[i]=predict(bmod,new.data=data.frame(operator='a'))+rnorm(n=1,sd=resid.sd)
}
quantile(pv,c(0.025,0.975))

# section 10.5



data(pulp)
library(lme4)
mmod=lmer(bright~1+(1|operator),pulp)

par(mfrow=c(1,2),cex=1.2)
qqnorm(residuals(mmod),main='',pch=20)
plot(fitted(mmod),residuals(mmod),xlab='Fitted',ylab='Residuals',pch=20)
abline(h=0)

# adding colors to the qq-plot
q1=qqnorm(residuals(mmod),type='n')
points(q1$x[1:5],q1$y[1:5],col='red',pch=20)
points(q1$x[6:10],q1$y[6:10],col='green',pch=20)
points(q1$x[11:15],q1$y[11:15],col='blue',pch=20)
points(q1$x[16:20],q1$y[16:20],col='magenta',pch=20)




# section 10.6

library(faraway)
library(ggplot2)
data(penicillin)
summary(penicillin)

penicillin

# plot data
penicillin$Blend=gl(5,4)
ggplot(penicillin,aes(y=yield,x=treat,shape=Blend))+geom_point()+xlab('Treatment')

ggplot(penicillin,aes(y=yield,x=Blend,shape=treat))+geom_point()+xlab('Blend')

# fixed effects model
op=options(contrasts=c('contr.sum','contr.poly'))
lmod=aov(yield~blend+treat,penicillin)
summary(lmod)


coef(lmod)

# random effects model - blend is random
library(lme4)
mmod=lmer(yield~treat+(1|blend),penicillin)
sumary(mmod)

# if you don't fully understand the model results, don't be afrad to do something like this

mean(penicillin$yield[penicillin$treat=='A'])
mean(penicillin$yield[penicillin$treat=='B'])
mean(penicillin$yield[penicillin$treat=='C'])
mean(penicillin$yield[penicillin$treat=='D'])


options(op)

ranef(mmod)$blend

amod=aov(yield~treat+Error(blend),penicillin)
summary(amod)

anova(mmod)

# Kenward-Roger test
library(pbkrtest)
amod=lmer(yield~treat+(1|blend),penicillin,REML=F)
nmod=lmer(yield~1+(1|blend),penicillin,REML=F)
KRmodcomp(amod,nmod)

# but note, we get the same thing with REML=T (because the K-R software refits anyway)
amod=lmer(yield~treat+(1|blend),penicillin,REML=T)
nmod=lmer(yield~1+(1|blend),penicillin,REML=T)
KRmodcomp(amod,nmod)

#parametric bootstrap
amod=lmer(yield~treat+(1|blend),penicillin,REML=F)
nmod=lmer(yield~1+(1|blend),penicillin,REML=F)
as.numeric(2*(logLik(amod)-logLik(nmod)))

1-pchisq(4.0474,3)

lrtstat=numeric(1000)
for(i in 1:1000){
  ryield=unlist(simulate(nmod))
  nmodr=refit(nmod,ryield)
  amodr=refit(amod,ryield)
  lrtstat[i]=2*(logLik(amodr)-logLik(nmodr))
}


mean(lrtstat<0.001)

mean(lrtstat>4.0474)

# also do same thing with parametric bootstrap
pmod=PBmodcomp(amod,nmod)
summary(pmod)

# test significance of blends
rmod=lmer(yield~treat+(1|blend),penicillin)
nlmod=lm(yield~treat,penicillin)
as.numeric(2*(logLik(rmod)-logLik(nlmod,REML=T)))

# simulation test here
lrtstatf=numeric(1000)
for(i in 1:1000){
  ryield=unlist(simulate(nlmod))
  nlmodr=lm(ryield~treat,penicillin)
  #rmodr=refit(rmod,ryield)
  rmodr=lmer(ryield~treat+(1|blend),penicillin)
  lrtstatf[i]=2*(logLik(rmodr)-logLik(nlmodr,REML=T))
}

mean(lrtstatf<0.00001)

mean(lrtstatf>2.7629)

library(RLRsim)
exactRLRT(rmod)


# Section 10.7

library(faraway)
data(irrigation)

ggplot(irrigation,aes(y=yield,x=field,shape=irrigation,color=variety))+geom_point()

library(lme4)

m1=lmer(yield~irrigation+variety+irrigation:variety+(1|field)+(1|field:variety),irrigation)

m2=lmer(yield~irrigation+variety+irrigation:variety+(1|field),irrigation)

m3=lmer(yield~irrigation+variety+(1|field),irrigation)

m4=lmer(yield~variety+(1|field),irrigation)

m5=lmer(yield~irrigation+(1|field),irrigation)

m6=lmer(yield~1+(1|field),irrigation)

# Kenward-Roger tests
library(pbkrtest)
KRmodcomp(m2,m3)
KRmodcomp(m3,m4)
KRmodcomp(m3,m5)
KRmodcomp(m4,m6)
KRmodcomp(m5,m6)

# Model m6 seems as good as any other

# Test statistical significance of random field effect in m6
library(RLRsim)
exactRLRT(m6)

# Confidence intervals
confint(m6)

# Diagnostics
par(mfrow=c(1,2),cex=1,2)
plot(fitted(m6),residuals(m6),xlab='Fitted',ylab='Residuals',pch=20)
qqnorm(residuals(m6),main='',pch=20)


# Section 10.8

data(eggs)
library(ggplot2)
ggplot(eggs,aes(y=Fat,x=Lab,color=Technician,shape=Sample))+
  geom_point(position=position_jitter(width=0.1,height=0.0))+scale_color_grey()

m1=lmer(Fat~1+(1|Lab)+(1|Lab:Technician)+(1|Lab:Technician:Sample),data=eggs)

m2=lmer(Fat~1+(1|Lab)+(1|Lab:Technician),data=eggs)

m3=lmer(Fat~1+(1|Lab:Technician:Sample),data=eggs)


library(RLRsim)
exactRLRT(m3,m1,m2)

# m1: full model under the alternative
# m2: null model
# m3: a random effects model containing ONLY the term set to 0 under the null
# The p-value is not significant

# Elminate "Sample", test for Technician effect: m2 is now the alternative hypothesis
m4=lmer(Fat~1+(1|Lab),data=eggs)
m5=lmer(Fat~1+(1|Lab:Technician),data=eggs)
exactRLRT(m5,m2,m4)
# p-value about 0.002

# we could also have use parametric bootstrap tests
library(pbkrtest)
PBmodcomp(m1,m2)
PBmodcomp(m2,m4)



# Confidence intervals in original model
confint(m1)



# My comment on this example: I don't see why we can't treat Sample as a fixed effect
m6=lmer(Fat~1+Sample+(1|Lab)+(1|Lab:Technician),data=eggs)
KRmodcomp(m6,m2)
# p-value is 0.076 --- not significant, but not too far off

# If Sample really did represent two manufacturers of egg powder, I think this would be
# the right test


# Section 10.9

library(faraway)
data(abrasion)
matrix(abrasion$material,4,4)

# fixed effects model:

m1=aov(wear~material+run+position,abrasion)
summary(m1)

# random effects model
library(lme4)
m2=lmer(wear~material+(1|run)+(1|position),abrasion)
summary(m2)

# KR test for the fixed effect
m3=lmer(wear~1+(1|run)+(1|position),abrasion)
library(pbkrtest)
KRmodcomp(m2,m3)

# RLRT tests for the successive random effects
library(RLRsim)
m4=lmer(wear~material+(1|run),abrasion)
m5=lmer(wear~material+(1|position),abrasion)
exactRLRT(m4,m2,m5)
exactRLRT(m5,m2,m4)

# Section 10.10
data(jsp)
# drop everything outside year 2
jspr=jsp[jsp$year==2,]
library(ggplot2)
ggplot(jspr,aes(x=raven,y=math))+xlab('Raven Score')+ylab('Math Score')+
  geom_point(position=position_jitter(),alpha=0.3)
ggplot(jspr,aes(x=social,y=math))+xlab('Social Class')+ylab('Math Score')+
  geom_boxplot()

# multiple regression approach
glin=lm(math~raven*gender*social,jspr)
anova(glin)

# remove gender
glin1=lm(math~raven*social,jspr)
anova(glin1)

anova(glin,glin1)

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


# table of school numbers
table(jspr$school)

# random effects model
mmod=lmer(math~raven + (1|school)+(1|school:class),data=jspr)
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




# now run a series of models and test by AIC/BIC. Must use MLE not REML for this
all3=lmer(math~raven*social*gender+(1|school)+(1|school:class),data=jspr,REML=F)
all2=update(all3,.~.-raven:social:gender)
notrs=update(all2,.~.-raven:social)
notrg=update(all2,.~.-raven:gender)
notsg=update(all2,.~.-social:gender)
onlyrs=update(all2,.~.-social:gender-raven:gender)
all1=update(all2,.~.-social:gender-raven:gender-raven:social)
nogen=update(all1,.~.-gender)
# comparisons of all these models
anova(all3,all2,notrs,notrg,notsg,onlyrs,all1,nogen)[,1:4]

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

# compositional effects
schraven=lm(raven~school,jspr)$fit
mmodc=lmer(math~craven*social+schraven*social+(1|school),jspr)
KRmodcomp(mmod,mmodc)

# conclusion: mean raven score per school does not have significant extra effect







