#prep


glm(y ~ ., data = data, family = 'binomial')
glm(y ~ ., data = data, family = 'quasibinomial')

glm(y ~ ., data = data, family = 'poisson')
glm(y ~ ., data = data, family = 'quasipoisson')

mod = lm(y ~ ., data = data)
step(mod, trace = F)


#for overall fit
pchisq(deviance(mod), df.residual(mod), lower.tail = F)
# big P value means good fit!

pchisq(deviance(full.mod) - deviance(reduced.mod),
       df.residual(full.mod) -df.residual(reduced.mod) , lower.tail = F)
# small p means the extra variable is significant!

#pearson method
p.full = sum(residuals(full.mod, type = 'pearson')^2)
p.red = sum(residuals(reduced.mod, type = 'pearson')^2)

pchisq(p.full - p.red,
       df.residual(full.mod) -df.residual(reduced.mod) , lower.tail = F)