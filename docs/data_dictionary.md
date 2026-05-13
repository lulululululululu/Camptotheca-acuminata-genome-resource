# Data dictionary

## Archive identifiers

This GitHub repository release is archived at Zenodo under DOI
https://doi.org/10.5281/zenodo.20156886. The DOI applies to the workflow
records, metadata files, data dictionaries and small source-data tables in this
repository. Large raw-read, genome assembly and annotation files should be cited
through their own public repository accessions or DOIs once deposited.

## Coordinate conventions

Unless otherwise stated, chromosome coordinates in source-data tables use
1-based closed intervals. BED-format files, if added later, should use 0-based
half-open intervals and should state this explicitly in the file description.

## Metadata tables

- `metadata/software_versions.tsv`: software, database and local path/source
  records for the computational workflow.
- `metadata/public_rnaseq_datasets.tsv`: reused public RNA-seq accessions and
  tissue or developmental-stage labels.
- `metadata/homologous_protein_evidence.tsv`: homologous protein evidence used
  for GETA annotation.
- `metadata/workflow_record_index.tsv`: workflow identifier, step name, inputs,
  software versions, key parameters, outputs and command-record file paths.

## Source-data tables

- `source_data/assembly_validation/`: residual gaps, ONT read mapping coverage
  and LAI validation records.
- `source_data/busco/`: BUSCO short summaries and combined BUSCO table.
- `source_data/figure_source_data/`: chromosome-scale figure source data and R
  plotting script.

## Missing values

`NA` indicates a missing, not applicable or not yet assigned field, depending on
the table context. Repository accessions for large sequence, assembly and
annotation files should be updated after public deposition.
