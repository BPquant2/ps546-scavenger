getwd()
setwd()
library(tidyverse)

data <- read_csv("V-Dem-CY-Core-v16.csv")

subset_data <- data %>%
  filter(
    country_name %in% c("Hungary", "Poland", "Serbia", "United States"),
    year >= 2010
  )

plot <- ggplot(subset_data, aes(x = year, y = v2juhcind, color = country_name)) +
  geom_line() +
  labs(
    title = "Judicial Independence (2010–Present)",
    x = "Year",
    y = "Judicial Independence Index",
    color = "Country"
  )

print(plot)

ggsave("judicial_independence_plot.png", plot = plot)