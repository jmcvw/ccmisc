#' Download homework submission form
#'
#' Download a GoogleSheets spreadsheet from the given link. The columns are
#' renamed to make them less unwieldy in a data frame. The original names are
#' preserved as an attribute.
#'
#' The first time this is called, you should be taken to the Google sign in
#' page, where it will be necessary to enter authenticate. RStudio should then
#' offer to allow the credentials to persist across sessions - your choice.
#'
#' @param g_sheet Character; Google Sheet identifier, see
#'   \code{\link[googlesheets4:read_sheet]{read_sheet}} for details.
#' @param ... Does nowt (currently)
#'
#' @return Data frame
#' @export
#'
#' @examples
#' \dontrun{
#' gs_url <- 'https://docs.google.com/spreadsheets/d/...unique google sheets url...'
#' form <- dl_hw_form(gs_url)
#' }
#'
dl_hw_form <- function(g_sheet, ...) {
  UseMethod('dl_hw_form')
}

#' @export
#' @keywords internal
#'
dl_hw_form.default <- function(g_sheet, ...) {

  hw_form <- googlesheets4::read_sheet(g_sheet)[-12]

  original_names <- names(hw_form)

  names(hw_form) <- c('submitted', 'name', 'gh_url', 'how_challenging',
                      'how_complete', 'current_feeling', 'recap_topics',
                      'other_comments', 'marker', 'mark', 'marker_notes')

  hw_form <- hw_form |>
    dplyr::rowwise() |>
    dplyr::mutate(week_day = ifelse(is.character(submitted), submitted, NA), .before = 1) |>
    dplyr::ungroup() |>
    tidyr::fill(week_day) |>
    dplyr::filter(!is.na(name)) |>
    tidyr::unnest(submitted) |>
    tidyr::extract(week_day, into = c('week', 'day'), '.+(\\d+).+(\\d+)', convert = TRUE)

  structure(hw_form, original_names = original_names, class = c(class(hw_form), 'hw_form'))
}


#'Clone student repositories
#'
#'Extract student names and Github repo links from the homework submission form
#'found on Google Sheets. Repositories are cloned into the directory given by
#'\code{hw_root}.
#'
#'@param form Dataframe; Class \code{hw_form}
#'@param hw_root Character; Root path to where repositories should be cloned
#'@param ... Character; any sub-directories to add onto hw_root
#'
#'@return Dataframe of two columns: name, and github url (invisible)
#'@export
#'
#' @examples
#'\dontrun{
#'  clone_hw_repos(hw_form, 'homework', 'de999')
#'}
#'
clone_hw_repos <- function(form, ..., hw_root = '~/Documents') {
  UseMethod('clone_hw_repos')
}

#' @export
#' @keywords internal
#'
clone_hw_repos.hw_form <- function(form, ...,  hw_root) {

  if (!inherits(form, 'hw_form')) stop('`form` is not a homework form of class "hw_form"')

  dots <- as.character(substitute(c(...)))[-1]
  dots <- dots[nzchar(dots)]

  form <- form[!(is.na(form[['name']]) | duplicated(form[['name']])),
               c('name', 'gh_url')]

  repos <- basename(form[['gh_url']])
  students <- sub('\\.git$', '', repos)

  repo_dir <- path.expand(
    file.path(hw_root, paste0(dots, collapse = '/'), students)
    )

  browser()
  if (!all(dir.exists(repo_dir))) sapply(repo_dir, dir.create, recursive = TRUE)

  mapply(gert::git_clone, form[['gh_url']], repo_dir)

  invisible(form)
}

# file.path(paste0(c('aaa'), collapse = '/'))
#' Setup student repo clones
#'
#' NEED TO TEST. Is just a wrapper around download & clone functions
#'
#' @param gs_url
#'
#' @return Dataframe of two columns: name, and github url (invisible)
#' @export
#'
setup_cohort_repos <- function(gs_url, ...) {
  clone_hw_repos(dl_hw_form(gs_url), ...)
}


#' Pull to student repos
#'
#' Update student homework repositories.
#'
#' The returned result is a list of [ git response stuff that i should probably
#' detail more precisely ], named according to the CodeClan naming convention
#' for student homework repositories. The path provided to \code{hw_dir} can be
#' the path to a single repository, or a directory containing one or more
#' repositories. In the latter case, the \code{cohort} parameter may also be
#' used to specify a sub-directory.
#'
#' @param hw_dir Character; Path to homework directory
#' @param cohort Character; Cohort directory
#'
#' @return List, named by student, containing information on the result of the
#'   pull operation. This is returned invisibly, so if it is required, it should
#'   be assigned
#' @export
#'
#' @examples
#' \dontrun{
#'   hw_root_dir <- '/Users/user/Documents/GitHub/homework'
#'   cohort <- 'de999'
#'   pull_response <- pull_hw(c('zzz', hw_root_dir), cohort) # 'zzz' fails
#' }
#'
pull_hw <- function(hw_dir, cohort = '') {

  repos <- normalizePath(file.path(hw_dir, cohort), mustWork = F)
  repos <- list.dirs(repos, recursive = FALSE)
  n_issues <- 0

  result <- lapply(repos, function(r) {
    tryCatch(gert::git_pull(repo = r, verbose = FALSE),
             error   = function(e) { n_issues <<- n_issues + 1; e },
             warning = function(w) { n_issues <<- n_issues + 1; w })
  })

  if (n_issues) cli::cat_line(n_issues, ' issues\n', col = 'red')
  setNames(result, sub('.*codeclan_homework_', '', repos, ignore.case = TRUE))
}

