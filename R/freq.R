#' Frequency Tables for Factors and Other Discrete Data
#'
#' Displays weighted or unweighted frequencies, including <NA> counts and
#' proportions.
#'
#' @param x Factor or vector
#' @param round.digits Number of significant digits to display. Defaults
#'   to \code{2} and can be set globally; see \code{\link{st_options}}.
#' @param order Ordering of rows in frequency table; \dQuote{names} (default for
#'   non-factors), \dQuote{levels} (default for factors), or \dQuote{freq}
#'   (from most frequent to less frequent).
#' @param style Style to be used by \code{\link[pander]{pander}} when rendering
#'   output table; One of \dQuote{simple} (default), \dQuote{grid}, or \dQuote{rmarkdown} 
#'   This option can be set globally; see \code{\link{st_options}}.
#' @param plain.ascii Logical. \code{\link[pander]{pander}} argument; when
#'   \code{TRUE}, no markup characters will be used (useful when printing
#'   to console). Defaults to \code{TRUE} unless \code{style = 'rmarkdown'},
#'   in which case it will be set to \code{FALSE} automatically. To change the default 
#'   value globally, see \code{\link{st_options}}.
#' @param justify String indicating alignment of columns. By default
#'   (\dQuote{default}), \dQuote{right} is used for text tables and
#'   \dQuote{center} is used for \emph{html} tables. You can force it to one
#'   of \dQuote{left}, \dQuote{center}, or \dQuote{right}.
#' @param totals Logical. Set to \code{FALSE} to hide totals from results. To change this
#'   value globally, see \code{\link{st_options}}.
#' @param report.nas Logical. Set to \code{FALSE} to turn off reporting of missing values.
#'   To change this default value globally, see \code{\link{st_options}}.
#' @param missing Characters to display in NA cells. Defaults to \dQuote{}.
#' @param display.type Logical. Should variable type be displayed? Default is \code{TRUE}.
#' @param display.labels Logical. Should variable / data frame labels be displayed?
#'   Default is \code{TRUE}. To change this default value globally, see 
#'   \code{\link{st_options}}.
#' @param omit.headings Logical. Set to \code{TRUE} to omit heading section. Can be set
#'   globally via \code{\link{st_options}}.
#' @param weights Vector of weights; must be of the same length as \code{x}.
#' @param rescale.weights Logical parameter. When set to \code{TRUE}, the total
#'   count will be the same as the unweighted \code{x}. \code{FALSE} by default.
#' @param \dots Additional arguments passed to \code{\link[pander]{pander}}.
#'
#' @return A frequency table of class \code{matrix} and \code{summarytools} with added
#'  attributes used by \emph{print} method.
#'
#' @details The default \code{plain.ascii = TRUE} option is there to make results
#'   appear cleaner in the console. To avoid rmarkdown rendering problems, this
#'   option is automatically set to \code{FALSE} whenever
#'   \code{style = "rmarkdown"} (unless \code{plain.ascii = TRUE} is made
#'   explicit in the function call).
#'
#' @examples
#' data(tobacco)
#' freq(tobacco$gender)
#' freq(tobacco$gender, totals = FALSE)
#' freq(tobacco$gender, display.nas = FALSE)
#' freq(tobacco$gender, style="rmarkdown")
#' with(tobacco, view(by(diseased, smoker, freq), method = "pander"))
#' 
#' @seealso \code{\link[base]{table}}
#'
#' @keywords univar classes category
#' @author Dominic Comtois, \email{dominic.comtois@@gmail.com}
#' @export
#' @importFrom stats xtabs
freq <- function(x, round.digits = st_options('round.digits'), order = "names", 
                 style = st_options('style'), plain.ascii = st_options('plain.ascii'), 
                 justify = "default", totals = st_options('freq.totals'), 
                 report.nas = st_options('freq.report.nas'), missing = "", 
                 display.type = TRUE, display.labels = st_options('display.labels'), 
                 omit.headings = st_options('omit.headings'), weights = NA, 
                 rescale.weights = FALSE, ...) {

  # Parameter validation ------------------------------------------------------

  # if x is a data.frame with 1 column, extract this column as x
  if (!is.null(ncol(x)) && ncol(x)==1) {
    varname <- colnames(x)
    x <- x[[1]]
  }

  if (!is.atomic(x)) {
    x <- try(as.vector(x), silent = TRUE)
    if (any(grepl('try-',class(x))) || !is.atomic(x)) {
      stop("argument x must be a vector or a factor")
    }
  }

  if (!is.numeric(round.digits) || round.digits < 1) {
    stop("'round.digits' argument must be numerical and >= 1")
  }

  order <- switch(tolower(substring(order, 1, 1)),
                  l = "levels",
                  f = "freq",
                  n = "names")

  if (!order %in% c("levels", "freq", "names")) {
    stop("'order' argument must be one of 'level', 'freq' or 'names'")
  }

  if (order == "levels" && !is.factor(x)) {
    stop("'order' argument can be set to 'factor' only for factors. Use 'names'
         or 'freq', or convert object to factor.")
  }

  if (!style %in% c("simple", "grid", "rmarkdown")) {
    stop("'style' argument must be one of 'simple', 'grid' or 'rmarkdown'")
  }

  if (!plain.ascii %in% c(TRUE, FALSE)) {
    stop("'plain.ascii' argument must either TRUE or FALSE")
  }

  if (!justify %in% c("left", "center", "centre", "right", "default")) {
    stop("'justify' argument must be one of 'default', 'left', 'center', or 'right'")
  }
  
  if (!totals %in% c(TRUE, FALSE)) {
    stop("'totals' argument must either be TRUE or FALSE")
  }
  
  if (!report.nas %in% c(TRUE, FALSE)) {
    stop("'report.nas' argument must either be TRUE or FALSE")
  }
  
  if (!omit.headings %in% c(TRUE, FALSE)) {
    stop("'omit.headings' argument must either be TRUE or FALSE")
  }
  
  # When style is 'rmarkdown', make plain.ascii FALSE unless specified explicitly
  if (style %in% c("grid", "rmarkdown") && !"plain.ascii" %in% (names(match.call()))) {
    plain.ascii <- FALSE
  }

  if (!display.labels %in% c(TRUE, FALSE)) {
    stop("'display.labels' must be either TRUE or FALSE.")
  }
  
  if ("file" %in% names(match.call())) {
    message(paste0("'file' argument is deprecated; use for instance ",
                   "print(x, file='a.txt') or view(x, file='a.html') instead"))
  }

  # Replace NaN's by NA's (This simplifies matters a lot)
  if (NaN %in% x)  {
    message(paste(sum(is.nan(x)), "NaN value(s) converted to NA\n"))
    x[is.nan(x)] <- NA
  }

  # Get information about x from parsing function
  parse_info <- try(parse_args(sys.calls(), sys.frames(), match.call(),
                               silent = exists('varname')),
                    silent = TRUE)
  if (any(grepl('try-', class(parse_info)))) {
    parse_info <- list()
  }
  
  if (!"var_names" %in% names(parse_info) && exists("varname")) {
    parse_info$var_names <- varname
  }
  
  # create a basic frequency table, always including the NA row
  if (identical(NA, weights)) {
    freq_table <- table(x, useNA = "always")

    # Order by frequency if needed
    if (order == "freq") {
      freq_table <- sort(freq_table, decreasing = TRUE)
      na_pos <- which(is.na(names(freq_table)))
      freq_table <- c(freq_table[-na_pos], freq_table[na_pos])
    }

    # Change the name of the NA item (last) to avoid potential
    # problems when echoing to console
    names(freq_table)[length(freq_table)] <- "<NA>"

    # calculate proportions (valid, i.e excluding NA's)
    P_valid <- prop.table(freq_table[-length(freq_table)]) * 100

    # Add '<NA>' item to the proportions; this assures
    # proper length when cbind'ing later on
    P_valid["<NA>"] <- NA

    # calculate proportions (total, i.e. including NA's)
    P_tot <- prop.table(freq_table) * 100
  }

  # Weights are used ----------------------------------------------------------
  else {

    # Check that weights vector is of the right length
    if (length(weights) != length(x)) {
      stop("weights vector must be of same length as x")
    }

    weights_string <- deparse(substitute(weights))
    weights_label <- try(label(weights), silent = TRUE)

    if (sum(is.na(weights)) > 0) {
      warning("Missing values on weight variable have been detected and were treated as zeroes.")
      weights[is.na(weights)] <- 0
    }

    if (isTRUE(rescale.weights)) {
      weights <- weights / sum(weights) * length(x)
    }

    freq_table <- xtabs(formula = weights ~ x)

    # Order by frequency if needed
    if (order == "freq")
      freq_table <- freq_table[order(freq_table, decreasing = TRUE)]

    P_valid <- prop.table(freq_table) * 100
    P_valid["<NA>"] <- NA
    freq_table["<NA>"] <- sum(weights) - sum(xtabs(formula = weights ~ x))
    P_tot <- prop.table(freq_table) * 100
  }

  # Calculate cumulative proportions ------------------------------------------
  
  P_valid_cum <- cumsum(P_valid)
  P_valid_cum["<NA>"] <- NA
  P_tot_cum <- cumsum(P_tot)

  # Combine the info to build the final frequency table -----------------------
  
  output <- cbind(freq_table, P_valid, P_valid_cum, P_tot, P_tot_cum)
  output <- rbind(output, c(colSums(output, na.rm = TRUE)[1:2], rep(100,3)))
  colnames(output) <- c("Freq", "% Valid", "% Valid Cum.", "% Total", "% Total Cum.")
  rownames(output) <- c(names(freq_table), "Total")
  
  # Update the output class and attributes ------------------------------------
  
  class(output) <- c("summarytools", class(output))
  
  attr(output, "st_type")    <- "freq"
  attr(output, "fn_call")    <- match.call()
  attr(output, "date")       <- Sys.Date()

  data_info <-
    list(Dataframe       = ifelse("df_name"   %in% names(parse_info), parse_info$df_name  , NA),
         Dataframe.label = ifelse("df_label"  %in% names(parse_info), parse_info$df_label , NA),
         Variable        = ifelse("var_names" %in% names(parse_info), parse_info$var_names, NA),
         Variable.label  = label(x),
         Data.type       = ifelse(is.factor(x) && is.ordered(x), "Factor (ordered)",
                                  ifelse(is.factor(x), "Factor (unordered)",
                                         ifelse(is.character(x), "Character",
                                                ifelse(is.numeric(x), "Numeric", class(x))))),
         #Subset          = ifelse("rows_subset" %in% names(parse_info), parse_info$rows_subset, NA),
         Weights         = ifelse(identical(weights, NA), NA,
                                  sub(pattern = paste0(parse_info$df_name, "$"), replacement = "",
                                      x = weights_string, fixed = TRUE)),
         #Weights.label   = ifelse(!identical(weights, NA) && class(weights_label) != "try-error",
         #                         weights_label, NA),
         Group    = ifelse("by_group" %in% names(parse_info), parse_info$by_group, NA),
         by.first = ifelse("by_group" %in% names(parse_info), parse_info$by_first, NA),
         by.last  = ifelse("by_group" %in% names(parse_info), parse_info$by_last , NA))

  attr(output, "data_info") <- data_info[!is.na(data_info)]

  attr(output, "formatting") <- list(style          = style,
                                     round.digits   = round.digits,
                                     plain.ascii    = plain.ascii,
                                     justify        = justify,
                                     totals         = totals,
                                     report.nas     = report.nas,
                                     missing        = missing,
                                     display.type   = display.type,
                                     display.labels = display.labels,
                                     omit.headings  = omit.headings)

  attr(output, "user_fmt") <- list(... = ...)

  return(output)
}
