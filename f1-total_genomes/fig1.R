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
    ) +
    xlab("Date") +
    ylab("Cumulative genomes processed")

ggsave("dat/fig1.png", width=16, height=7, unit="cm")

# Output basic metadata
total_pags <- nrow(df)
today_pags <- nrow(df[df$published_date == args[2],])

dft <- data.frame(c(total_pags), c(today_pags))
write_tsv(dft, 'dat/fig1.dat', col_names=F)
