setup() {
  export DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )/.."
  export TESTDIR=$(mktemp -d -t testredis-XXXXXXXXXX)
  export PROJNAME=testredis
  export DDEV_NON_INTERACTIVE=true
  ddev delete -Oy ${PROJNAME} || true
  cd "${TESTDIR}"
}

teardown() {
  cd ${TESTDIR}
  ddev delete -Oy ${DDEV_SITENAME}
  rm -rf ${TESTDIR}
}

@test "basic installation" {
  ddev config --project-name=${PROJNAME} --project-type=drupal9 --docroot=web --create-docroot
  ddev start -y
  cd ${TESTDIR}
  ddev get ${DIR}
  ddev restart
  ddev redis-cli INFO | grep "^redis_version:6."
  # Check if Redis configuration was setup.
  [ -f web/sites/default/settings.ddev.redis.php ]
  grep -F 'settings.ddev.redis.php' web/sites/default/settings.php
}

# bats test_tags=release
@test "install from release" {
  ddev config --project-name=${PROJNAME} --project-type=drupal9 --docroot=web --create-docroot
  ddev start -y
  cd ${TESTDIR}
  ddev get ddev/ddev-redis
  ddev restart
  ddev redis-cli INFO | grep "^redis_version:6."
  # Check if Redis configuration was setup.
  [ -f web/sites/default/settings.ddev.redis.php ]
  grep -F 'settings.ddev.redis.php' web/sites/default/settings.php
}
