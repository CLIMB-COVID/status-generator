library(tidyverse)
library(hrbrthemes)

args = commandArgs(trailingOnly=TRUE)

df <- read_tsv(args[1])
df <- df[df$published_date <= args[2],]

dfc <- df %>% 
    group_by(published_date) %>%
    summarise(pag_count = n())

p <- ggplot(dfc, aes(x=published_date, y=cumsum(pag_count))) +
    geom_area(
        fill="#002366"
    ) +
    scale_x_date(expand=c(0,0), date_labels = "%b\n%Y", date_breaks = "1 month", limit=c(as.Date("2020-03-01"),max(df$published_date))) +
    scale_y_continuous(
        expand=c(0.0,0),
        breaks=seq(0,sum(dfc$pag_count),100000),
        minor_breaks=c(),
        labels=scales::comma,
        limits=c(0,sum(dfc$pag_count)+10000)
    ) +
    theme(
        axis.title=element_text(size=8, colour="#8B7968"),
        axis.text.x=element_text(size=6, angle=0, hjust=0),
        axis.text.y=element_text(size=8),
        panel.grid.major.x = element_blank(),
        panel.grid.minor.x = element_blank(),
        axis.ticks.x = element_line(size=0.1, colour="#002366"),
        axis.ticks.y = element_line(size=0.1),

        panel.background = element_rect(
            fill = alpha("#8B7968", 0.4),
            size = 0,
        ),
    ) +
    xlab("Date") +
    ylab("Cumulative genomes processed")

ggsave("dat/fig1.png", width=16, height=7, unit="cm")


# Output basic metadata
total_pags <- nrow(df)
today_pags <- nrow(df[df$published_date == args[2],])

dft <- data.frame(c(total_pags), c(today_pags))
write_tsv(dft, 'dat/fig1.dat', col_names=F)

## Fig1b
library(lubridate)

CUTOFF_DAYS <- 30
start_cutoff <- as.Date(args[2]) - CUTOFF_DAYS # N days ago
dfd <- dfc[dfc$published_date >= start_cutoff,]
dfd$month <- month(dfd$published_date, label=TRUE, abbr=FALSE)
dfd$year <- year(dfd$published_date)

q <- ggplot(dfd, aes(x=published_date, y=pag_count)) +
    geom_bar(
        stat="identity",
        fill="#002366",
    ) +
    scale_x_date(expand=c(0.01,0.01), date_labels = "%d", date_breaks = "1 day") +
    scale_y_continuous(
        expand=c(0.0,0.0),
        breaks=seq(0,max(dfd$pag_count),1000),
        minor_breaks=seq(0,max(dfd$pag_count),500),
        labels=scales::comma,
        limits=c(0,max(dfd$pag_count)+100)
    ) +
    facet_grid(~year+month, scales="free_x", space = "free_x", switch="both") +
    theme(
        axis.title=element_text(size=8, colour="#8B7968"),
        axis.text.x=element_text(size=6, angle=0, hjust=0.5),
        axis.text.y=element_text(size=8),
        panel.grid.major.x = element_blank(),
        panel.grid.minor.x = element_blank(),
        axis.ticks.x = element_line(size=0.1, colour="#002366"),
        axis.ticks.y = element_line(size=0.1),

        panel.background = element_rect(
            fill = alpha("#8B7968", 0.4),
            size = 0,
        ),
        strip.placement = "outside",
        strip.text = element_text(size=5, margin=margin(b = 0.5, t = 0.5)),
    ) +
    xlab(paste("Elan processed date (last", CUTOFF_DAYS, "days)")) +
    ylab("Daily genomes processed")

ggsave("dat/fig1b.png", width=16, height=7, unit="cm")


dfe <- df %>% 
    mutate(collection_date = coalesce(collection_date, received_date)) %>% # Use received date if collection missing
    group_by(collection_date) %>%
    summarise(pag_count = n()) %>%
    complete(collection_date = seq.Date(start_cutoff, as.Date(args[2]), by="days"))

dfe[is.na(dfe$pag_count),]$pag_count <- 0
dfe <- dfe[dfe$collection_date >= start_cutoff,]

dfe$month <- month(dfe$collection_date, label=TRUE, abbr=FALSE)
dfe$year <- year(dfe$collection_date)

r <- ggplot(dfe, aes(x=collection_date, y=pag_count)) +
    geom_bar(
        stat="identity",
        fill="#002366",
    ) +
    #scale_x_date(expand=c(0.01,0.01), date_labels = "%d", date_breaks = "1 day", limit=c(start_cutoff, args[1])) +
    scale_x_date(expand=c(0.01,0.01), date_labels = "%d", date_breaks = "1 day") +
    scale_y_continuous(
        expand=c(0.0,0.0),
        breaks=seq(0,max(dfe$pag_count),1000),
        minor_breaks=seq(0,max(dfe$pag_count),500),
        labels=scales::comma,
        limits=c(0,max(dfe$pag_count)+100)
    ) +
    facet_grid(~year+month, scales="free_x", space = "free_x", switch="both") +
    theme(
        axis.title=element_text(size=8, colour="#8B7968"),
        axis.text.x=element_text(size=6, angle=0, hjust=0.5),
        axis.text.y=element_text(size=8),
        panel.grid.major.x = element_blank(),
        panel.grid.minor.x = element_blank(),
        axis.ticks.x = element_line(size=0.1, colour="#002366"),
        axis.ticks.y = element_line(size=0.1),

        panel.background = element_rect(
            fill = alpha("#8B7968", 0.4),
            size = 0,
        ),
        strip.placement = "outside",
        strip.text = element_text(size=5, margin=margin(b = 0.5, t = 0.5)),
    ) +
    xlab(paste("Sample collection date (last", CUTOFF_DAYS, "days)")) +
    ylab("Genomes processed")

ggsave("dat/fig1c.png", width=16, height=7, unit="cm")
