# Melbourne Datathon 2016 Kaggle
This is the home of the predictive modelling component of the 2016 Melbourne Datathon.

The objective is to predict if a job is in the 'Hotel and Tourism' category.

In the 'jobs' table there is a column 'HAT' which stands for 'Hotel and Tourism'. The values in this column are 1 or 0 representing 'Yes' and 'No' meaning it is or is not in the Hotel and Tourism category. This binary flag is a look up from the column 'Subclasses'.

Some of the rows have a value of -1 for HAT. These are the rows you need to predict.

The prediction can be a  1/0 or a continuous number representing a probability of a job being in the HAT category.

Example code in R and SQL to generate the Barista benchmark will be on the data provided, and Python code will also be made available.
