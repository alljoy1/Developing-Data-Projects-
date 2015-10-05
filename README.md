# Developing-Data-Projects-
Repo for the project Developing Data Projects

This is a simple application to predict the phases of the moon for a selected year and month.  When the app opens, it defaults to the current year and month.
From the app page, enter the year into the text input control box – either by typing or selecting from the drop down control.  This control accepts any year between 1950 and 2099.  Once the year is entered, the day of the full moon at its peak (highest percentage of surface illuminated) for all months displays below the "year selected" bar.
The slider bar allows you to select the month to view the days of additional moon phases throughout the selected month.
The displayed chart and phases for the selected month change as the slider is moved to a different month.  The lunar phase is calculated at 12 noon UT.
For the purposes of this application, a blue moon is the second full moon in the month.  As the start and end dates for a full moon can span across months, a blue moon in one month may also count as the first full moon in the next month.

The r code uses the cran package lunar written and published by Emmanuel Lazaridis
It also uses the lubridate package for managing dates.

