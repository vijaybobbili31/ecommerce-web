# Use an official PHP runtime as a parent image
FROM php:8.2-cli

# Set the working directory to /var/www/html
WORKDIR /var/www/html

# Install any needed packages specified in requirements.txt
# For example, if you have a requirements.txt file with necessary dependencies, uncomment the next line
# RUN apt-get update && apt-get install -y --no-install-recommends $(cat requirements.txt)
RUN apt-get update && apt-get install -y --no-install-recommends \
    libcurl4-openssl-dev \
    libssl-dev \
    zlib1g-dev \
    libicu-dev
 
RUN apt-get -y update && \
    apt-get install -y libicu-dev && \ 
    docker-php-ext-configure intl && \
    docker-php-ext-install intl


# Install PHP extensions
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev

# Install PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install pdo pdo_mysql gd

RUN docker-php-ext-install pdo pdo_mysql gd
RUN docker-php-ext-install mysqli
RUN docker-php-ext-install curl


# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer


# Install Apache and enable the rewrite module
RUN apt-get update && \
    apt-get install -y apache2 && \
    a2enmod rewrite

# Enable Apache modules
RUN a2enmod rewrite
  

# Expose port 80 for web traffic
EXPOSE 80

# Install MySQL client
RUN apt-get update && apt-get install -y default-mysql-client

# Install Laravel
COPY . /var/www/html

RUN composer update self-update 2>&1 | tee /tmp/composer_self_update.log


# Define environment variables for Apache
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
ENV APACHE_LOG_DIR /var/log/apache2

# Configure Apache to use the new document root and log directory
RUN sed -i -e "s|DocumentRoot /var/www/html|DocumentRoot \${APACHE_DOCUMENT_ROOT}|g" /etc/apache2/sites-available/000-default.conf \
    && sed -i -e "s|<Directory /var/www/html/>|<Directory \${APACHE_DOCUMENT_ROOT}/>|g" /etc/apache2/apache2.conf

# By default, start Apache in the foreground
#CMD ["apache2-foreground"]
ENTRYPOINT ["apache2ctl", "-D", "FOREGROUND"]
