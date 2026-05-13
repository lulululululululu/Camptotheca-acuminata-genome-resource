# MUMmer-assisted local gap filling plan

This workflow searches whether an existing assembly contig bridges the four `hic_gap_40`
gaps in the top21 chromosome FASTA.

## Inputs

- Reference: `/public/home/ryx13/genome_cad/juicer/run_3ddna/review/Ont_filt_asm.bp.p_ctg.top21.chr.seqkit.fasta`
- First query: `/public/home/ryx13/genome_cad/hifiasm_ont/ont_filt_asm.bp.p_ctg.fa`
- Gap table: `/public/home/ryx13/genome_cad/gap_filling_top21/gaps.tsv`

## Run

Install or expose `nucmer`, `delta-filter`, `show-coords`, and `seqkit` first.

```bash
sbatch /public/home/ryx13/genome_cad/gap_filling_top21/01_run_mummer_hifiasm_vs_top21.slurm
```

After MUMmer finishes:

```bash
bash /public/home/ryx13/genome_cad/gap_filling_top21/02_find_mummer_gap_bridge_candidates.sh
```

Review:

```bash
less -S /public/home/ryx13/genome_cad/gap_filling_top21/mummer_gap_candidates/gap_bridge_candidates.tsv
```

Do not patch the FASTA until a candidate query contig cleanly spans both gap flanks with
consistent orientation and non-repetitive unique alignment.
