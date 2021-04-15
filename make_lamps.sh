source ~/.ocarina
echo -e 'service\tdate' > dat/lamps.tsv

ls $ASKLEPIAN_PUBDIR/ | grep '^20*' | sed 's,^,asklepian\t,' >> dat/lamps.tsv
ls $COG_PUBLISHED_DIR/ | grep '^20*' | sed 's,^,elan\t,' >> dat/lamps.tsv

