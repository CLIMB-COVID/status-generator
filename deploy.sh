source .env

read REPORT_DATE < <(head build/report_date)
cp -r build/* $DEPLOY_DIR
cd $DEPLOY_DIR
git add .
git commit -am "$REPORT_DATE"
git reset $(git commit-tree HEAD^{tree} -m "$REPORT_DATE")
git push --force
cd -
