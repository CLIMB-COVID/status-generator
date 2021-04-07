source .env

rm -rf dat
mkdir dat

rm -rf build
mkdir build
mkdir build/graphs
mkdir build/_includes

DATE=`date -d $1 +'%Y-%m-%d'`

scp $PAG_TSV dat/pags.tsv

Rscript f1-total_genomes/fig1.R dat/pags.tsv $DATE
read TOTAL_PAGS TODAY_PAGS < <(head dat/fig1.dat)

cp dat/fig1b.png build/graphs/fig1b.png

python f1-total_genomes/fig1.py $TOTAL_PAGS

## Index
sed "s,PLACEHOLDER_DATE,$DATE,g" template > build/index.md

## Sidebar data
cat summary_template | \
    sed "s,PLACEHOLDER_GENOMES_TODAY,$TODAY_PAGS,g" | \
    sed "s,PLACEHOLDER_GENOMES_TOTAL,$TOTAL_PAGS,g" > \
    build/_includes/summary.html

mkdir build/assets
cp -r assets/public/* build/assets
