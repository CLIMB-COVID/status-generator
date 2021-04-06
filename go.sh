source .env

rm -rf dat
mkdir dat

rm -rf build
mkdir build
mkdir build/graphs

scp $PAG_TSV dat/pags.tsv

Rscript f1-total_genomes/fig1.R
while IFS=$'\t' read -r TOTAL_PAGS; do
    python f1-total_genomes/fig1.py $TOTAL_PAGS
done < dat/fig1.dat

DATE=`date +'%Y-%m-%d'`
sed "s,PLACEHOLDER_DATE,$DATE,g" template > build/index.md

mkdir build/assets
cp -r assets/public/* build/assets
