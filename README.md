
<!-- README.md is generated from README.Rmd. Please edit that file -->

# ccmisc

A package of miscellaneous functions that might come in handy working at
CodeClan. Currently only has functions for cloning / pulling student
homework repos, but might grow over time.

## Installation

You can install `ccmisc` like so:

``` r
remotes::install_github('jmcvw/ccmisc')
```

## Examples

### Clone repos of new cohort

When a new cohort arrives, they complete a form that includes their name
and Github url. The function `setup_cohort_repos` takes as its first
argument a GoogleSheets id or url. It will ask for authentication, then
read the homework submission form. The `...` parameter of
`setup_cohort_repos` can be used to pass on the directory into which the
homework (hw) repos should be cloned. The default location is
`~/Documents`, but can be changed by specifying an input for `hw_root`.
Further sub-directories can also be passed added, and are appended to
`hw_root`

The parameter `hw_root` takes a path where the repos should be
downloaded, by default this is set to `~/Documents/`. The `...` allows
further sub-directories to be added: eg `homework/cohort_id` will clone
all repos taken from the homework submission form, into a
cohort-specific sub-directory.

``` r
library(ccmisc)

hw_form <- 'https://docs.google.com/spreadsheets/d/...unique google sheets url...'
hw_form <- 'https://docs.google.com/spreadsheets/d/1HyAxd5050SQmvkIyIVuZOrZoMfqHia6YyANfcewXbxo/edit#gid=1164343432'

setup_cohort_repos(hw_form, , hw_root = '~/Documents/Github', 'homework', 'de999')
```

### Pull repos to review latest homework submissions

Student homework repos can be updated using `pull_hw`. The only argument
required is the root directory for a chosen cohort. It will attempt
carry out a pull action for all sub-directories. There is a second
argument provided, `cohort`, which (should, hopefully, maybe) be
vectorized such that if more than one `cohort` sub-directory is passed
in, they will be looped over to pull repos for all cohorts specified.

``` r
hw_root_dir <- '/Users/user/Documents/GitHub/homework'
cohort <- 'de999'

pull_response <- pull_hw(hw_root_dir, cohort)
```
