#!/usr/bin/env bash
set -euo pipefail

# Assembly validation command records for the final 21-chromosome genome.
# These commands are provided for reproducibility and should be submitted to
# compute nodes when rerun on large inputs.

FASTA=/public/home/ryx13/genome_cad/juicer/run_3ddna/review/Ont_filt_asm.bp.p_ctg.top21.chr.seqkit.fasta
PROTEIN=/public/home/ryx13/genome_cad/geta/full_run/chr_liftover/Camptotheca_acuminata_T2T.protein.clean.fasta
OUTROOT=/public/home/ryx13/genome_cad
THREADS=32

# QUAST structural validation.
/public/share/ac4w0a7em6/ryx13_software/micromamba/envs/quast/bin/quast \
  "${FASTA}" \
  -o "${OUTROOT}/quast_final_21chr" \
  -t "${THREADS}" \
  --large

# BUSCO genome-mode validation.
busco \
  -i "${FASTA}" \
  -o final_top21_chr_eudicots \
  -m genome \
  -l eudicots_odb10 \
  -c "${THREADS}" \
  --out_path "${OUTROOT}/busco"

busco \
  -i "${FASTA}" \
  -o final_top21_chr_embryophyta \
  -m genome \
  -l embryophyta_odb10 \
  -c "${THREADS}" \
  --out_path "${OUTROOT}/busco"

# BUSCO protein-mode validation of the final clean protein set.
busco \
  -i "${PROTEIN}" \
  -o clean_protein_eudicots \
  -m proteins \
  -l eudicots_odb10 \
  -c "${THREADS}" \
  --out_path "${OUTROOT}/busco"

busco \
  -i "${PROTEIN}" \
  -o clean_protein_embryophyta \
  -m proteins \
  -l embryophyta_odb10 \
  -c "${THREADS}" \
  --out_path "${OUTROOT}/busco"

# LTR Assembly Index. The exact local EDTA/LTR_retriever environment used in the
# final run is recorded in Supplementary Table 12. The raw output is included as
# source_data/assembly_validation/LTR_retriever_LAI_raw_output.tsv.
gt suffixerator \
  -db "${FASTA}" \
  -indexname "${FASTA}" \
  -tis -suf -lcp -des -ssp -sds -dna

gt ltrharvest \
  -index "${FASTA}" \
  -out "${FASTA}.harvest.scn"

LTR_retriever \
  -genome "${FASTA}" \
  -inharvest "${FASTA}.harvest.scn" \
  -threads "${THREADS}"
