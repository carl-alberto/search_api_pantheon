#!/bin/bash

# Bring the code down to Circle so that modules can be added via composer.
git clone $(terminus connection:info $SITE_ENV --field=git_url) drupal8
cd drupal8
git checkout -b $TERMINUS_ENV

# Tell Composer where to find packages.
composer config repositories.drupal composer https://packages.drupal.org/8
composer config repositories.search_api_pantheon vcs git@github.com:pantheon-systems/search_api_pantheon.git
composer require drupal/search_api_pantheon:dev-8.x-1.x#$CIRCLE_SHA1
composer require drupal/search_api_page:1.x-dev

# These two lines are necessary only to force dev installs,
# otherwise the latest releases would be used.
composer require drupal/search_api_solr:8.x-1.x#43156067c6198621012bd60914906e1dbc37f6f6 --prefer-dist
composer require drupal/search_api:8.x-1.x#f9e7a4ed96b89989e7e061341bccc65bad7d63b9 --prefer-dist

# Make sure submodules are not committed.
rm -rf modules/search_api_solr/.git/
rm -rf modules/search_api/.git/
rm -rf modules/search_api_page/.git/
rm -rf modules/search_api_pantheon/.git/
rm -rf vendor/solarium/solarium/.git/

# Make a git commit
git add .
git commit -m 'Result of build step'
git push --set-upstream origin $TERMINUS_ENV
