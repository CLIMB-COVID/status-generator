library(tidyverse)
library(lubridate)

args = commandArgs(trailingOnly=TRUE)

df <- read_tsv(args[1], col_types="cc")
df$date <- parse_date(df$date, format="%Y%m%d")
df$go <- TRUE

df <- df %>%
    complete(service, date = seq.Date(min(df$date), as.Date(args[2]), by="days"))
df[is.na(df$go),]$go <- FALSE

CUTOFF_DAYS <- 180
start_cutoff <- as.Date(args[2]) - CUTOFF_DAYS # N days ago
df <- df[df$date >= start_cutoff,]
df <- df[df$date <= as.Date(args[2]),]

df$month <- month(df$date, label=TRUE, abbr=FALSE)
df$year <- year(df$date)


p <- ggplot(df, aes(x=date, y=service)) + geom_tile(aes(fill=go)) +
    scale_x_date(expand=c(0.0,0.0), date_labels = "%d", date_breaks = "1 day") +
    scale_y_discrete(expand=c(0,0)) +
    facet_grid(~year+month, scales="free_x", space = "free_x", switch="both") +
    scale_fill_manual(values = c("TRUE" = "#005AB5", "FALSE" = "#DC3220")) +
    theme(
        axis.title=element_text(size=8, colour="#8B7968"),
        axis.text.x=element_text(size=5, angle=90, hjust=0.5, vjust=0.5),
        axis.text.y=element_text(size=8),
        panel.grid.major.y = element_blank(),
        panel.grid.minor.y = element_blank(),
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
        legend.position = "none",
    ) +
    xlab(paste("Date (last", CUTOFF_DAYS, "days)")) +
    ylab("Service")

ggsave("dat/fig2.png", width=16, height=4, unit="cm")
