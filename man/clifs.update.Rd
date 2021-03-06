% Generated by roxygen2 (4.1.0): do not edit by hand
% Please edit documentation in R/clifs_model_functions.R
\name{clifs.update}
\alias{clifs.update}
\title{CliFSSS model, updates model for specified months.  Other months remain as is}
\usage{
clifs.update(ml, periods, terms = "", dep.var = ".", clear.terms = F, df,
  period.type = "month")
}
\arguments{
\item{ml}{\code{list} model list, of  \code{lm} or \code{merMod} class models}

\item{periods}{\code{array}}

\item{terms}{\code{character} terms to be appended to formulat (with + or - operator)}

\item{df}{\code{data.frame}}

\item{period.type}{\code{character}}
}
\description{
CliFSSS model, updates model for specified months.  Other months remain as is
}

