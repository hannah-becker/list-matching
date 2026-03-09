#extract elements of a list by matching names ----


#requirements ----
library(readxl)
library(writexl)
library(dplyr)

#housekeeping ----
#uncomment and run if necessary
#options(timeout = max(300, getOption("timeout"))) #defaults to 60s which might be too short for larger files and poor wifi


#get data ----
#url <- "https://www.lanuk.nrw.de/fileadmin/lanuvpubl/3_fachberichte/Artenverzeichnis_Farn-_u._Bl%C3%BCtenpflanzen_2022-04-05.xlsx"

#download.file(url, destfile = "./official_lists/plants_nrw.xlsx")

offlist <- readxl::read_xlsx("./official_lists/plants_nrw.xlsx", skip = 3) #trim leading superfluous data, adjust as needed


list <- readxl::read_excel("./data/test_data.xlsx") #can read xlsx and xls files, if you're using smth else you're probably familiar with read.csv/csv2, adjust accordingly


# find matches ----
index <- pmatch(list[[1]], offlist[[3]]) # if you're not interested in partial matches (e.g. Draba verna returning a match for Draba verna agg. in the official list) you can run this as match(...) instead

matches <- offlist[na.omit(index), ]
missing <- list[which(is.na(index)), ][[1]]
print(paste0("not matched: ", missing)) #all species listed here were not found on the official list. If the official list is comprehensive, check these for spelling and potential taxonomy changes and rerun if necessary


m <- grepl("\\.|\\s[x]\\s|(\\w+\\s(\\w+|\\w+\\-\\w+)\\s\\w+)", matches[[3]],  perl = TRUE)
#r does not play nice with regex look behinds so we'll instead look for this beast
#finds names in which . has been used (catches s.str., s.l., agg., subsp.), " x " has been used (catches hybrids) or in which the taxon name consists of more than just genus and species epithet (catches subspecies that were not explicitly declared)
#all of the above are then flagged for manual verification. 

matches <- cbind(manual_check_recommended = m, not_found = "", matches)

#add not-found species back to the list:

matches <- rows_insert(matches, tibble(not_found = missing, manual_check_recommended = TRUE))

#as it stands rn it cannot handle to-be-matched lists in which species are listed with proper authority a la Hyacinthoides italica (L.) Rothm.
#if that is a feature we might need lmk and I'll see about implementing that

writexl::write_xlsx(matches, "./data/matches.xlsx") #will overwrite preexisting files with this name


