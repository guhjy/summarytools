% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/st_options.R
\name{st_options}
\alias{st_options}
\title{Query and set summarytools global options}
\usage{
st_options(option = NULL, value = NULL, style = "simple",
  round.digits = 2, plain.ascii = TRUE, omit.headings = FALSE,
  footnote = "default", display.labels = TRUE, bootstrap.css = TRUE,
  custom.css = NA, escape.pipe = FALSE, freq.totals = TRUE,
  freq.report.nas = TRUE, ctable.prop = "r", ctable.totals = TRUE,
  descr.stats = "all", descr.transpose = FALSE,
  dfSummary.varnumbers = TRUE, dfSummary.labels.col = TRUE,
  dfSummary.valid.col = TRUE, dfSummary.na.col = TRUE,
  dfSummary.graph.col = TRUE, dfSummary.graph.magnif = 1)
}
\arguments{
\item{option}{option(s) name(s) to query (optional). Can be a single string or a vector
of strings to query multiple values.}

\item{value}{value to assign to the option specified as first argument. This is for
backward-compatibility, as all options can now be set via their own parameter.}

\item{style}{Character. One of \dQuote{simple} (default), \dQuote{rmarkdown}, or \dQuote{grid}. 
Does not apply to \code{\link{dfSummary}}.}

\item{round.digits}{Numeric. Defaults to \code{2}.}

\item{plain.ascii}{Logical. \code{TRUE} by default. Set to \code{FALSE} when using
summarytools with a rendering tool such as \code{knitr} or when creating rmarkdown output
files to be converted with Pandoc (although note that its value will automatically be set
to \code{FALSE} whenever \code{style} = \dQuote{rmarkdown}).}

\item{omit.headings}{Logical. Set to \code{TRUE} to remove all headings from outputs
(only the tables will be printed out). \code{FALSE} by default.}

\item{footnote}{Character. When the default value \dQuote{default} is used, the 
package name, version, and R version are displayed below html outputs. Set no \code{NA} to omit
the footnote, or provide a string to personalize it.}

\item{display.labels}{Logical. \code{TRUE} by default. Set to \code{FALSE} to omit data 
frame and variable labels in the headings section.}

\item{bootstrap.css}{Logical. Include Bootstrap CSS in html outputs. Defaults to 
\code{TRUE}. Set to \code{FALSE} when using the \dQuote{render} method inside a 
\code{shiny} app.}

\item{custom.css}{Character. Path to an additional, user-provided, CSS file. \code{NA} 
by default.}

\item{escape.pipe}{Logical. Set to \code{TRUE} if Pandoc conversion
is your goal and you have unsatisfying results with grid or multiline tables.
\code{FALSE} by default.}

\item{freq.totals}{Logical. Corresponds to the \code{totals} parameter of \code{\link{freq}}.
\code{TRUE} by default.}

\item{freq.report.nas}{Logical. Corresponds to the \code{display.nas} parameter of 
\code{freq()}. \code{TRUE} by default.}

\item{ctable.prop}{Character. Corresponds to the \code{prop} parameter of 
\code{\link{ctable}}. Defaults to \dQuote{r} (\emph{r}ow).}

\item{ctable.totals}{Logical. Corresponds to the \code{totals} parameter of 
\code{\link{ctable}}. \code{TRUE} by default.}

\item{descr.stats}{Character. Corresponds to the \code{stats} parameter of 
\code{\link{descr}}. Defaults to \dQuote{all}.}

\item{descr.transpose}{Logical. Corresponds to the \code{transpose} parameter of 
\code{\link{descr}}. \code{FALSE} by default.}

\item{dfSummary.varnumbers}{Logical. In \code{\link{dfSummary}}, display variable numbers
in the first column. Defaults to \code{TRUE}.}

\item{dfSummary.labels.col}{Logical. In \code{\link{dfSummary}}, display variable labels
Defaults to \code{TRUE}.}

\item{dfSummary.valid.col}{Logical. In \code{\link{dfSummary}}, include column indicating
count and proportion of valid (non-missing). \code{TRUE} by default.}

\item{dfSummary.na.col}{Logical. In \code{\link{dfSummary}}, include column indicating count
and proportion of missing (NA) values. \code{TRUE} by default.}

\item{dfSummary.graph.col}{Logical. Display barplots / histograms column in 
\code{\link{dfSummary}} \emph{html} reports. \code{TRUE} by default.}

\item{dfSummary.graph.magnif}{Numeric. Magnification factor, useful if 
\code{\link{dfSummary}} graphs show up too large (then use a value between 0 and 1) or 
too small (use a value > 1). Must be positive. Default to \code{1}.}
}
\description{
To list all \code{summarytools} global options, call without arguments. To display the value of
one or several options, enter the name(s) of the option(s) in a character vector as sole argument.
}
\note{
Loosely based on Gergely Daróczi's \code{\link[pander]{panderOptions}} function.
}
\examples{
\dontrun{
st_options()                   # show all summarytools global options
st_options('round.digits')     # show a specific global option 
st_options(round.digits = 1)   # set an option
st_options('round.digits', 1)  # set an option (legacy way)
st_options('reset')            # reset all summarytools global options
}
}
\author{
Dominic Comtois, \email{dominic.comtois@gmail.com},
}
