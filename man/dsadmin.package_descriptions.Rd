\name{dsadmin.package_descriptions}
\alias{dsadmin.package_descriptions}
\title{Get Datashield Package Descriptions}
\usage{
  dsadmin.package_descriptions(opal, fields = NULL)
}
\arguments{
  \item{opal}{Opal object or list of opal objects.}

  \item{fields}{A character vector giving the fields to
  extract from each package's DESCRIPTION file in addition
  to the default ones, or NULL (default). Unavailable
  fields result in NA values.}
}
\value{
  A named list of package descriptions
}
\description{
  Get Datashield package descriptions from Opal(s).
}

