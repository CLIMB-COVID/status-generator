source .env

read REPORT_DATE < <(head build/report_date)
cp -r build/* $DEPLOY_DIR
git add .
git commit -am "$DATE"
git reset $(git commit-tree HEAD^{tree} -m "$DATE")
git push --force
