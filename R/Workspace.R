#' Workspace
#' 
#' @name Workspace
#' @docType class
#' @author Joan Dídac Viana Fons \email{joanvianafons@gmail.com}
#' @import R6
#' @import devtools
#' @import roxygen2
#' @export Workspace
#' @keywords pvR, Workspace, git, library, package
#' @return Object of \code{\link{R6Class}} with methods to easy create and update an R package. 
#' @format \code{\link{R6Class}} object.
#' @examples
#' # Instance at current working directory
#' w = Workspace$new(getwd())
#' # Create a package skeleton (roxygen2::create()),
#' # git init, copy some files,
#' # set documentation (devtools::document()),
#' # git commit and install
#' name = 'newLibrary'
#' # Create a Workspace object at working root directory (\code{getwd()})
#' w = Workspace$new()
#' # Create a library skeleton and git init
#' w$libraryCreate(name)
#' # Generate Rd documentation, pdf manual, build, install and git commit
#' w$libraryUpdate(name, 'version 0.0.0.9')
#'
#' @field root character. Stores absolute path of working root directory.
#' @section Methods:
#' \describe{
#'   \item{\code{new(Xroot = getwd())}}{This method is used to create object of this class with \code{Xroot} as absolute path for working root directory.}
#'
#'   \item{\code{folderCreate(XfolderList)}}{This method create folders (\code{dir.create}) given a list of paths (relative with respect to \code{Xroot}) by \code{folderList} parameter.}
#'   \item{\code{fileCreate(XfileList)}}{This method create files (\code{file.create}) given a list of paths (relative with respect to \code{Xroot}) by \code{fileList} parameter.}
#'   \item{\code{fileList(Xfolder='', Xpattern = '*', Xfull = TRUE, Xrecursive = FALSE)}}{This method returns a vector of relative paths (if \code{Xfull = FALSE} return filenames). Regex filters can be applied by \code{Xpattern} argument.}
#'   \item{\code{fileCopy(XfileList, Xfolder)}}{This method copy a list of files into a folder. All paths relative to \code{self$root}.}
#'   \item{\code{gitInit(Xfolder)}}{This method initialize (init && add --all && commit -m "Init") a git repository in a given \code{Xfolder}.}
#'   \item{\code{gitCommit(Xfolder, Xmessage)}}{The method commit (add . && commit -m "\code{Xmessage}") the git repository in a given \code{Xfolder}.}
#'   \item{\code{libraryCreate(Xlibrary)}}{This method creates skeleton package with \code{create()} function from \code{roxygen2}, adds forlder to complete the package skeleton and runs \code{gitInit()}.}
#'   \item{\code{libraryUpdate(Xlibrary)}}{This method updates package documentation (with \code{document()} function from \code{roxygen2}), creates a pfd manual, builds and installs the package and runs \code{gitCommit()}.}
#'	 \item{\code{readAllFiles(Xpath, Xpattern = '*.csv', Xbind = TRUE, X2env = TRUE)}}{This method import all files in a folder and returns a only \code{data.table}. If \code{Xbind = FALSE} returns a list of \code{data.table} with the same name than files and save in Global Environment. If \code{X2env = FALSE} returns a named list of \code{data.table}.}
#'	 \item{\code{rd2pdf(Xtitle, Xoutput, Xinput)}}{This method coverts an \code{Xinput} Rd file into \code{Xoutput} pdf with \code{Xtitle} from \code{Xroot}.}   
#'   \item{\code{runSystem(Xcommand)}}{This method run bash command typed in \code{Xcommand} from \code{self$root}.}
#'   }

Workspace = R6Class('Workspace',
                    lock_objects = FALSE,
                    public = list(
                      root = NULL,
                      git.dir = NULL,
                      git.email = NULL,
                      git.user = NULL,
                      so = NULL,
                      branches = list('master'),
                      commits = list(),
                      remote = NULL,
                      packages = NULL,
                      version = NULL,
                      description = NULL,
                      initialize = function(Xroot = getwd()) {
                        self$root = Xroot
                        self$so = Sys.info()[['sysname']]
                        self$version = paste0('Depends: R (>= ', R.version$major, '.', R.version$minor,')')
                        self$packages = self$version
                      },
                      folderCreate= function(XfolderList){
                        lapply(XfolderList, function(f){
                          dir.create(f, showWarnings = FALSE)
                        })
                      },
                      fileCreate = function(XfileList){
                        lapply(XfileList, function(f){
                          file.create(f, showWarnings = FALSE)
                        })
                      },
                      fileList = function(Xfolder='', Xpattern = '*', Xfull = TRUE, Xrecursive = FALSE){
                        return (list.files(path = file.path(folder), pattern = Xpattern, full.names = Xfull, recursive = Xrecursive))
                      },
                      fileCopy = function(XfileList, Xfolder){
                        lapply(XfileList, function(f){
                          file.copy(f, Xfolder, overwrite = T)
                        })
                      },
                      findFile = function(Xfile = 'git.exe', Xfolders = c('c:/program files', 'c:/program files (x86)')){
                        if (grepl('w|W', self$so)) {
                          # Windows
                          return (list.files(path = Xfolders, pattern = Xfile, full.names = TRUE, recursive = TRUE))
                          # self$git.dir = li.dir[[which(grepl('cmd',li.dir))]]
                        } else {
                          return (self$runCommand(paste0('sudo find ', Xfolders,' -print | grep -i ', Xfile)))
                        }
                      },
                      setGitUser = function(Xname = NULL, Xemail = NULL){
                        # if(!is.null(Xname)) self$runCommand(paste0('git config --global user.name "', gsub(" ", "", Xname, fixed = T), '" --replace-all'))
                        if(!is.null(Xname)) self$runCommand(paste0('git config --global user.name "', Xname, '"'))
                        if(!is.null(Xemail)) self$runCommand(paste0('git config --global user.email "', gsub(" ", "", Xemail, fixed = T), '"'))
                        message(system('powershell -command git config --list'))
                      },
                      setRemote = function(Xhttps = NULL, Xuser = NULL, Xpassword = NULL, Xrepository = NULL, Xhost = 'bitbucket.org'){
                        if(!is.null(Xuser) & !is.null(Xpassword) & !is.null(Xrepository)){
                          self$remote = paste0('https://', Xuser, ':', Xpassword, '@', Xhost, '/', Xuser, '/', Xrepository,'.git')
                          self$runCommand(paste0('git remote set-url origin ', self$remote))
                        } else {
                          self$remote = Xhttps
                          self$runCommand(paste0('git remote add origin ', self$remote))
                        }
                      },
                      setDescription = function(Xfolder, Xtext, Xlines, Xadd = F){
                        self$description = readLines(file.path(self$root, Xfolder, 'DESCRIPTION'), n = -1)
                        for(i in 1:length(Xlines)){
                          self$description[Xlines[i]] = Xtext[i]
                          if (Xadd) self$description[Xlines[i]] = paste(self$description[Xlines[i]], Xtext[i])
                        }
                        writeLines(self$description, file.path(self$root, Xfolder,'DESCRIPTION'))
                      },
                      gitInit = function(Xfolder, Xhttps = NULL, Xname = NULL, Xemail = NULL, Xuser = NULL, Xpassword = NULL, Xrepository = NULL, Xbranch = 'master', Xhost = 'bitbucket.org'){
                        if(!is.null(Xname) | !is.null(Xemail)) self$setGitUser(Xname, Xemail)
                        setwd(Xfolder)
                        self$runCommand(paste0('git init && git add --all && ', shQuote('git commit -m "Init"')))
                        if(!is.null(Xhttps)) self$runCommand(paste0('git remote add origin ', Xhttps))
                        # if(is.null(Xhttps) & !is.null(Xuser) & !is.null(Xpassword) & !is.null(Xrepository)) self$runCommand(paste0('git remote add origin https://', Xuser, '@', Xhost, '/', Xuser, '/', Xrepository, '.git'))
                        setwd(self$root)
                        # if(!is.null(Xhttps) | (!is.null(Xuser) & !is.null(Xpassword) & !is.null(Xrepository)))  self$gitPush(Xfolder, Xhttps, Xuser, Xpassword, Xrepository, Xbranch, Xhost)
                      },
                      gitCommit = function(Xfolder, Xmessage, Xhttps = NULL, Xname = NULL, Xemail = NULL, Xuser = NULL, Xpassword = NULL, Xrepository = NULL, Xbranch = 'master', Xhost = 'bitbucket.org', Xforce = F){
                        if(!is.null(Xname) | !is.null(Xemail)) self$setGitUser(Xname, Xemail)
                        self$gitBranch(Xfolder, Xbranch)
                        setwd(Xfolder)
                        self$runCommand('git add --all')
                        self$runCommand(shQuote(paste0('git commit -m "', Xmessage, '"', ifelse(Xforce, ' --force', ''))))
                        setwd(self$root)
                        if(!is.null(Xhttps) | (!is.null(Xuser) & !is.null(Xpassword) & !is.null(Xrepository))) self$gitPush(Xfolder, Xhttps, Xuser, Xpassword, Xrepository, Xbranch, Xhost, Xforce)
                        self$commits[[length(self$commits) + 1]] = paste(Xmessage, Sys.time(), Xbranch, sep = ' - ')
                      },
                      gitPush = function(Xfolder, Xhttps = NULL, Xuser = NULL, Xpassword = NULL, Xrepository = NULL, Xbranch = 'master', Xhost = 'bitbucket.org', Xforce = F){
                        setwd(Xfolder)
                        if(is.null(self$remote)) self$setRemote(Xhttps, Xuser, Xpassword, Xrepository, Xhost)
                        system(paste0('git push -u origin ', Xbranch, ifelse(Xforce, '--force', '')))
                        setwd(self$root)
                      },
                      gitBranch = function(Xfolder, Xname){
                        setwd(Xfolder)
                        branches = self$runCommand('git show-branch --all')
                        if (!grepl(Xname, paste(branches, collapse = ''))){
                          self$runCommand(paste0('git checkout -b ', Xname))
                          self$branches[[length(self$branches) + 1]] = paste(Sys.time(), Xname, sep = ' - ')
                        }
                        setwd(self$root)
                      },
                      addPackages2Description = function(Xlibrary, Xpackages = NULL, Xadd = F){
                        if (!is.null(Xpackages)){
                          if (Xadd) self$packages = unique(c(self$packages, Xpackages))
                          else self$packages = c(self$version, Xpackages)
                        } else {
                          temp = loaded_packages()$package[which(sapply(loaded_packages()$path, grepl, pattern = '/R/') & !sapply(loaded_packages()$package, grepl, pattern = Xlibrary))]
                          if (Xadd) self$packages = unique(c(self$packages, temp)) 
                          else self$packages = c(self$version, temp)
                        }
                        self$setDescription(Xlibrary, Xtext = paste(self$packages, collapse = ', '), Xlines = 6)
                      },
                      libraryCreate = function(Xlibrary, Xhttps = NULL, Xname = NULL, Xemail = NULL, Xuser = NULL, Xpassword = NULL, Xrepository = NULL, Xbranch = 'master', Xhost = 'bitbucket.org', XloadPackages = T, Xlines = NULL, Xtext = NULL, XcheckDescription = T){
                        # Create folders (R & man) and metadata in DESCRIPTION file.
                        create(Xlibrary)
                        # Create complete package skeleton
                        self$folderCreate(as.list(paste(Xlibrary,
                                                        c('man','data','vignettes',
                                                          'demo','test','src','exec',
                                                          'inst','inst/extdata'), sep = '/')))
                        # if (XcheckDescription) self$checkDescription(Xlibrary, Xname, Xemail)
                        if (XloadPackages) self$addPackages2Description(Xlibrary)
                        if(!is.null(Xtext) & !is.null(Xlines)) self$setDescription(Xlibrary, Xtext, Xlines)
                        self$gitInit(Xlibrary, Xhttps, Xname, Xemail, Xuser, Xpassword, Xrepository, Xbranch, Xhost)
                      },
                      libraryUpdate = function(Xlibrary, Xmessage, Xhttps = NULL, Xname = NULL, Xemail = NULL, Xuser = NULL, Xpassword = NULL, Xrepository = NULL, Xbranch = 'master', Xhost = 'bitbucket.org', XloadPackages = T, Xlines = NULL, Xtext = NULL, XcheckDescription = T, Xforce = F){
                        # Create documentation as .Rd files in man directory
                        document(Xlibrary)
                        message('Documentation generated in Rd.')
                        # Generate manual pdf
                        system(paste0('R CMD Rd2pdf -o ', file.path(self$root, Xlibrary, paste0(Xlibrary,'.pdf')), ' --force ', Xlibrary))
                        message('Documentation generated in pdf.')
                        # Build package
                        build(Xlibrary, path = Xlibrary, vignettes = T, manual = T) 
                        message('Package Builded.')
                        # Check package
                        check(Xlibrary, manual = T, args = '--no-examples') 
                        message('Package Checked.')
                        # Install package
                        install(Xlibrary, build_vignettes = T, dependencies = T, force_deps = T, local = F)
                        message('Package Installed.')
                        # Load Packages and set Description
                        # if (XcheckDescription) self$checkDescription(Xlibrary, Xname, Xemail)
                        # if (XloadPackages) self$addPackages2Description(Xlibrary)
                        if(!is.null(Xtext) & !is.null(Xlines)) self$setDescription(Xlibrary, Xtext, Xlines)
                        # Git commit
                        self$gitCommit(Xlibrary, Xmessage, Xhttps, Xname, Xemail, Xuser, Xpassword, Xrepository, Xbranch, Xhost, Xforce)
                        message('Commit finish.')
                      },
                      checkDescription = function(Xlibrary, Xname, Xemail){
                        if (is.null(self$description)) self$description = readLines(file.path(self$root, Xlibrary, 'DESCRIPTION'), n = -1)
                        if (is.null(self$version)) self$version = self$description[6]
                        if (is.null(self$packages)) self$packages = self$version
                        if (!is.null(Xname) & !is.null(Xemail)){
                          self$setDescription(Xlibrary, 
                                              Xtext = paste0('Authors@R: person(\"', strsplit(Xname, " ")[[1]][1], '\", \"', strsplit(Xname, " ")[[1]][2], '\", email = \"', Xemail, '\", role = c(\"aut\", \"cre\"))'),
                                              Xlines = 4)
                        }
                      },
                      rd2pdf = function(Xtitle, Xoutput , Xinput){
                        system(paste0('R CMD Rd2pdf --title:', Xtitle,' -o ', Xoutput,'.pdf --force ', Xinput,'.Rd'))
                      },
                      runFile = function(Xfile){
                        f = path.expand(Xfile)
                        if (!file.exists(f)) {
                          stop('File not found!')
                        }
                        if (grepl('w|W', self$so)) {
                          # Windows
                          shell.exec(f) #nolint
                        } else {
                          if (grepl('darwin', version$os)) {
                            # Mac
                            system(paste(shQuote('open'), shQuote(f)), wait = FALSE, ignore.stderr = TRUE)
                          } else {
                            # Linux
                            system(paste(shQuote('/usr/bin/xdg-open'), shQuote(f)), #nolint
                                   wait = FALSE,
                                   ignore.stdout = TRUE)
                          }
                        }
                      },
                      runCommand = function(Xcommand, XPS = T){
                        # command = path.expand(Xcommand)
                        command = strsplit(Xcommand, ' && ')[[1]]
                        outs = list()
                        for(i in 1:length(command)){
                          if (grepl('w|W', self$so)) {
                            # Windows
                            if (XPS) cmd = paste0('powershell -command ', command[i])
                            else cmd = command[i]
                            message(paste0('running cmd > ', cmd))
                            outs[[i]] = system(cmd, intern = T, ignore.stdout = F, ignore.stderr = F)
                          } else {
                            # Mac or Linux
                            message(paste0('runing bash > ', command[i]))
                            outs[[i]] = system(shQuote(command[i]), wait = FALSE, ignore.stderr = TRUE)
                          }
                        }
                        return (outs)
                      }
                    )
)
