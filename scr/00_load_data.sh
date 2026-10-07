#!/usr/bin/env bash
set -euo pipefail

mkdir -p data/raw data/metadata data/resources config

ACCESSIONS_FILE="data/metadata/accessions.txt"
METADATA_URL="https://www.ebi.ac.uk/ena/portal/api/filereport?accession=PRJEB39685&result=read_run&fields=run_accession,sample_alias,fastq_ftp&format=tsv&download=true&limit=0"
METADATA_FILE="data/metadata/metadata.tsv"
SAMPLES_FILE="config/samples.tsv"

# check input file exists
if [[ ! -f "$ACCESSIONS_FILE" ]]; then
  echo "Missing $ACCESSIONS_FILE"
  exit 1
fi


# download metadata
wget -O "$METADATA_FILE" "$METADATA_URL"
echo "metadata saved in data/metadata/"


# build config/samples.tsv from metadata
{
  printf "sample_id\trun_accession\thost\tcountry\tgroup_id\n"

  awk -F '\t' '
    NR == FNR {
      wanted[$1] = 1
      next
    }

    FNR == 1 {
      next
    }

    ($1 in wanted) {
      run = $1
      alias = $2

      split(alias, a, "_")
      country = a[1]
      host = a[2]

      sample_id = tolower(country "_" host "_" run)
      group_id = country

      print sample_id, run, host, country, group_id
    }
  ' "$ACCESSIONS_FILE" "$METADATA_FILE"
} > "$SAMPLES_FILE"


echo "Wrote $SAMPLES_FILE in config/"
column -t -s $'\t' "$SAMPLES_FILE"


# download paired FASTQs for each accession
while read -r acc; do
  [[ -z "$acc" ]] && continue
  [[ "$acc" =~ ^# ]] && continue

  prefix="${acc:0:6}"
  suffix="${acc: -1}"
  base_url="ftp://ftp.sra.ebi.ac.uk/vol1/fastq/${prefix}/00${suffix}/${acc}"

  wget -nc -P data/raw "${base_url}/${acc}_1.fastq.gz"
  wget -nc -P data/raw "${base_url}/${acc}_2.fastq.gz"
done < "$ACCESSIONS_FILE"
echo "fastq saved in data/raw/"


# retrieve adapters
curl -L \
  https://raw.githubusercontent.com/bbushnell/BBTools/master/resources/adapters.fa \
  -o data/resources/adapters.fa
echo "adapters saved in data/resources"

