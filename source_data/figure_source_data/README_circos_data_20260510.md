# Camptotheca acuminata T2T circos data

## Purpose

This directory contains source tables for a genome circos plot of the
Camptotheca acuminata T2T top21 chromosome assembly.

The intended tracks are:

1. Chromosome length
2. GC content in 1 Mb windows
3. Repeat density in 1 Mb windows
4. Gene density in 1 Mb windows
5. Within-genome synteny links from MCScanX

## Inputs

```text
Final assembly FASTA:
/public/home/ryx13/genome_cad/juicer/run_3ddna/review/Ont_filt_asm.bp.p_ctg.top21.chr.seqkit.fasta

Final assembly FAI:
/public/home/ryx13/genome_cad/juicer/run_3ddna/review/Ont_filt_asm.bp.p_ctg.top21.chr.seqkit.fasta.fai

Clean gene annotation:
/public/home/ryx13/genome_cad/geta/full_run/chr_liftover/Camptotheca_acuminata_T2T.geneModels.chr.clean.gff3

Repeat annotation:
/public/home/ryx13/genome_cad/juicer/run_3ddna/review/Ont_filt_asm.bp.p_ctg.top21.chr.seqkit.fasta.mod.out.gff3

Clean protein FASTA:
/public/home/ryx13/genome_cad/geta/full_run/chr_liftover/Camptotheca_acuminata_T2T.protein.clean.fasta
```

## Window tracks

Window size is 1,000,000 bp.

Generated files:

```text
CacuT2T_chr_lengths.tsv
CacuT2T_gc_1Mb.tsv
CacuT2T_repeat_density_1Mb.tsv
CacuT2T_repeat_class_density_1Mb.tsv
CacuT2T_gene_density_1Mb.tsv
CacuT2T_circos_track_qc.txt
```

Definitions:

- GC content ignores non-ACGT bases.
- Gene count is assigned by gene start position, so each gene is counted once.
- Gene bp is assigned by interval overlap, so genes crossing a window boundary
  contribute bp to both windows.
- Repeat bp is assigned by interval overlap.
- Repeat class is parsed from the repeat GFF3 `classification=` attribute.

Current QC:

```text
window_bp   1000000
chromosomes 21
windows     424
gene_count  31752
```

Additional checks:

```text
GC windows: 424, bad GC values: 0
repeat windows: 424, bad repeat windows: 0
gene_count_sum: 31752, bad gene bp windows: 0
```

## Synteny

Within-genome synteny is being generated with MCScanX from the clean protein
FASTA and clean chromosome-coordinate GFF3.

MCScanX input files:

```text
mcscanx/CacuT2T.gff
mcscanx/CacuT2T.faa
```

Counts:

```text
MCScanX genes: 31752
MCScanX proteins: 31752
protein stop codon symbols: 0
```

Submitted SLURM job:

```text
JOBID: 24825450
script: mcscanx/run_mcscanx_self_circos.slurm
```

The first SLURM run produced a valid BLASTP output but MCScanX initially
reported `0 matches imported` because the MCScanX GFF column order had been
written as `gene chr start end`. MCScanX expects `chr gene start end`.

The script was corrected and MCScanX was rerun using the existing BLASTP output.

Corrected MCScanX summary:

```text
matches imported      317787
alignments generated  1439
collinear genes       17947
all genes             31752
collinear percentage  56.52
```

Final link file:

```text
CacuT2T_synteny_links.tsv
```

The link conversion keeps blocks with at least 5 gene pairs and removes
same-chromosome links whose block starts are closer than 1 Mb.

Final link QC:

```text
links       20
bad_coords  0
intra_chr   2
inter_chr   18
```

A looser top-100 link set was later generated for the existing `circos.R`
input file. This version uses all MCScanX alignments with at least 5 gene pairs,
does not remove same-chromosome links by the 1 Mb distance cutoff, sorts by
`gene_pairs`, and keeps the top 100 blocks.

```text
loose_all_links      1439
loose_top100_links   100
top100_bad_coords    0
top100_intra_chr     6
top100_inter_chr     94
```

The `circos.R` default file now points to the looser top-100 set:

```text
synteny_blocks.links.6col.txt
```

Strict 20-link backups:

```text
CacuT2T_synteny_links.strict20.tsv
synteny_blocks.links.6col.strict20.txt
```

## Reproducibility

Window track generation:

```bash
/public/share/ac4w0a7em6/ryx13_software/micromamba/envs/geta_env/bin/python \
  /public/home/ryx13/genome_cad/scripts/prepare_circos_tracks.py \
  --fasta /public/home/ryx13/genome_cad/juicer/run_3ddna/review/Ont_filt_asm.bp.p_ctg.top21.chr.seqkit.fasta \
  --fai /public/home/ryx13/genome_cad/juicer/run_3ddna/review/Ont_filt_asm.bp.p_ctg.top21.chr.seqkit.fasta.fai \
  --genes-gff3 /public/home/ryx13/genome_cad/geta/full_run/chr_liftover/Camptotheca_acuminata_T2T.geneModels.chr.clean.gff3 \
  --repeats-gff3 /public/home/ryx13/genome_cad/juicer/run_3ddna/review/Ont_filt_asm.bp.p_ctg.top21.chr.seqkit.fasta.mod.out.gff3 \
  --outdir /public/home/ryx13/genome_cad/circos_data \
  --window 1000000
```

MCScanX input generation:

```bash
/public/share/ac4w0a7em6/ryx13_software/micromamba/envs/geta_env/bin/python \
  /public/home/ryx13/genome_cad/scripts/prepare_mcscanx_circos_inputs.py prepare \
  --gff3 /public/home/ryx13/genome_cad/geta/full_run/chr_liftover/Camptotheca_acuminata_T2T.geneModels.chr.clean.gff3 \
  --protein /public/home/ryx13/genome_cad/geta/full_run/chr_liftover/Camptotheca_acuminata_T2T.protein.clean.fasta \
  --out-prefix /public/home/ryx13/genome_cad/circos_data/mcscanx/CacuT2T
```

## Legacy R circos input files

The existing `circos.R` script reads five no-header input files from the working
directory:

```text
circos_chr_size.fixed.txt
synteny_blocks.links.6col.txt
gc_90kb.fixed.txt
gene_density_90kb.fixed.txt
repeat_percent_90kb.fixed.txt
```

These files were regenerated for the current top21 chromosome assembly using
90 kb windows. Previous versions were backed up to:

```text
legacy_input_backup_20260510/
```

Format:

```text
circos_chr_size.fixed.txt       chr start end
synteny_blocks.links.6col.txt   chr1 start1 end1 chr2 start2 end2
gc_90kb.fixed.txt               chr start end GC_fraction
gene_density_90kb.fixed.txt     chr start end gene_count
repeat_percent_90kb.fixed.txt   chr start end repeat_fraction
```

`GC_fraction` and `repeat_fraction` are in 0-1 scale, matching the original
R script. Repeat intervals are merged before calculating window coverage, so
overlapping repeat annotations cannot produce values greater than 1.

Current QC:

```text
window_bp   90000
chromosomes 21
windows     4616
gene_count  31752
links       20
bad_coords  0
```

Regeneration command:

```bash
/public/share/ac4w0a7em6/ryx13_software/micromamba/envs/geta_env/bin/python \
  /public/home/ryx13/genome_cad/scripts/prepare_circos_r_inputs.py \
  --fasta /public/home/ryx13/genome_cad/juicer/run_3ddna/review/Ont_filt_asm.bp.p_ctg.top21.chr.seqkit.fasta \
  --fai /public/home/ryx13/genome_cad/juicer/run_3ddna/review/Ont_filt_asm.bp.p_ctg.top21.chr.seqkit.fasta.fai \
  --genes-gff3 /public/home/ryx13/genome_cad/geta/full_run/chr_liftover/Camptotheca_acuminata_T2T.geneModels.chr.clean.gff3 \
  --repeats-gff3 /public/home/ryx13/genome_cad/juicer/run_3ddna/review/Ont_filt_asm.bp.p_ctg.top21.chr.seqkit.fasta.mod.out.gff3 \
  --synteny-links /public/home/ryx13/genome_cad/circos_data/CacuT2T_synteny_links.tsv \
  --outdir /public/home/ryx13/genome_cad/circos_data \
  --window 90000
```
