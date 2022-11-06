#!/usr/bin/bash
sudo -i -u postgres psql -c "CREATE DATABASE laravel_realworld"
sudo -i -u postgres psql -c "CREATE USER root WITH PASSWORD 'Phunkeeb100*'";
sudo -i -u postgres psql -c "GRANT postgres TO root";

