source /cephfs/covid/software/eagle-owl/scripts/hootstrap.sh
source "$EAGLEOWL_CONF/common.sh"
source "$EAGLEOWL_CONF/status_generator/conf.sh"

set -euo pipefail

read REPORT_DATE < <(head build/report_date)
cp -r build/* $DEPLOY_DIR
cd $DEPLOY_DIR
git add .
git commit --allow-empty -am "$REPORT_DATE"
git reset $(git commit-tree HEAD^{tree} -m "$REPORT_DATE")
git push --force
cd -
