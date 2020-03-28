# Security---Environment Variables

This version of the application is secured **very** simply. 

The application **does not allow update or deletion** of database records. (Controllers immediately redirect to HTTP 401.)

Creation of database records is done through secret URLs. The secret for the URLs is read from the SECRET environment
variable. The application will exit immediately if the SECRET environment variable is not set.

# Populating the Database

The CORD-19 dataset is quite large and not suitable for inclusion in a `git` repository. 

1. Download and decompress the [CORD-19 commercial use subset](https://pages.semanticscholar.org/coronavirus-research).

2. Copy the `comm_use_subset` directory into the local `public` directory. (If you use a different directory, you will
have to edit `db/seed_papers.rb`.)

3. Clone the [2019 Novel Coronavirus COVID-19 (2019-nCoV) Data Repository by Johns Hopkins CSSE](https://github.com/CSSEGISandData/COVID-19)
into a directory next to the one for this repo. (If you use a different directory, you will have to edit `db/seeds_jhu.rb`.)

4. Clone the New York Times [Coronavirus (Covid-19) Data in the United States](https://github.com/nytimes/covid-19-data) repository 
into a directory next to the one for this repo. (If you use a different directory, you will have to edit `db/seeds_nyt.rb`.)

## Development

The following procedure can be used to populate the database from the dataset and repository, if the application is
running locally.

1. Create the local PostgreSQL database with `rake db:create` and `rake db:migrate`.

2. Choose a secret (e.g. 1234) and run the application with `SECRET=1234 rails s`.

3. Using the same secret, run the seed script with `SECRET=1234 RAILS_ENV=development ruby db/seed_papers.rb`. This script will
read through the dataset and POST to the application to create database records.

4. Using the same secret, run the seed script with `SECRET=1234 RAILS_ENV=development ruby db/seeds_jhu.rb`. This script
will read through the repository and POST to the application to create database records

5. Using the same secret, run the seed script with `SECRET=1234 RAILS_ENV=development ruby db/seeds_nyt.rb`. This script
will read through the repository and POST to the application to create database records

## Deployment

It is fastest (and most reliable) to populate a local database and then restore it to the remote database for deployment.
However, the following procedure can be used to populate the database from the dataset, if the application is running
remotely.

1. Ensure the remote PostgreSQL database exists and is migrated with `rake db:migrate`.

2. Choose a secret (e.g. 1234) and run the remote application with `SECRET=1234`.

3. Using the same secret, run the seed script with `SECRET=1234 ruby db/seed_papers.rb`. This script will read through the
dataset and POST to the application to create database records.

4. Using the same secret, run the seed script with `SECRET=1234 ruby db/seeds_jhu.rb`. This script will read through the
repository and POST to the application to create database records

4. Using the same secret, run the seed script with `SECRET=1234 ruby db/seeds_nyt.rb`. This script will read through the
repository and POST to the application to create database records
