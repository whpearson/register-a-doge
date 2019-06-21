# Register a Doge

Demo application for a gameday.

## Usage

```
rbenv install
bundle install
RACK_ENV=development rackup
# OR
RACK_ENV=production rackup
```

## Postgres

A postgres database is required:

```
# Run locally
docker run --rm -it -d -p 5432:5432 postgres
bundle exec rspec # run the tests
```

## Docker

A docker image is provided: `/tlwr/register-a-doge`
