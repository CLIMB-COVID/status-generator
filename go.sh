set -euo pipefail

source .env

rm -rf dat
mkdir dat

rm -rf build
mkdir build
mkdir build/graphs
mkdir build/_includes

DATE=`date -d $1 +'%Y-%m-%d'`

echo $DATE > build/report_date

# Load dat
scp $PAG_TSV dat/pags.tsv


# F1
# To use source override commandArgs, e.g. commandArgs <- function(...) c("dat/pags.tsv", "2021-04-07"); source(...)
Rscript f1-total_genomes/fig1.R dat/pags.tsv $DATE
read TOTAL_PAGS TODAY_PAGS < <(head dat/fig1.dat)

cp dat/fig1b.png build/graphs/fig1b.png
cp dat/fig1c.png build/graphs/fig1c.png

python f1-total_genomes/fig1.py $TOTAL_PAGS


# F2
./make_lamps.sh
Rscript f2-lamps/fig2.R dat/lamps.tsv $DATE
cp dat/fig2.png build/graphs/fig2.png

# S1
wget -O dat/case_counts.ukgov_latest.csv 'https://api.coronavirus.data.gov.uk/v2/data?areaType=overview&metric=cumCasesBySpecimenDate&metric=newCasesBySpecimenDate&format=csv'
Rscript s1/fig1.R dat/pags.tsv $DATE s1/annotations.tsv dat/case_counts.ukgov_latest.csv
cp dat/s1.png build/graphs/s1.png


# Build
## Index
sed "s,PLACEHOLDER_DATE,$DATE,g" template > build/index.md

## Sidebar data
cat summary_template | \
    sed "s,PLACEHOLDER_GENOMES_TODAY,$TODAY_PAGS,g" | \
    sed "s,PLACEHOLDER_GENOMES_TOTAL,$TOTAL_PAGS,g" > \
    build/_includes/summary.html

mkdir build/assets
cp -r assets/public/* build/assets

./deploy.sh
