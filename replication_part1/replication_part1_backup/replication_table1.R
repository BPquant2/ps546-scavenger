# "Do Populist Parties Increase Voter Turnout? Evidence From Over 40 Years of Electoral History in 31 European Democracies"
# Arndt Leininger and Maurits J Meijers
# PS 546 Replication (Replicating Table 1)
# Bogdan Petric

library(fixest)
library(modelsummary)

data <- read.csv("master_elec.csv")

data <- subset(data, election_type == "parliament" & election_year >= 1970)

m1 <- feols(turnout ~ populistparty + enp_seats + unemp + openc +
              population_mio + compulsory_voting + pr +
              log_tier1_avemag + log_margin |
              country_id + election_period,
            cluster = ~country_id,
            data = data)

m2 <- feols(turnout ~ l_populistpresence + enp_seats + unemp + openc +
              population_mio + compulsory_voting + pr +
              log_tier1_avemag + log_margin |
              country_id + election_period,
            cluster = ~country_id,
            data = data)

m3 <- feols(turnout ~ populist_new + enp_seats + unemp + openc +
              population_mio + compulsory_voting + pr +
              log_tier1_avemag + log_margin |
              country_id + election_period,
            cluster = ~country_id,
            data = data)

m4 <- feols(turnout ~ l_populistvoteshare + enp_seats + unemp + openc +
              population_mio + compulsory_voting + pr +
              log_tier1_avemag + log_margin |
              country_id + election_period,
            cluster = ~country_id,
            data = data)

m5 <- feols(turnout ~ l_populistseatshare + enp_seats + unemp + openc +
              population_mio + compulsory_voting + pr +
              log_tier1_avemag + log_margin |
              country_id + election_period,
            cluster = ~country_id,
            data = data)

etable(m1, m2, m3, m4, m5)

modelsummary(
  list(
    "Populist Participation" = m1,
    "Populist Representation" = m2,
    "New Populist Party" = m3,
    "Populist Vote Share" = m4,
    "Populist Seat Share" = m5
  ),
  output = "replication_table1.html"
)