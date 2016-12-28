# pvR

*pvR* is an R package which provides an R6class **Workspace.R** with methods to easy create and update an R package. 

* Full R-package skeleton creation
* Roxygen2 documentation to pdf manual
* Git 
* Install and build

Therefore implements functions for working with archives: files, folders, git, Rd2pdf, python scripts and bash.

## Installation

 Install package from this repository
 
 ```R
 
 install.packages('devtools')
 
 library('devtools')
 
 devtools::install_github('JoanViana/devR')
 
 ```
 
 or [download](https://github.com/JoanViana/pvR/blob/master/devR_0.0.0.9000.tar.gz) and install from source:
 
 ```R
 
 install.packages(path_to_file, repos = NULL, type="source")
 
 ```
 Where *path_to_file* could be:
 * On Windows it will look something like this: C:\Users\user\Downloads\devR_0.0.0.9000.tar.gz.
 * On UNIX it will look like this: /home/user/download/devR_0.0.0.9000.tar.gz.
 
##### Windows users: Activate *Windows PowerShell* and *GIT* running:

```bat 
@ECHO OFF

REM.-- Unblock PowerShell Security defaults: run signed scripts
Powershell -command Set-ExecutionPolicy RemoteSigned -Force

REM.-- Install PSget: http://psget.net/
Powershell -command "(new-object Net.WebClient).DownloadString(\"http://psget.net/GetPsGet.ps1\") | iex"

REM.-- Install poshgit: https://github.com/dahlbyk/posh-git
Powershell -command Install-Module posh-git

REM.-- Add PATH to System
REM.-- SETX /M path "%path%;C:\Program Files\Git\cmd\"

PAUSE
```

## Usage

Check the [Controller Demo](https://github.com/JoanViana/pvR/blob/master/demo/devControlleR.R) and the [Documentation](https://github.com/JoanViana/pvR/blob/master/devR.pdf)

Workflow example: Create a hosted git repository and an R project (myProject.Rproj) in your workspace from RStudio and type from your Controller script:

```R
# Load devR package
library(devR)

# Create an instance of R6Class in root directory
w = Workspace$new(getwd())

# Name new library 
lib = 'myLibrary'

# Create new library in root directory and git init, config user and add remote
w$libraryCreate(Xlibrary = lib, Xname = 'Your Name and Surname', Xemail = 'your email', Xhttps = 'https of git repository')

# Now it is time to develop the package ...

  # Example: copy files from workspace to the new library directory
  w$fileCopy(c('LICENSE', 'README.md'), file.path(lib))
  w$fileCopy(c('Workspace.R'), file.path(lib, 'R'))
  w$fileCopy(c('devControlleR.R'), file.path(lib, 'demo'))
  w$setDescription(lib, Xtext = "License: MIT + file LICENSE", Xlines = 7)  
  
# Create documentation, manual pdf, build, install and git add, commit & push
w$libraryUpdate(Xlibrary = lib, Xmessage = 'commit message', Xuser = 'git user', Xpassword = 'git password', Xrepository = 'repository name', Xbranch = 'master', Xhost = 'git host')

# Example creating a new branch, checkout & push 
w$libraryUpdate(Xlibrary = lib, Xmessage = 'version 0.0.0.9002', Xuser = 'JoanViana', Xpassword = 'my_password', Xrepository = 'devR', Xbranch = 'new_branch', Xhost = 'bitbucket.org')

```

## Issues

1. DESCRIPTION (Depends line) edition in *Workspace$libraryCreate()*
    * Task 1: Debug and test.
2. Choose if add or edit in *git config --global user.name*

## Next Tasks (Features & Documentation)

1. Add an example with *devtools::install_github()*. Take into account public and private repositories.
2. New workflow for contributing
3. Roxygen2 Documentation of R/Workspace.R and compile it by libraryUpdate() && modify paths of README.md.
4. Rpubs, pdf = vignettes, git webpage (index.html), ... of script I want. 

## Contributing

1. Fork it!
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Submit a pull request :D

## Author

Joan Dídac Viana Fons - <joanvianafons@gmail.com>

## License

MIT - Please, read [LICENSE](https://github.com/JoanViana/pvR/blob/master/LICENSE)
