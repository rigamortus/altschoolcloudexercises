#!/usr/bin/bash
sed -i~ '/^DB_PORT=/s/=.*/="3306"/' .env
sed -i~ '/^DB_DATABASE=/s/=.*/="laravel_realworld"/' .env
sed -i~ '/^DB_USERNAME=/s/=.*/="laravel"/' .env
sed -i~ '/^DB_PASSWORD=/s/=.*/="Phunkeeb100*"/' .env
sed -i~ '/^DB_URL=/s/=.*/="134.209.177.183"/' .env
sed -i~ '/^DB_CONNECTION=/s/=.*/="mysql"/' .env
sed -i~ '/^DB_HOST=/s/=.*/="127.0.0.1"/' .env
