#' Locate files at given path
#'
#' Determines all notes files (html, Rmd) or data (csv) files at the given location.
#'
#' If \code{file_types} is \code{'notes'}, html note files are opened. If \code{file_types} is \code{'rmd'} Rmarkdown notebooks are opened. If \code{file_types} is \code{'data'} csv files are read and placed in the global environment. Data files are named according to their \code{\link{basename}}
#'
#' @param week Integer
#' @param day  Integer
#' @param file_types Character; Any or all of 'notes', 'rmd', or 'data'
#' @param path Character; Location of course repo
#'
#' @return List of character vector filepaths named 'notes', 'rmd' and 'data'
#' @export
#'
find_notes <- function(week, day, file_types = c('notes', 'data', 'rmd'),
                       path) {

  path <- sprintf(file.path(path, 'week_%02i/day_%i'), week, day)

  files <- list()

  if ('notes' %in% file_types) {
    files$notes <- dir(path, '\\.html$', recursive = TRUE, full.names = TRUE)
  }

  # rmds are only returned if specified explicitly
  if ('rmd' %in% file_types) {
    rmd <- dir(path, '\\.Rmd$', recursive = TRUE, full.names = TRUE)
    files$rmd <- rmd
  }

  if ('data' %in% file_types) {
    data_files <- dir(path, '\\.csv$', recursive = TRUE, full.names = TRUE)
    data_files_names <- sub('.+/(.+)\\....$', '\\1', data_files)
    data_files_names <- gsub('[ -]+', '_', data_files_names)
    files$data <- setNames(data_files, data_files_names)
  }

  files
}

#' Opens notes files
#'
#' Loops over a vector or file paths and open the files indicated. If two or
#' more datasets have the same name basename, only the last read will be
#' available
#'
#' @param week Integer
#' @param day Integer
#' @param file_types Character; Any or all of 'notes', 'rmd', or 'data'
#' @param path Character; Location of course repo
#'
#' @return NULL
#' @export
#'
open_notes <- function(week, day, file_types = c('notes', 'data', 'rmd'),
                       path = '/Users/user/Documents/GitHub/data_rewrite2',
                       clean_names = TRUE) {

  file_types_arg <- match.arg(file_types, several.ok = TRUE)
  if (missing(file_types)) {
    file_types_arg <- file_types_arg[1:2]
  }

  notes <- find_notes(week, day, file_types_arg, path)

  suppressMessages(
    invisible(
      mapply(\(f, n) {
        f <- readr::read_csv(f)
        assign(n,
               if (clean_names) janitor::clean_names(f) else f,
               envir = .GlobalEnv)
      }, notes$data, names(notes$data))
    ))
  invisible(lapply(unlist(notes[names(notes) != 'data']), browseURL))
  names(notes$data)
}
