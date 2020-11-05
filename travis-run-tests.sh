#!/bin/bash -e

case "$1" in
    group1)
        for i in `mvn -q --also-make exec:exec -Dexec.executable="pwd" | awk -F '/' '{if (NR > 1) print $NF}'`;
        do
          # FIXME Workaround to skip Angular.js app on Travis CI while we figure out the best way to fix the issues with Selenium
          if [ "$i" = "app-angular2" -o "$i" = "app-authz-uma-photoz" -o "$i" = "app-authz-photoz" -o "$i" = "photoz-html5-client" -o "$i" = "photoz-js-policies" -o "$i" = "photoz-restful-api" -o "$i" = "photoz-testsuite" -o "$i" = "app-profile-jee-html5" ]; then
            continue
          fi
          mvn -B -s maven-settings.xml clean install -Pwildfly-managed -Denforcer.skip=true -f $i
        done
        ;;

    group2)
        mvn -B -s maven-settings.xml test -Pwildfly-managed -f action-token-authenticator/pom.xml </dev/null
        mvn -B -s maven-settings.xml test -Pwildfly-managed -f action-token-required-action/pom.xml </dev/null
        ;;

    group3)
        mvn -f fuse63/pom.xml -B -s maven-settings.xml clean install
        mvn -f fuse70/pom.xml -B -s maven-settings.xml clean install
        ;;

    group4)
        cd app-authz-springboot && mvn -B -s ../maven-settings.xml clean test -Pspring-boot -q
        cd ../service-springboot-rest && mvn -B -s ../maven-settings.xml clean test -Pspring-boot -q
        mvn spring-boot:run >/dev/null&
        cd ../app-springboot
        mvn -B -s ../maven-settings.xml clean test -Pspring-boot
        ;;

    group5)
        mvn -B -s maven-settings.xml test -Pkeycloak-remote -f user-storage-jpa
        mvn -B -s maven-settings.xml test -Pkeycloak-remote -f user-storage-simple
        ;;

    group6)
        ./productize.sh
        exit 0
        ;;

    group7)
        mvn -B -s maven-settings.xml test -Pkeycloak-remote -f event-listener-sysout
        mvn -B -s maven-settings.xml test -Pkeycloak-remote -f event-store-mem
        ;;
esac
