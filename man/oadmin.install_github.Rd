\name{oadmin.install_github}
\alias{oadmin.install_github}
\title{Install a package from a source repository on GitHub. Makes sure devtools package is available.}
\usage{
  oadmin.install_github(opal, pkg,
    username = getOption("github.user"), ref = "master",
    auth_user = NULL, password = NULL)
}
\arguments{
  \item{opal}{Opal object or list of opal objects.}

  \item{pkg}{Package name.}

  \item{username}{GitHub user name.}

  \item{ref}{Desired git reference. Could be a commit, tag,
  or branch name. Defaults to "master".}

  \item{auth_user}{Your github username if you're
  attempting to install a package hosted in a private
  repository (and your username is different to username).}

  \item{password}{Your github password}
}
\description{
  Install a package from a source repository on GitHub.
  Makes sure devtools package is available.
}

