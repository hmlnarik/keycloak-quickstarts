#!/bin/bash -e

REPO="https://github.com/keycloak/keycloak.git"
BRANCH=${GITHUB_REF:-${TRAVIS_BRANCH:-latest}}

echo "Building $BRANCH"

if [[ $BRANCH != "latest" ]]; then
  # Temporarily commented
  # git clone --depth 1 $REPO  > /dev/null 2>&1 && cd keycloak
  # Clone Keycloak repo
  git clone $REPO  > /dev/null 2>&1 && cd keycloak

  # Build the repository based on jboss-public-repository
  mvn -s ../maven-settings.xml clean install --no-snapshot-updates -Pdistribution -DskipTestsuite -DskipTests=true -B -V

  # Extract and start the Keycloak server distribution
  mkdir ../keycloak-server && tar xzf distribution/server-dist/target/keycloak-*.tar.gz -C ../keycloak-server --strip-components 1
  cd .. && ./scripts/start-server.sh

else
  ./scripts/start-server.sh
fi
