# Workflow records for the Camptotheca acuminata T2T genome Data Descriptor

This directory contains command-line records and SLURM scripts used to generate
the genome assembly, annotation, validation tables and manuscript figures for the
Scientific Data submission. The scripts are intended as reproducibility records:
cluster-specific absolute paths should be replaced by local paths before reuse.

## Directory map

- `primary_workflow/01_ont_qc_filtering.sh`: ONT read QC and Filtlong filtering.
- `primary_workflow/02_hifiasm_assembly.sh`: ONT de novo assembly with hifiasm.
- `primary_workflow/03_hic_juicer_3ddna.sh`: Hi-C scaffolding with Juicer and 3D-DNA.
- `primary_workflow/04_landmark_detection.sh`: Hi-C heatmap plotting, CentIER and TIDK commands.
- `geta_full_annotation.slurm`: GETA gene annotation workflow.
- `run_pfam_hmmscan.slurm`: Pfam domain annotation by HMMER hmmscan.
- `run_swissprot_diamond.slurm`: Swiss-Prot best-hit annotation by DIAMOND.
- `run_eggnog_mapper.slurm`: eggNOG-mapper functional annotation.
- `run_kofamscan.slurm`: KofamScan KEGG orthology annotation.
- `validation/01_quast_busco_lai.sh`: assembly validation command records.
- `validation/02_ont_mapping_coverage.sh`: ONT read remapping and coverage command records.
- `validation/03_summary_tables_and_figures.md`: source-data and figure-generation notes.

## Workflow overview

1. Raw ONT reads were assessed with NanoStat and NanoPlot.
2. Reads were filtered with Filtlong v0.3.1 using `--min_length 1000` and
   `--keep_percent 90`.
3. Filtered ONT reads were assembled with hifiasm v0.25.0-r726 in ONT mode.
4. Public Hi-C reads from SRR12042291 were used for Juicer/3D-DNA scaffolding.
5. The 3D-DNA output was manually reviewed in Juicebox and post-processed with
   `run-asm-pipeline-post-review.sh`.
6. The top 21 chromosome-scale pseudomolecules were retained as the final
   deposited coordinate system.
7. Assembly landmarks and validation metrics were generated with TIDK, CentIER,
   QUAST, BUSCO, LTR_retriever/LAI and ONT read remapping.
8. Gene annotation was performed with GETA using reused public RNA-seq and
   homologous protein evidence.
9. Repeat annotation was performed with EDTA on the final 21-chromosome FASTA.
10. Functional annotation used Swiss-Prot DIAMOND, Pfam hmmscan, eggNOG-mapper
    and KofamScan.

## External data

- Newly generated ONT reads: to be deposited under final BioProject, BioSample
  and read-run accessions.
- Reused Hi-C reads: NCBI SRA SRR12042291 / SRX8571379 / BioProject PRJNA639006.
- Reused RNA-seq reads: 15 runs from BioProject PRJNA80029; see
  `supplementary_tables/Supplementary_Table_13_reused_RNAseq_datasets.tsv`.
- Homologous protein evidence: see
  `supplementary_tables/Supplementary_Table_14_reused_homologous_protein_evidence.tsv`.

## Software versions

Software versions are listed in
`supplementary_tables/Supplementary_Table_12_software_versions.tsv`. Commands in
this directory use the same versions recorded in that table unless otherwise
noted in the corresponding script.

## Notes for reuse

The original analyses were run on an HPC cluster using SLURM. Commands that
start large jobs should be submitted to compute nodes rather than run on a login
node. Some workflow records point to symlinked files in the submission package;
the symlink targets preserve the original cluster paths used during analysis.
