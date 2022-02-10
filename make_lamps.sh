source /cephfs/covid/software/eagle-owl/scripts/hootstrap.sh
source "$EAGLEOWL_CONF/common.sh"
source "$EAGLEOWL_CONF/asklepian/conf.sh"

echo -e 'service\tdate' > dat/lamps.tsv

ls $ASKLEPIAN_PUBDIR/ | grep '^20*' | sed 's,^,asklepian\t,' >> dat/lamps.tsv
ls $ARTIFACTS_ROOT/elan | grep '^20*' | sed 's,^,elan\t,' >> dat/lamps.tsv

