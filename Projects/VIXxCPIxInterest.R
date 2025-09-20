# Install required packages if not already installed
if (!require(quantmod)) install.packages("quantmod")
if (!require(ggplot2)) install.packages("ggplot2")
if (!require(dplyr)) install.packages("dplyr")
if (!require(lubridate)) install.packages("lubridate")

library(quantmod)
library(ggplot2)
library(dplyr)
library(lubridate)

# Define the time period for analysis
start_date <- as.Date("2019-01-01")
end_date   <- as.Date("2020-12-31")

# Download monthly CPI data (Consumer Price Index for All Urban Consumers: CPIAUCSL) from FRED
getSymbols("CPIAUCSL", src = "FRED", from = start_date, to = end_date)
# Download daily VIX data (CBOE Volatility Index: VIXCLS) from FRED
getSymbols("VIXCLS", src = "FRED", from = start_date, to = end_date)

# Convert CPI data to a data frame
cpi_df <- data.frame(Date = index(CPIAUCSL), CPI = as.numeric(CPIAUCSL))
# CPI data is monthly, so Date values should be end-of-month dates.

# Convert VIX daily data to monthly data (using monthly averages)
# 'to.monthly' converts the daily data to OHLC; we then extract the closing prices.
vix_monthly <- to.monthly(VIXCLS, indexAt = "lastof", OHLC = FALSE)
vix_df <- data.frame(Date = index(vix_monthly), VIX = as.numeric(vix_monthly))

# Merge the two data frames on Date (assuming both are end-of-month)
data_merged <- merge(cpi_df, vix_df, by = "Date")

# Quick check on the merged data
head(data_merged)

# Compute the correlation between CPI and VIX over the period
correlation <- cor(data_merged$CPI, data_merged$VIX, use = "complete.obs")
cat("Correlation between CPI and VIX:", round(correlation, 2), "\n")

# Plot the time series (scaling the series for visualization purposes)
p1 <- ggplot(data_merged, aes(x = Date)) +
  geom_line(aes(y = scale(CPI), color = "CPI (scaled)"), size = 1) +
  geom_line(aes(y = scale(VIX), color = "VIX (scaled)"), size = 1) +
  scale_color_manual(values = c("CPI (scaled)" = "blue", "VIX (scaled)" = "red")) +
  labs(title = "Monthly CPI & VIX (2019-2020)",
       y = "Scaled Values",
       color = "Series") +
  theme_minimal()
print(p1)

# Create a scatter plot with a linear regression fit
p2 <- ggplot(data_merged, aes(x = CPI, y = VIX)) +
  geom_point() +
  geom_smooth(method = "lm", se = TRUE, color = "blue") +
  labs(title = paste("CPI vs VIX (Correlation:", round(correlation, 2), ")"),
       x = "CPI",
       y = "VIX") +
  theme_minimal()
print(p2)

# Fit a linear regression model to test the relationship
lm_fit <- lm(VIX ~ CPI, data = data_merged)
summary(lm_fit)
