do_package_checks()

if (Sys.getenv("DEV_VERSIONS") != "") {
  get_stage("install") %>%
    add_step(step_install_github("facebook/prophet", subdir = "R"))
}

if (Sys.getenv("BUILD_PKGDOWN") != "" && ci()$get_branch() == "master") {
  get_stage("before_deploy") %>%
    add_step(step_setup_ssh()) %>%
    add_step(step_setup_push_deploy(path = "docs", branch = "gh-pages"))

  get_stage("deploy") %>%
    add_code_step(
      pkgbuild::compile_dll(),
      prepare_call = remotes::install_github("r-lib/pkgbuild")
    ) %>%
    add_step(step_build_pkgdown(run_dont_run = TRUE)) %>%
    add_step(step_do_push_deploy(path = "docs"))
}
