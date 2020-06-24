
# Question 4
## a)
```{r}
library(faraway)
data(lawn)
head(lawn)
library(ggplot2)
ggplot(lawn, aes(x=machine, y = time)) + geom_point() + facet_grid(~ speed)
ggplot(lawn, aes(x=speed, y = time)) + geom_point() + facet_grid(~ manufact)

ggplot(lawn, aes(x=machine, y = time)) + geom_point() + facet_grid(manufact ~ speed)

```

The plot shows that cutoff times were all higher for high speed to low speed. There also appears to be a downward slope from machine 1 to machine 6, but it isn't clear.

## b)
```{r}
lmod=lm(time~machine+speed+manufact,lawn)
summary(lmod)
drop1(lmod, test = 'F')
```

This model shows that the machines are statistically significant, but this could be due to differences between the manufactures rather than the machines. The dropped 1 F test shows these effects are significant as well.

## c)
```{r}
library(lme4)

mmod=lmer(time~manufact+ speed + manufact:speed + (1|machine),lawn)
summary(mmod)
group.sd=as.data.frame(VarCorr(mmod))$sdcor[1]
resid.sd=as.data.frame(VarCorr(mmod))$sdcor[2]
resid.sd
group.sd

```

If the same machine was tested at the same speed, the standard deviation of the times observed would be 11.5. If different machines were sampled from the same manufacturer once at the same speed, the standard deviation of the times observed would be 12.05.

## d)
```{r}
library(pbkrtest)

nmod=lmer(time~manufact+ speed  + (1|machine),lawn)
pmod=PBmodcomp(mmod,nmod)
summary(pmod)
nmod=lmer(time~1+(1|machine),lawn)

KRmodcomp(mmod,nmod)
```

The parametric bootstrap test shows that the interaction term can be removed as the p values are all very high for the different statistical metrics of significance. After removing them, Kenward-Rogers test shows that the fixed effects are almost certainly significant.


## e)
```{r}
library(tidyverse)
machine.var = lawn %>% group_by(machine) %>% summarise(mean = mean(time),
                                                       var = var(time),
                                                       sd = sd(time))
ggplot(lawn, aes(x = machine, y = time)) + geom_boxplot()
machine.var
bartlett.test(time ~ machine, data = lawn)
```

The boxplot and summary tables showed no obvious signs of differences in variation. The bartlett test also showed no evidence for differences in variation between machines.

## f)
```{r}
tmod=lmer(time~speed  + (1|manufact) + (1|machine:manufact),lawn)
summary(tmod)

```

The variability between manufacturers has a standard deviation of 12.27 and the variation of machines within manufacturers is 12.12.

## g)
```{r}
confint(tmod,method='boot')
nmod=lmer(time~speed  + (1|manufact),lawn)
library(pbkrtest)

pmod=PBmodcomp(tmod,nmod)
summary(pmod)

library(RLRsim)

```

The confidence intervals for the model terms and the parametric bootstrap test shows that the random interaction effect is significant.
