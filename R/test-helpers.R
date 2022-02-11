local_create_package <- function(dir = fs::file_temp(), env = parent.frame()) {
  old_project <- usethis::proj_get()
  
  # create new folder and package
  usethis::create_package(dir, open = FALSE) # A
  withr::defer(fs::dir_delete(dir), envir = env) # -A
  
  # change working directory
  setwd(dir) # B
  withr::defer(setwd(old_project), envir = env) # -B
  
  # switch to new usethis project
  usethis::proj_set(dir) # C
  withr::defer(proj_set(old_project, force = TRUE), envir = env) # -C
  
  dir
}