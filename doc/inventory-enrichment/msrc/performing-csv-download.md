# MSRC CSV download: how to

[https://msrc.microsoft.com/update-guide](https://msrc.microsoft.com/update-guide)

The data can be manually downloaded by starting with the most recent year (e.g. 2023) and working backwards to the year
2016:

1. download the csv for these options:
   ```
   Start of the month   January   start year
   Today
   ```

2. then download the csv for all years until 2016:
   ```
   Start of the month   January    decrement year by 1
   End of the month     December   decrement year by 1
   ```

This can be a bit tedious, as the file download can take quite some time to generate the file you want to download, but
as this is only required to be done 20XX - 2016 + 1 times (2023: currently 8 times), so it's not too bad.
