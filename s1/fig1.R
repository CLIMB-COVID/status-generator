library(tidyverse)
library(hrbrthemes)
library(ggrepel)
library(patchwork)
library(lubridate)


args = commandArgs(trailingOnly=TRUE)

common_theme <- theme (
    axis.title=element_text(size=7, colour="#8B7968"),
)

df <- read_tsv(args[1])
df <- df[df$published_date <= args[2],]

dfc <- df %>% 
    group_by(published_date) %>%
    summarise(pag_count = n()) %>%
    complete(published_date=seq.Date(min(published_date), max(published_date), by="day")) # add missing days so we can annotate them, AFTER counting
dfc$pag_count <- replace_na(dfc$pag_count, 0) # change NA to 0

annotations <- read_delim(args[3], delim='\t', escape_backslash=TRUE, escape_double=FALSE)
dfc <- left_join(dfc, annotations)

dfc$pag_count_cumsum <- cumsum(dfc$pag_count)
filtered <- dfc %>% filter(label != "")

big_count <- format(sum(dfc$pag_count), big.mark = ",", scientific = FALSE)
p1 <- ggplot(dfc, aes(x=published_date, y=pag_count_cumsum)) +
    geom_area(
    ) +
    scale_x_date(expand=c(0,0), date_labels = "%b\n%Y", date_breaks = "1 month", limit=c(as.Date("2020-03-01"),max(df$published_date)), position="bottom") +
    scale_y_continuous(
        expand=c(0.0,0),
        breaks=seq(0,sum(dfc$pag_count),50000)[-1],
        minor_breaks=c(),
        labels=scales::comma,
        limits=c(0,sum(dfc$pag_count)+10000)
    ) +
    common_theme +
    theme(
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

        plot.margin=margin(b=0, unit="cm"),
        axis.title.x = element_blank(),
    ) +
    geom_text_repel(
        aes(label=label),
        angle=90,
        vjust="middle",
        hjust="left",
        size=1.8,
        max.overlaps=Inf,
        data=filtered,
        direction="x",
        segment.size=0.25,
        lineheight=1,
        ylim = c(NA, NA),
        nudge_y=75000,
    ) +
    annotate(geom='text', label=big_count, x=max(df$published_date)-1, y=15000, vjust = "inward", hjust = "right", colour="white", size=6, alpha=0.5) +
    xlab("Date") +
    ylab("Cumulative genomes processed by\nElan on CLIMB-COVID")


#dfe <- df %>% 
#    mutate(collection_date = coalesce(collection_date, received_date)) %>% # Use received date if collection missing
#    group_by(collection_date) %>%
#    summarise(pag_count = n())
#dfe[is.na(dfe$pag_count),]$pag_count <- 0
#p2 <- ggplot(dfe, aes(x=collection_date, y=pag_count)) +

dfc_week <- df %>%
    group_by(week_start = cut(published_date, "week", start.on.monday = TRUE)) %>%
    arrange(week_start) %>%
    summarise(pag_count = n())

print(dfc_week, n=100)

p2 <- ggplot(dfc_week, aes(x=as.Date(week_start), y=pag_count)) +
    geom_bar(
        stat='identity',
        width=7,
    ) +
    scale_x_date(expand=c(0,0), date_labels = "%b\n%Y", date_breaks = "1 month", limit=c(as.Date("2020-03-01"),max(df$published_date)), position="top") +
    scale_y_continuous(
        expand=c(0,0),
        limit=c(0, max(dfc_week$pag_count)+5000),
        labels=scales::comma,
        breaks=seq(0,max(dfc_week$pag_count+10000),10000)[-1],
        minor_breaks=c(),
    ) +
    common_theme +
    theme(
        plot.margin=margin(t=0, unit="cm"),
        axis.text.y=element_text(size=8),
        panel.grid.major.x = element_blank(),
        panel.grid.minor.x = element_blank(),
        axis.ticks.x = element_line(size=0.1, colour="#002366"),
        axis.ticks.y = element_line(size=0.1),
        axis.title.x=element_blank(),

        panel.background = element_rect(
            fill = alpha("#8B7968", 0.2),
            size = 0,
        ),

        axis.text.x = element_blank(),
    ) +
    ylab("Weekly\ngenomes")


gov_df <- read_csv(args[4])
head(gov_df)
p3 <- ggplot(gov_df, aes(x=date, y=newCasesBySpecimenDate)) +
    geom_bar(
        stat='identity',
        width=1,
    ) +
    scale_x_date(expand=c(0,0), date_labels = "%b\n%Y", date_breaks = "1 month", limit=c(as.Date("2020-03-01"),max(df$published_date)), position="top") +
    scale_y_continuous(
        expand=c(0,0),
        limit=c(0, max(gov_df$newCasesBySpecimenDate)+1000),
        labels=scales::comma,
        breaks=seq(0,max(gov_df$newCasesBySpecimenDate+20000),20000)[-1],
        minor_breaks=c(),
    ) +
    common_theme +
    theme(
        plot.margin=margin(t=0, unit="cm"),
        axis.text.y=element_text(size=8),
        panel.grid.major.x = element_blank(),
        panel.grid.minor.x = element_blank(),
        axis.ticks.x = element_line(size=0.1, colour="#002366"),
        axis.ticks.y = element_line(size=0.1),
        axis.title.x=element_blank(),

        panel.background = element_rect(
            fill = alpha("#8B7968", 0.2),
            size = 0,
        ),

        axis.text.x = element_blank(),
    ) +
    ylab("UK cases by\nspecimen date")

p <- p1 / p2 / p3 + plot_layout(heights=c(3,1,1))
ggsave("dat/s1.png", width=16, height=9, unit="cm")

