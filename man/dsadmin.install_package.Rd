\name{dsadmin.install_package}
\alias{dsadmin.install_package}
\title{Install Datashield Package}
\usage{
  dsadmin.install_package(opal, pkg, ref = NULL)
}
\arguments{
  \item{opal}{Opal object or list of opal objects.}

  \item{pkg}{Package name.}

  \item{githubusername}{GitHub username of git repository.
  If NULL (default), try to install from Datashield package
  repository.}

  \item{ref}{Desired git reference (could be a commit, tag,
  or branch name). If NULL (default), try to install from
  Datashield package repository.}
}
\value{
  TRUE if installed
}
\description{
  Install a package from Datashield public package
  repository or (if Git reference is provided) from
  Datashield source repository on GitHub.
}

