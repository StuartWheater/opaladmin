#-------------------------------------------------------------------------------
# Copyright (c) 2013 OBiBa. All rights reserved.
#  
# This program and the accompanying materials
# are made available under the terms of the GNU Public License v3.0.
#  
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#-------------------------------------------------------------------------------

#' Get Datashield package descriptions from Opal(s).
#' 
#' @title Get Datashield Package Descriptions
#'
#' @param opal Opal object or list of opal objects.
#' @param fields A character vector giving the fields to extract from each package's DESCRIPTION file in addition to the default ones, or NULL (default). Unavailable fields result in NA values.
#' @return A named list of package descriptions
#' @export
dsadmin.package_descriptions <- function(opal, fields=NULL) {
  if(is.list(opal)){
    lapply(opal, function(o){dsadmin.package_descriptions(o, fields=fields)})
  } else {
    query <- list()
    if (!is.null(fields) && length(fields)) {
      query <- append(query,list(fields=paste(fields, collapse=',')))
    }
    dtos <- opal:::.get(opal, "datashield", "packages", query=query)
    packageList <- c()
    for (dto in dtos) {
      packageDescription <- list()
      for (desc in dto$description) {
        packageDescription[[desc$key]] <- desc$value
      }
      packageList[[dto$name]] <- packageDescription
    }
    packageList
  }
}

#' Get Datashield package description from Opal(s).
#' 
#' @title Get Datashield Package Description
#'
#' @param opal Opal object or list of opal objects.
#' @param pkg Package name.
#' @param fields A character vector giving the fields to extract from each package's DESCRIPTION file in addition to the default ones, or NULL (default). Unavailable fields result in NA values.
#' @export
dsadmin.package_description <- function(opal, pkg, fields=NULL) {
  if(is.list(opal)){
    lapply(opal, function(o){dsadmin.package_description(o, pkg,fields=fields)})
  } else {
    query <- NULL
    if (!is.null(fields) && length(fields) > 0) {
      query <- list(fields=paste(fields, collapse=','))
    }
    dto <- opal:::.get(opal, "datashield", "package", pkg, query=query)
    packageDescription <- list()
    for (desc in dto$description) {
      packageDescription[[desc$key]] <- desc$value
    }
    packageDescription
  }
}

#' Install a package from Datashield public package repository or (if Git reference and GitHub username is provided) from Datashield source repository on GitHub.
#'
#' @title Install Datashield Package
#'
#' @param opal Opal object or list of opal objects. 
#' @param pkg Package name.
#' @param githubusername GitHub username of git repository. If NULL (default), try to install from Datashield package repository. 
#' @param ref Desired git reference (could be a commit, tag, or branch name). If NULL (default), try to install from Datashield package repository.
#' @return TRUE if installed
#' @export
dsadmin.install_package <- function(opal, pkg, githubusername=NULL, ref=NULL) {
  if(is.list(opal)){
    lapply(opal, function(o){dsadmin.install_package(o, pkg, githubusername=githubusername, ref=ref)})
  } else {
    if((!is.null(ref)) && (!is.null(githubusername))) {
      query <- list(name=paste(githubusername,pkg,sep="/"),ref=ref)
    } else {
      query <- list(name=pkg)
    }
    opal:::.post(opal, "datashield", "packages", query=query)
    dsadmin.installed_package(opal, pkg)
  }
}

#' Remove a Datashield package permanently from Opal(s).
#'
#' @title Remove Datashield Package
#'
#' @param opal Opal object or list of opal objects.
#' @param pkg Package name.
#' @export
dsadmin.remove_package <- function(opal, pkg) {
  if(is.list(opal)){
    resp <- lapply(opal, function(o){dsadmin.remove_package(o, pkg)})
  } else {
    resp <- opal:::.delete(opal, "datashield", "package", pkg, callback=function(o,r){})
  }
}

#' Check if a Datashield package is installed in Opal(s).
#'
#' @param opal Opal object or list of opal objects.
#' @param pkg Package name.
#' @return TRUE if installed
#' @export
dsadmin.installed_package <- function(opal, pkg) {
  if(is.list(opal)){
    resp <- lapply(opal, function(o){dsadmin.installed_package(o, pkg)})
  } else {
    opal:::.get(opal, "datashield", "package", pkg, callback=function(o,r){
      if(r$code == 404) {
        FALSE
      } else if (r$code >= 400) {
        NULL
      } else {
        TRUE
      }
    })
  }
}

#' Set a Datashield method in Opal(s).
#' 
#' @title Set Datashield Method
#' 
#' @param opal Opal object or list of opal objects.
#' @param name Name of the method, as it will be accessed by Datashield users.
#' @param func Function name.
#' @param path Path to the R file containing the script (mutually exclusive with func).
#' @param type Type of the method: "aggregate" (default) or "assign"
#' @export
dsadmin.set_method <- function(opal, name, func=NULL, path=NULL, type="aggregate") {
  if(is.list(opal)){
    lapply(opal, function(o){dsadmin.set_method(o, name, func=func, path=path, type=type)})
  } else {
    # build method dto
    if(is.null(func)) {
      # read script from file
      rscript <- paste(readLines(path),collapse="\\n")
      rscript <- gsub('\"','\\\\"', rscript)
      methodDto <- paste('{"name":"', name, '","DataShield.RScriptDataShieldMethodDto.method":{"script":"', rscript, '"}}', sep='')  
    } else {
      methodDto <- paste('{"name":"', name, '","DataShield.RFunctionDataShieldMethodDto.method":{"func":"', func, '"}}', sep='')
    }
    dsadmin.rm_method(opal, name, type=type)
    opal:::.post(opal, "datashield", "env", type, "methods", body=methodDto, contentType="application/json");
  }
}

#' Remove a Datashield method from Opal(s).
#' 
#' @title Remove Datashield Method
#' 
#' @param opal Opal object or list of opal objects.
#' @param name Name of the method, as it is accessed by Datashield users.
#' @param type Type of the method: "aggregate" (default) or "assign"
#' @export
dsadmin.rm_method <- function(opal, name, type="aggregate") {
  if(is.list(opal)){
    lapply(opal, function(o){dsadmin.rm_method(o, name, type=type)})
  } else {
    # ignore errors and returned value
    resp <- opal:::.delete(opal, "datashield", "env", type, "method", name, callback=function(o,r){})
  }
}

#' Remove all Datashield methods from Opal(s).
#' 
#' @title Remove Datashield Methods
#' 
#' @param opal Opal object or list of opal objects.
#' @param type Type of the method: "aggregate" or "assign". Default is NULL (=all type of methods).
#' @export
dsadmin.rm_methods <- function(opal, type=NULL) {
  if(is.list(opal)){
    lapply(opal, function(o){dsadmin.rm_methods(o, type=type)})
  } else {
    # ignore errors and returned value
    if (is.null(type)) {
      dsadmin.rm_methods(opal, type="aggregate")
      dsadmin.rm_methods(opal, type="assign")
    } else {
      resp <- opal:::.delete(opal, "datashield", "env", type, "methods", callback=function(o,r){})
    }
  }
}

#' Get a Datashield method from Opal(s).
#' 
#' @title Get Datashield Method
#' 
#' @param opal Opal object or list of opal objects.
#' @param name Name of the method, as it is accessed by Datashield users.
#' @param type Type of the method: "aggregate" (default) or "assign"
#' @export
dsadmin.get_method <- function(opal, name, type="aggregate") {
  if(is.list(opal)){
    lapply(opal, function(o){dsadmin.get_method(o, name, type=type)})
  } else {
    m <- opal:::.get(opal, "datashield", "env", type, "method", name)
    class <- "function"
    value <- m$DataShield.RFunctionDataShieldMethodDto.method$func
    pkg <- NA
    version <- NA
    if (is.null(value)) {
      class <- "script"
      value <- m$DataShield.RScriptDataShieldMethodDto.method$script
    } else {
      pkg <- m$DataShield.RFunctionDataShieldMethodDto.method$rPackage
      if (is.null(pkg)) {
        pkg <- NA
      }
      version <- m$DataShield.RFunctionDataShieldMethodDto.method$version
      if (is.null(version)) {
        version <- NA
      }
    }
    list(name=m$name, type=type, class=class, value=value, package=pkg, version=version)
  }
}

#' Get Datashield methods from Opal(s).
#' 
#' @title Get Datashield Methods
#' 
#' @param opal Opal object or list of opal objects.
#' @param type Type of the method: "aggregate" (default) or "assign"
#' @export
dsadmin.get_methods <- function(opal, type="aggregate") {
  datashield.methods(opal, type)
}

#' Declare Datashield aggregate and assign methods as defined by the package.
#'
#' @title Set Package Datashield Methods
#'
#' @param opal Opal object or list of opal objects. 
#' @param pkg Package name.
#' @param type Type of the method: "aggregate" or "assign". Default is NULL (=all type of methods).
#' @return TRUE if successfull
#' @export
dsadmin.set_package_methods <- function(opal, pkg, type=NULL) {
  if(is.list(opal)){
    lapply(opal, function(o){dsadmin.set_package_methods(o, pkg, type)})
  } else {
    if (dsadmin.installed_package(opal,pkg)) {
      # put methods
      methods <- opal:::.put(opal, "datashield", "package", pkg, "methods")
      TRUE
    } else {
      FALSE
    }
  }
}

#' Remove Datashield aggregate and assign methods defined by the package.
#'
#' @title Remove Package Datashield Methods
#'
#' @param opal Opal object or list of opal objects. 
#' @param pkg Package name.
#' @param type Type of the method: "aggregate" or "assign". Default is NULL (=all type of methods).
#' @export
dsadmin.rm_package_methods <- function(opal, pkg, type=NULL) {
  if(is.list(opal)){
    lapply(opal, function(o){dsadmin.rm_package_methods(o, pkg, type)})
  } else {
    # get methods
    methods <- opal:::.get(opal, "datashield", "package", pkg, "methods")
    if (is.null(type) || type == "aggregate") {
      rval <- lapply(methods$aggregate, function(dto) {
        dsadmin.rm_method(o, dto$name, type='aggregate')
      })
    }
    if (is.null(type) || type == "assign") {
      rval <- lapply(methods$assign, function(dto) {
        dsadmin.rm_method(o, dto$name, type='assign')
      })
    }
  }
}
