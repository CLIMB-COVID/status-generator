library(tidyverse)
library(hrbrthemes)
library(ggrepel)
library(patchwork)

args = commandArgs(trailingOnly=TRUE)

df <- read_tsv(args[1])
df <- df[df$published_date <= args[2],]

dfc <- df %>% 
    complete(published_date=seq.Date(min(published_date), max(published_date), by="day")) %>% # add missing days so we can annotate them
    group_by(published_date) %>%
    summarise(pag_count = n())

annotations <- read_delim(args[3], delim='\t', escape_backslash=TRUE, escape_double=FALSE)
dfc <- left_join(dfc, annotations)

dfc$pag_count_cumsum <- cumsum(dfc$pag_count)
filtered <- dfc %>% filter(label != "")

p1 <- ggplot(dfc, aes(x=published_date, y=pag_count_cumsum)) +
    geom_area(
    ) +
    scale_x_date(expand=c(0,0), date_labels = "%b\n%Y", date_breaks = "1 month", limit=c(as.Date("2020-03-01"),max(df$published_date))) +
    scale_y_continuous(
        expand=c(0.0,0),
        breaks=seq(0,sum(dfc$pag_count),50000),
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

        plot.margin=margin(b=0, unit="cm"),
        axis.title.x = element_blank(),
    ) +
    geom_text_repel(
        aes(label=label),
        angle=90,
        vjust="top",
        hjust="left",
        size=1.9,
        max.overlaps=Inf,
        data=filtered,
        direction="x",
        force_pull=0.25,
        force=0.5,
        segment.size=0.25,
        lineheight=1,
    ) +
    xlab("Date") +
    ylab("Cumulative genomes processed by\nElan on CLIMB-COVID")


gov_df <- read_csv(args[4])
head(gov_df)
p2 <- ggplot(gov_df, aes(x=date, y=newCasesBySpecimenDate)) +
    geom_bar(
        stat='identity',
        width=1,
    ) +
    scale_x_date(expand=c(0,0), date_labels = "%b\n%Y", date_breaks = "1 month", limit=c(as.Date("2020-03-01"),max(df$published_date))) +
    scale_y_continuous(
        expand=c(0,0),
        limit=c(0, max(gov_df$newCasesBySpecimenDate)+5000),
        labels=scales::comma,
    ) +
    theme(
        plot.margin=margin(t=0, unit="cm"),
        axis.title=element_text(size=8, colour="#8B7968"),
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

p <- p1 / p2 + plot_layout(heights=c(3,1))
ggsave("dat/s1.png", width=16, height=9, unit="cm")

