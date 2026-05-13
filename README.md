# Camptotheca acuminata chromosome-level genome resource

This repository contains workflow records, metadata tables, data dictionaries,
plotting scripts and small source-data tables associated with a chromosome-level
genome assembly resource for *Camptotheca acuminata*.

## Repository contents

- `workflow_records/`: command-line records and scripts for ONT read filtering,
  genome assembly, Hi-C scaffolding, telomere/centromere detection, repeat
  annotation, gene annotation, validation and figure generation.
- `metadata/`: software versions, public input dataset metadata, homologous
  protein evidence metadata and workflow-record index tables.
- `source_data/`: small tabular source-data files used for validation summaries
  and manuscript figures.
- `data_inventory.tsv`: file-level inventory for the deposited data package.
- `checksums.md5`: MD5 checksums for files tracked in this repository.
- `docs/data_dictionary.md`: field-level notes for key tables and coordinate
  conventions.

## Large data files

Large files, including raw ONT reads, final genome FASTA files, gene annotation
files, repeat annotation files and Hi-C contact-map files, are not stored
directly in this GitHub repository. These files should be deposited in public
sequence or data repositories. Repository accessions for these large sequence,
assembly and annotation files will be added to the manuscript and data
inventory before formal submission.

## Reproducibility

Each major computational step is documented in `workflow_records/` and indexed in
`metadata/workflow_record_index.tsv`. Scripts preserve the original HPC command
structure and use cluster-specific absolute paths; users should replace these
paths with local file locations before rerunning the workflow.

## Archived release

This repository release has been archived with Zenodo:

- DOI: https://doi.org/10.5281/zenodo.20158760
- GitHub: https://github.com/lulululululululu/Camptotheca-acuminata-genome-resource

Please cite the Zenodo DOI when using these workflow records, metadata files or
small source-data tables.
