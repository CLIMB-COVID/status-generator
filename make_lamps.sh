source ~/.bootstrap.sh
source $EAGLEOWL_CONF/paths.env
source $EAGLEOWL_CONF/asklepian.env

echo -e 'service\tdate' > dat/lamps.tsv

ls $ASKLEPIAN_PUBDIR/ | grep '^20*' | sed 's,^,asklepian\t,' >> dat/lamps.tsv
ls $ARTIFACTS_ROOT/elan | grep '^20*' | sed 's,^,elan\t,' >> dat/lamps.tsv

