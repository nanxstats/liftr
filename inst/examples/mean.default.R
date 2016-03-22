#!/usr/local/bin/Rscript
'
usage: mean.default.R [options]
  --x=<string> An R object.  Currently there are methods for    numeric/logical vectors and link[=Dates]{date},    link{date-time} and link{time interval} objects.  Complex vectors    are allowed for code{trim = 0}, only.
  --trim=<float> the fraction (0 to 0.5) of observations to be    trimmed from each end of code{x} before the mean is computed.    Values of trim outside that range are taken as the nearest endpoint.   [default: 0]
  --na.rm=<boolean> a logical value indicating whether code{NA}    values should be stripped before the computation proceeds. [default: FALSE] ' -> doc
library(docopt)
 opts <- docopt(doc)
do.call( mean.default , list( x = opts$x,trim = as.numeric(opts$trim),na.rm = as.logical(opts$na.rm) ) )
