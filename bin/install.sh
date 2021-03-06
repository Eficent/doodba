#!/bin/bash
set -ex

reqs=https://raw.githubusercontent.com/$ODOO_SOURCE/$ODOO_VERSION/requirements.txt
apt_deps="python-dev build-essential"
apt-get update

# lxml
apt_deps="$apt_deps libxml2-dev libxslt1-dev"
# Pillow
apt_deps="$apt_deps libjpeg-dev libfreetype6-dev
    liblcms2-dev libopenjpeg-dev libtiff5-dev tk-dev tcl-dev"
# psutil
apt_deps="$apt_deps linux-headers-amd64"
# psycopg2
apt_deps="$apt_deps libpq-dev"
# python-ldap
apt_deps="$apt_deps libldap2-dev libsasl2-dev"

apt-get install -y --no-install-recommends $apt_deps

# Download requirements file to be able to patch it
curl -SLo /tmp/requirements.txt $reqs
reqs=/tmp/requirements.txt

if [ "$ODOO_VERSION" == "8.0" ]; then
    # Packages already installed that conflict with others
    sed -ir 's/pyparsing|six/#\0/' $reqs
    # Extra dependencies for Odoo at runtime
    apt-get install -y --no-install-recommends file
fi

# Build and install Odoo dependencies with pip
pip install --requirement $reqs

# Remove all installed garbage
apt-get -y purge $apt_deps
apt-get -y autoremove
rm -Rf /var/lib/apt/lists/* /tmp/* || true
