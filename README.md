# metagenomics-project

Reproducible Snakemake workflow for a metagenomics course project based on ENA project `PRJEB39685`, using pooled fecal shotgun metagenomes from European turkey and veal calf herds. The workflow is designed to be runnable locally for development and small-scale testing, and on HPC for full analysis, following the course progression from trimming/QC through taxonomy, KMA-based abundance analysis, assembly, mapping, binning, MAG quality assessment, dereplication, and taxonomic classification.

## Project focus

Current project question:

**How does the gut microbiome differ between French and German turkey samples?**

The repository is structured so the same workflow logic can be developed locally and later executed on Computerome or another HPC system with minimal changes. The course workflow includes trimming and QC, Kraken2/Bracken, KMA-based analyses, assembly with SPAdes/metaSPAdes, read mapping, MetaBAT2 binning, CheckM2, dRep, and GTDB-Tk classification.

## Repository structure

```text
metagenomics-project/
├── README.md
├── environment.yml
├── config/
│   ├── config.yaml
│   └── samples.tsv
├── workflow/
│   ├── Snakefile
│   └── rules/
│       ├── qc.smk
│       ├── taxonomy.smk
│       ├── amr_kma.smk
│       ├── assembly.smk
│       ├── mapping.smk
│       ├── binning.smk
│       ├── bin_quality.smk
│       ├── dereplication.smk
│       └── gtdbtk.smk
├── pbs/
│   ├── config.sh
│   └── submit_all.sh
├── data/
│   ├── raw/
│   └── metadata/
├── results/
├── scr/
├── poster/
└── logs/
