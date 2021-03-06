\name{mice.impute.2lonly.norm}
\alias{2lonly.norm}
\alias{mice.impute.2lonly.norm}
\title{Imputation at level 2 by Bayesian linear regression}
\usage{
  mice.impute.2lonly.norm(y, ry, x, type, ...)
}
\arguments{
  \item{y}{Incomplete data vector of length \code{n}}

  \item{ry}{Vector of missing data pattern
  (\code{FALSE}=missing, \code{TRUE}=observed)}

  \item{x}{Matrix (\code{n} x \code{p}) of complete
  covariates. Only numeric variables are permitted for
  usage of this function.}

  \item{type}{Group identifier must be specified by '-2'.
  Predictors must be specified by '1'.}

  \item{...}{Other named arguments.}
}
\value{
  A vector of length \code{nmis} with imputations.
}
\description{
  Imputes univariate missing data at level 2 using Bayesian
  linear regression analysis.  Variables are level 1 are
  aggregated at level 2. The group identifier at level 2
  must be indicated by \code{type=-2} in the
  \code{predictorMatrix}.
}
\details{
  This function allows in combination with
  \code{\link{mice.impute.2l.pan}} switching regression
  imputation between level 1 and level 2 as described in
  Yucel (2008) or Gelman and Hill (2007, p. 541).
}
\examples{
##################################################
# simulate some data
# x,y ... level 1 variables
# v,w ... level 2 variables

G <- 250            # number of groups
n <- 20             # number of persons
beta <- .3          # regression coefficient
rho <- .30          # residual intraclass correlation
rho.miss <- .10     # correlation with missing response
missrate <- .50     # missing proportion
y1 <- rep( rnorm( G , sd = sqrt( rho ) ) , each=n ) + rnorm(G*n , sd = sqrt( 1 - rho ))
w <- rep( round( rnorm(G ) , 2 ) , each=n )
v <- rep( round( runif( G , 0 , 3 ) ) , each=n )
x <-  rnorm( G*n )
y <- y1 + beta  * x + .2 * w + .1 * v
dfr0 <- dfr <- data.frame( "group" = rep(1:G , each=n ) , "x" = x , "y" = y , "w" = w , "v" = v )
dfr[ rho.miss * x + rnorm( G*n , sd = sqrt( 1 - rho.miss ) ) < qnorm( missrate ) , "y" ] <- NA
dfr[ rep( rnorm(G) , each=n ) < qnorm( missrate ) , "w" ] <- NA
dfr[ rep( rnorm(G) , each=n ) < qnorm( missrate ) , "v" ] <- NA

#....
# empty mice imputation
imp0 <- mice( as.matrix(dfr)  , maxit=0 )
predM <- imp0$predictorMatrix
impM <- imp0$method

#...
# multilevel imputation
predM1 <- predM
predM1[c("w","y","v"),"group"] <- -2
predM1["y","x"] <- 1        # fixed x effects imputation
impM1 <- impM
impM1[c("y","w","v")] <- c("2l.pan" , "2lonly.norm" , "2lonly.pmm" )

# y ... imputation using pan
# w ... imputation at level 2 using norm
# v ... imputation at level 2 using pmm

imp1 <- mice( as.matrix( dfr ) , m = 1 , predictorMatrix = predM1 ,
           imputationMethod = impM1 , maxit=1 , paniter=500)
}
\author{
  Alexander Robitzsch (Federal Institute for Education
  Research, Innovation, and Development of the Austrian
  School System, Salzburg, Austria),
  \email{a.robitzsch@bifie.at}
}
\references{
  Gelman, A. and Hill, J. (2007). \emph{Data analysis using
  regression and multilevel/hierarchical models}.
  Cambridge, Cambridge University Press.

  Yucel, RM (2008). Multiple imputation inference for
  multivariate multilevel continuous data with ignorable
  non-response.  \emph{Philosophical Transactions of the
  Royal Society A}, \bold{366}, 2389-2404.
}
\seealso{
  \code{\link{mice.impute.norm}},
  \code{\link{mice.impute.2lonly.pmm}},
  \code{\link{mice.impute.2l.pan}}
}

