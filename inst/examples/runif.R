#!/usr/local/bin/Rscript
'
usage: runif.R [options]
  --x, q=<string> vector of quantiles.
  --p=<string> vector of probabilities.
  --n=<string> number of observations. If code{length(n) > 1}, the length    is taken to be the number required.
  --min, max=<string> lower and upper limits of the distribution.  Must be finite.
  --log, log.p=<string> logical; if TRUE, probabilities p are given as log(p).
  --lower.tail=<string> logical; if TRUE (default), probabilities are    eqn{P[X le x]}, otherwise, eqn{P[X > x]}. ' -> doc
library(docopt)
 opts <- docopt(doc)
do.call( runif , list( n = opts$n,min = as.numeric(opts$min),max = as.numeric(opts$max) ) )
