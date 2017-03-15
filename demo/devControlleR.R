# # Load all the dependencies needed in the package to be created
# # library(...)
# library(R6)
# library(devtools)
# library(roxygen2)
# # Load R6Class
# source('Workspace.R')
library(devR)

# Create an instance of R6Class in root directory
w = Workspace$new(getwd())

# Name new library 
name = 'devR'

# Create new library in root directory and git init
# w$libraryCreate(name, Xname = 'Joan Viana', Xemail = 'joanvianafons@gmail.com', Xhttps = 'https://JoanViana@bitbucket.org/JoanViana/devr.git')
# w$libraryCreate(name, Xname = 'Joan Viana', Xemail = 'joanvianafons@gmail.com', Xhttps = 'https://github.com/JoanViana/devR.git')

# Now it is time to develop the package ...
  # Example: copy files
  w$fileCopy(c('LICENSE', 'README.md'), file.path(name))
  w$fileCopy(c('Workspace.R'), file.path(name, 'R'))
  w$fileCopy(c('devControlleR.R'), file.path(name, 'demo'))
  # w$setDescription(name, Xtext = "License: MIT + file LICENSE", Xlines = 7)
  
  
# Create documentation, manual pdf, build, install and git add, commit & push: Xhost = 'bitbucket.org' or Xhost = 'github.com'
# w$libraryUpdate(name,'version 0.0.0.9000', Xname = 'Joan Viana', Xemail = 'joanvianafons@gmail.com',
#                 Xuser = 'JoanViana', Xpassword = 'Pikaporte123', Xrepository = 'devr', Xbranch = 'master', Xhost = 'bitbucket.org')
w$libraryUpdate(name,'version 0.0.0.9000', Xname = 'Joan Viana', Xemail = 'joanvianafons@gmail.com',
                Xuser = 'JoanViana', Xpassword = '...', Xrepository = 'devR', Xbranch = 'master', Xhost = 'github.com')

##############################################################################################

# Load installed library
library(myLibrary)

# Enjoy your package...
getwd()
w.test = Workspace$new(getwd())

# Name new library 
name.test = 'Test'

# Create new library in root directory and git init
w.test$libraryCreate(name.test, Xname = 'Joan Viana', Xemail = 'joanvianafons@gmail.com', Xhttps = 'https://JoanViana@bitbucket.org/JoanViana/test4.git',
                     Xuser = 'JoanViana', Xpassword = '...', Xrepository = 'test3', Xbranch = 'master', Xhost = 'bitbucket.org')

# Now it is time to develop the package ...
# Example: copy files
w.test$fileCopy(c('LICENSE', 'README.md'), file.path(name.test))
w.test$fileCopy(c('Workspace.R'), file.path(name.test, 'R'))
w.test$fileCopy(c('devController.R'), file.path(name.test, 'demo'))
w.test$setDescription(name.test, Xtext = "License: MIT + file LICENSE", Xlines = 7)

# Create documentation, manual pdf, build, install and git commit: Xhost = 'bitbucket.org' or Xhost = 'github.com'
w.test$libraryUpdate(name.test,'version 0.0.0.9000', Xname = 'Joan Viana', Xemail = 'joanviana@gmail.com', 
                     Xuser = 'JoanViana', Xpassword = '...', Xrepository = 'test3', Xbranch = 'master', Xhost = 'bitbucket.org')


