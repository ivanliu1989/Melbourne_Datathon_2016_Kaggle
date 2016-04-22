# Melbourne Datathon 2016 Kaggle
https://inclass.kaggle.com/c/melbourne-datathon-2016

This is the home of the predictive modelling component of the 2016 Melbourne Datathon.

The objective is to predict if a job is in the 'Hotel and Tourism' category.

In the 'jobs' table there is a column 'HAT' which stands for 'Hotel and Tourism'. The values in this column are 1 or 0 representing 'Yes' and 'No' meaning it is or is not in the Hotel and Tourism category. This binary flag is a look up from the column 'Subclasses'.

Some of the rows have a value of -1 for HAT. These are the rows you need to predict.

The prediction can be a  1/0 or a continuous number representing a probability of a job being in the HAT category.

Example code in R and SQL to generate the Barista benchmark will be on the data provided, and Python code will also be made available.

#### Initial Ideas for Data Exploration
Job_Jobs
1.	Abstract length
2.	Key words in abstract - Text mining
3.	Raw_job_type – cleaning and binary
4.	Job Title – cleaning and text mining
5.	Salary range

Job_Clicks
1.	Created_at
a.	Date
b.	Time
c.	Time to job created
d.	Nth job clicks for User

Job_Search
1.	Query – cleaning and text mining
2.	Created_at – as Job_Clicks

Job_Impression
1.	Created_at

Other
1.	# of applicants
2.	Nth of applicants
3.	Location same?
4.	# of applications
