# Functional Annotation Workflow

This directory contains the functional annotation workflow for the final 21-chromosome `Camptotheca acuminata` genome assembly.

## Purpose

The workflow assigns protein-level function to the final GETA protein set using four complementary resources:

- Swiss-Prot / UniProt reference proteins
- Pfam protein-domain HMMs
- eggNOG-mapper for eggNOG/COG, GO and KEGG-oriented annotation
- KofamScan for KEGG Orthology assignment

The input sequence set is:

`/public/home/ryx13/genome_cad/geta/full_run/chr_liftover/Camptotheca_acuminata_T2T.protein.clean.fasta`

All jobs are written as Slurm submission scripts and create their own output directories before running.

## Directory Layout

- `run_swissprot_diamond.slurm`: Swiss-Prot best-hit search with DIAMOND.
- `run_pfam_hmmscan.slurm`: Pfam domain search with HMMER `hmmscan`.
- `run_eggnog_mapper.slurm`: eggNOG-mapper annotation run.
- `run_kofamscan.slurm`: KofamScan KEGG Orthology annotation run.
- `summarize_swissprot_pfam.py`: helper script to merge Swiss-Prot and Pfam summary statistics.
- `swissprot/`: DIAMOND output files.
- `pfam/`: HMMER output files.
- `eggnog/`: eggNOG-mapper output files.
- `kofam/`: KofamScan output files.
- `summary/`: combined summary tables.
- `logs/`: Slurm stdout and stderr logs.

## Software and Databases

The workflow uses the following software and local databases:

- `DIAMOND` for Swiss-Prot search
- `HMMER` for Pfam scanning
- `micromamba` environment `eggnog_mapper` for eggNOG-mapper
- `micromamba` environment `kofamscan` for KofamScan
- `Swiss-Prot/UniProt` DIAMOND database in `databases/functional_annotation/uniprot`
- `Pfam-A.hmm` in `geta/pfam`
- eggNOG database files in `databases/functional_annotation/eggnog`
- KOfam database files in `databases/functional_annotation/kofam`

## Current Status

- Swiss-Prot DIAMOND output has been generated.
- Pfam hmmscan output has been generated.
- eggNOG-mapper output has been generated.
- KofamScan has been prepared and submitted through Slurm.

The current tables-for-submission record keeps the functional annotation summary as a pending placeholder until the final merged annotation summary is completed.

## Output Files

Expected or produced key outputs include:

- `swissprot/Camptotheca_acuminata_T2T_vs_uniprot_sprot.diamond.tsv`
- `pfam/Camptotheca_acuminata_T2T_vs_Pfam.domtblout`
- `pfam/Camptotheca_acuminata_T2T_vs_Pfam.tblout`
- `pfam/Camptotheca_acuminata_T2T_vs_Pfam.hmmscan.out`
- `eggnog/Camptotheca_acuminata_T2T_eggnog.emapper.annotations`
- `eggnog/Camptotheca_acuminata_T2T_eggnog.emapper.hits`
- `eggnog/Camptotheca_acuminata_T2T_eggnog.emapper.seed_orthologs`
- `kofam/Camptotheca_acuminata_T2T_vs_Kofam.detail.tsv`
- `kofam/Camptotheca_acuminata_T2T_vs_Kofam.mapper.tsv`
- `summary/swissprot_pfam_summary.tsv`

## Notes

- Each Slurm script creates its output directory and log directory if needed.
- The functional annotation summary table in `tables_for_submission` is intentionally kept separate from raw tool outputs.
- Do not mix these results with the repeat annotation or gene-structure tables.
