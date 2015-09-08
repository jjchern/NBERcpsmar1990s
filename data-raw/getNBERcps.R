# Download raw data from NBER

library(magrittr)
library(stringr)
library(haven)
library(devtools)

getNBERcps = function(year) {

  file = paste0("cpsmar", substr(as.character(year), 3, 4))
  file.zip = paste0(file, ".zip")
  url.zip = paste0("http://www.nber.org/cps/", file.zip)

  download.file(url.zip, file.zip)
  unzip(file.zip)
  unlink(file.zip)

  if (year == 1998) {
    file.rename("mar98pub.cps", "cpsmar98.dat")
  } else if (year == 1999) {
    file.rename("mar99pub.cps", "cpsmar99.dat")
  }

  file.dct = paste0(file, ".dct")
  url.dct = paste0("http://www.nber.org/data/progs/cps/", file.dct)
  download.file(url.dct, file.dct)

  file.do = paste0(file, ".do")
  url.do = paste0("http://www.nber.org/data/progs/cps/", file.do)
  download.file(url.do, file.do)

  file.dat = paste0(file, ".dat")

  if (year == 1999) {
    readLines(file.do) %>%
      str_replace(paste0("log using ", file, ", text replace"), "clear") %>% # no log
      str_replace("/homes/data/cps/cpsmar99.dat", "cpsmar99.dat") %>%
      str_replace(paste0("save ", file, ",replace"), paste0("save ", file, ", replace;")) %>% # added a ";"
      writeLines(file.do)

  } else {

    readLines(file.dct) %>%
      str_replace(paste0("/home/data/cps/", file, ".raw"), file.dat) %>%
      writeLines(file.dct)

    readLines(file.do) %>%
      str_replace(paste0("log using ", file, ", replace"), "clear") %>% # no log
      str_replace(paste0("save ", file, ",replace"), paste0("save ", file, ", replace;")) %>% # added a ";"
      writeLines(file.do)
  }

  cat("Start creating Stata dta file")
  stata = paste0("/Applications/Stata/StataSE.app/Contents/MacOS//stata-se -b ", file.do)
  system(stata)

  file.log = paste0(file, ".log")
  unlink(file.dat)
  unlink(file.dct)
  unlink(file.do)
  unlink(file.log)

}

getNBERcps(1990)
cpsmar90 = read_dta("cpsmar90.dta")
use_data(cpsmar90, overwrite = TRUE)
unlink("cpsmar90.dta")

getNBERcps(1991)
cpsmar91 = read_dta("cpsmar91.dta")
use_data(cpsmar91, overwrite = TRUE)
unlink("cpsmar91.dta")

getNBERcps(1992)
cpsmar92 = read_dta("cpsmar92.dta")
use_data(cpsmar92, overwrite = TRUE)
unlink("cpsmar92.dta")

getNBERcps(1993)
cpsmar93 = read_dta("cpsmar93.dta")
use_data(cpsmar93, overwrite = TRUE)
unlink("cpsmar93.dta")

getNBERcps(1994)
cpsmar94 = read_dta("cpsmar94.dta")
use_data(cpsmar94, overwrite = TRUE)
unlink("cpsmar94.dta")

getNBERcps(1995)
cpsmar95 = read_dta("cpsmar95.dta")
use_data(cpsmar95, overwrite = TRUE)
unlink("cpsmar95.dta")

getNBERcps(1996)
cpsmar96 = read_dta("cpsmar96.dta")
use_data(cpsmar96, overwrite = TRUE)
unlink("cpsmar96.dta")

getNBERcps(1997)
cpsmar97 = read_dta("cpsmar97.dta")
use_data(cpsmar97, overwrite = TRUE)
unlink("cpsmar97.dta")

getNBERcps(1998)
cpsmar98 = read_dta("cpsmar98.dta")
use_data(cpsmar98, overwrite = TRUE)
unlink("cpsmar98.dta")

getNBERcps(1999)
cpsmar99 = read_dta("cpsmar99.dta")
use_data(cpsmar99, overwrite = TRUE)
unlink("cpsmar99.dta")


# Note:
# The originally released 1994 ASEC file contained an error in `h_idnum`.
# The error is discussed in User  CURRENT POPULATION SURVEY, MARCH 1995 -
# User Note 2 (https://www.nber.org/morg/docs/usernote.asc).
# A corrected file was also made aviable via NBER.
# The corrected file, which can be downloaded in http://www.nber.org/cps/h_idnum_mar94.html,
# contains two variables: `h_seq` and `h_idnum`, where
# the `h_seq` is an identifying number unique to each household in a given survey,
# and `h_id_num` is the corrected `h_id_num`.
# The following script downloads the corrected file, and merges into `cpsmar94.rda`.
# The initial `h_idnum` is renamed as `h_idnum_init`.
# Thus, in the data package, `cpsmar94.rda` contains a corrected `h_idnum`.

h_idnum_mar94 = read.table("http://www.nber.org/cps/h_idnum_mar94.dat", sep = " ",
           col.names = c("h_seq", "h_idnum"))
h_idnum_mar94 %>% tbl_df()  # in total, there're 73,126 families

library(dplyr)
cpsmar94 = cpsmar94 %>%
  rename(h_idnum_init = h_idnum) %>%
  left_join(h_idnum_mar94, by = "h_seq")

attr(cpsmar94$h_idnum, "label") = "Household identification number (corrected)"
attr(cpsmar94$h_idnum_init, "label") = "Household identification number (initial)"
use_data(cpsmar94, overwrite = TRUE)
