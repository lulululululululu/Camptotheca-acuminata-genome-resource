# TGS-GapCloser ultralong-only local test

This workflow tests whether ONT reads longer than a defined threshold can close the remaining local scaffold gaps.

Default settings:

- input reads: `/public/home/ryx13/genome_cad/hifiasm_ont/ONT_raw.filtlong.fastq.gz`
- read length threshold: `MIN_LEN=100000`
- local flank: `FLANK=300000`
- tested gaps: `chr7 chr12 chr17`
- TGS-GapCloser mode: `--tgstype ont --minmap_arg ' -x map-ont' --ne`

## Run with reads >=100 kb

```bash
cd /public/home/ryx13/genome_cad/gap_filling_top21
mkdir -p /public/home/ryx13/genome_cad/gap_filling_top21/tgsgap_ultralong_test/logs
sbatch 10_prepare_tgsgap_ultralong_inputs.slurm
```

After the prepare job finishes, check the number of ultralong reads in each local window:

```bash
column -t /public/home/ryx13/genome_cad/gap_filling_top21/tgsgap_ultralong_test/tgsgap_ultralong_inputs.min100000.tsv
```

Then run TGS-GapCloser:

```bash
sbatch 11_run_tgsgap_ultralong_array.slurm
```

Validate:

```bash
bash /public/home/ryx13/genome_cad/gap_filling_top21/12_validate_tgsgap_ultralong_results.sh
column -t /public/home/ryx13/genome_cad/gap_filling_top21/tgsgap_ultralong_test/tgsgap_ultralong_validation.min100000.tsv
```

## Run with reads >=150 kb

```bash
cd /public/home/ryx13/genome_cad/gap_filling_top21
MIN_LEN=150000 sbatch 10_prepare_tgsgap_ultralong_inputs.slurm
MIN_LEN=150000 sbatch 11_run_tgsgap_ultralong_array.slurm
MIN_LEN=150000 bash /public/home/ryx13/genome_cad/gap_filling_top21/12_validate_tgsgap_ultralong_results.sh
column -t /public/home/ryx13/genome_cad/gap_filling_top21/tgsgap_ultralong_test/tgsgap_ultralong_validation.min150000.tsv
```

## Include chr15 if needed

The default test focuses on chr7, chr12 and chr17 because chr15 already has a local Flye bridge candidate.

To include chr15:

```bash
GAP_CHROMS="chr7 chr12 chr15 chr17" sbatch 10_prepare_tgsgap_ultralong_inputs.slurm
GAP_CHROMS="chr7 chr12 chr15 chr17" sbatch --array=1-4 11_run_tgsgap_ultralong_array.slurm
```
