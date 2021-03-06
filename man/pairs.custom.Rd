% Generated by roxygen2 (4.1.0): do not edit by hand
% Please edit documentation in R/pairs_panels.R
\name{pairs.custom}
\alias{pairs.custom}
\title{Customization of pairs function}
\usage{
\method{pairs}{custom}(df, main = NULL, flag = 0.5)
}
\arguments{
\item{df}{\code{data.frame} data.frame for comparison. all columns will be used, so pass a subset data.frame if you want to limit which colums.}

\item{main}{\code{character} title for plot}

\item{flag}{\code{numeric} value between 0 and 1.  above this value, pearson's r will be colored red to flag}
}
\value{
only prints plot
}
\description{
Customization of pairs function. Diagonal displays histograms. Lower panel displays pearson's r, with values above 0.5 or other specified value flagged by coloring red.
}
\keyword{correlation}
\keyword{pairs,}

