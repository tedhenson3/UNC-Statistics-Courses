
library(faraway)
data(faithful)

par(mfrow=c(1,1),cex=1.1)
plot(waiting~eruptions,pch=20,ylab='Waiting Time',xlab='Length of Eruption',faithful)
lines(faithful$eruptions,lm(waiting~eruptions,faithful)$fitted,lw=3,col='red')


library(splines)
erupspl=ns(faithful$eruptions,8)
lines(lm(waiting[order(eruptions)]~erupspl[order(eruptions),])$fitted~sort(eruptions),
      faithful,lw=3,col='blue')

# alternative way of handling ordering
faith1=faithful[order(faithful$eruptions),]
plot(waiting~eruptions,pch=20,ylab='Waiting Time',xlab='Length of Eruption',faith1)
lines(lm(waiting~ns(eruptions,8))$fitted~eruptions,lw=3,col='blue',faith1)

# kernel method
par(mfrow=c(1,3),cex=1.1)
for(bw in c(0.1,0.5,2)){
  with(faithful,{
    plot(waiting~eruptions,col='green',pch=20)
    lines(ksmooth(eruptions,waiting,"normal",bw))
  })}

# optimal kernel smoothing using Bowman-Azzalini method

par(mfrow=c(1,1),cex=1.1)
library(sm)
with(faithful,sm.regression(eruptions,waiting,h=h.select(eruptions,waiting)))

# to get more information about the smoother
sm1=with(faithful,sm.regression(eruptions,waiting,h=h.select(eruptions,waiting)))
names(sm1)
# e.g. for bandwidth
sm1$h


par(mfrow=c(1,1),cex=1.1)
library(sm)
with(exa,sm.regression(x,y,h=h.select(x,y)))

par(mfrow=c(1,1),cex=1.1)
library(sm)
with(exb,sm.regression(x,y,h=h.select(x,y)))



# smoothing splines method

# note the following method automatically selects the optimal smoothing by cross-validation

with(faithful,{
  plot(waiting~eruptions,pch=20,col='green')
  lines(smooth.spline(eruptions,waiting),lty=2,lw=3,col='red')
})

# artificial example from text
data(exa)
with(exa,{
  plot(y~x,pch=20,col='blue')
  lines(smooth.spline(x,y),lty=2,lw=3,col='red')
})


# example where this goes wrong
data(exb)
with(exb,{
  plot(y~x,pch=20,col='blue')
  lines(smooth.spline(x,y),lty=2,lw=3,col='red')
})

# regression  splines method - this differs a bit from the text

par(mfrow=c(1,1),cex=1.1)

# arrange x values in order
faith1=faithful[order(faithful$eruptions),]
plot(waiting~eruptions,pch=20,ylab='Waiting Time',xlab='Length of Eruption',faith1)
library(splines)
erupspl=ns(faith1$eruptions,3)
lines(lm(waiting[order(eruptions)]~erupspl[order(eruptions),])$fitted~sort(eruptions),
      faith1,lw=3,col='blue')

plot(waiting~eruptions,pch=20,ylab='Waiting Time',xlab='Length of Eruption',faithful)
library(splines)
erupspl=ns(faithful$eruptions,8)
lines(lm(waiting[(eruptions)]~erupspl[(eruptions),])$fitted~(eruptions),
      faithful,lw=3,col='blue')

plot(y~x,pch=20,ylab='y',xlab='x',exa)
library(splines)
xspl=ns(exa$x,8)
lines(lm(y~xspl)$fitted~x,exa,lw=3,col='blue')

plot(y~x,pch=20,ylab='y',xlab='x',exb)
library(splines)
xspl=ns(exb$x,8)
lines(lm(y~xspl)$fitted~x,exb,lw=3,col='blue')






# loess method (local polynomials)

with(faithful,{
  plot(waiting~eruptions,col='green',pch=20)
  f=loess(waiting~eruptions,span=0.25)
  i=order(eruptions)
  lines(f$x[i],f$fitted[i],lw=3,col='blue')
})
# try other values of span and also try omitting span entirely: the default is 0.75


# confidence bands

library(ggplot2)
ggplot(faithful,aes(x=eruptions,y=waiting))+geom_point(alpha=0.25)+geom_smooth(
  method='loess',span=0.5)


library(mgcv)
ggplot(faithful,aes(x=eruptions,y=waiting))+geom_point(alpha=0.25)+geom_smooth(
  method='gam',formula=y~s(x))


library(mgcv)
data(exa)
ggplot(exa,aes(x=x,y=y))+geom_point(alpha=0.25)+geom_smooth(
  method='gam',formula=y~s(x))



# fit linear model to polynomial splines, old faithful data
erupspl=ns(faithful$eruptions,8)
lm1=lm(waiting~erupspl,faithful)
# add ones to erupspl to allow for intercept term
erups2=cbind(rep(1,272),erupspl)
# compute pointwise standard deviations at all values of eruptions
sd_points=sqrt(diag(erups2 %*% vcov(lm1) %*% t(erups2)))
# t statistic for 95% confidence intervals (adjust confidence limit if desired)
ts=qt(0.975,df.residual(lm1))
# redraw plot with confience lines
i=order(faithful$eruptions)
par(mfrow=c(1,1),cex=1.1)
with(faithful,{
  plot(waiting~eruptions,pch=20,ylab='Waiting Time',xlab='Length of Eruption')
  lines(eruptions[i],lm1$fitted[i],lw=5,col='blue')
  lines(eruptions[i],lm1$fitted[i]+ts*sd_points[i],lw=3,col='green')
  lines(eruptions[i],lm1$fitted[i]-ts*sd_points[i],lw=3,col='green')
})



# much easier way to do this:

erupspl=ns(faithful$eruptions,8)
lm1=lm(waiting~erupspl,faithful)
pr1=predict(lm1,se.fit=T,interval='confidence')
i=order(faithful$eruptions)
par(mfrow=c(1,1),cex=1.1)
with(faithful,{
  plot(waiting~eruptions,pch=20,ylab='Waiting Time',xlab='Length of Eruption')
  lines(eruptions[i],pr1$fit[i,1],lw=5,col='blue')
  lines(eruptions[i],pr1$fit[i,2],lw=3,col='green')
  lines(eruptions[i],pr1$fit[i,3],lw=3,col='green')
})



