IFS=$'\n'       # make newlines the only separator, it is recomended to unset after

cut -f1,3,5 Hs_All_sample_2019.tsv > samples.tsv

rm -f tmp_mdata_spl.tsv tmp_mdata_pmid.tsv
rm -f mdata_spl.tsv mdata_pmid.tsv

# extract MDATA - sample id pairs
for line in `cat  PeptideAtlas.mapinfo` ; do
  samplename=$(echo $line|cut -d "=" -f 1)
  MDATA=$(echo $line|cut -d "=" -f 2)
  echo "building mdata - sample pairs for $MDATA - $samplename"
  pattern="$(printf '\t%s\t' $samplename)"
  matches=$(grep "$pattern" samples.tsv | cut -f 1)
  #echo "matches: $matches"
  for match in $matches; do
  	echo -e "$MDATA\t$match" >> tmp_mdata_spl.tsv
  done
done

sort -u tmp_mdata_spl.tsv > mdata_spl.tsv
rm -f tmp_mdata_spl.tsv 
echo "mdata - sample pairs completed"


# extract MDATA - pubmed pairs
for line in `cat  PeptideAtlas.mapinfo` ; do
  samplename=$(echo $line|cut -d "=" -f 1)
  MDATA=$(echo $line|cut -d "=" -f 2)
  echo "building mdata - pmid  pairs for $MDATA - $samplename"
  pattern="$(printf '\t%s\t' $samplename)"
  matches=$(grep "$pattern" samples.tsv | cut -f 3)
  #echo "matches: $matches"
  for match in $matches; do
        echo -e "$MDATA\t$match" >> tmp_mdata_pmid.tsv
  done
done

sort -u tmp_mdata_pmid.tsv > mdata_pmid.tsv
rm -f tmp_mdata_pmid.tsv

echo "mdata - sample pairs completed"
echo "DONE !"


