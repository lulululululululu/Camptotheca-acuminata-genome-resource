#!/bin/bash
#SBATCH -J geta_full
#SBATCH -p hebhcnormal03
#SBATCH -N 1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --mem=300G
#SBATCH -o /public/home/ryx13/genome_cad/geta/full_run/logs/geta_full.%j.out
#SBATCH -e /public/home/ryx13/genome_cad/geta/full_run/logs/geta_full.%j.err

set -euo pipefail

WORKDIR=/public/home/ryx13/genome_cad/geta/full_run
mkdir -p ${WORKDIR}/logs
cd ${WORKDIR}

unset PERL5LIB
unset PERL_LOCAL_LIB_ROOT
unset PERL_MB_OPT
unset PERL_MM_OPT
unset PERL5OPT

export PATH=/public/share/ac4w0a7em6/ryx13_software/micromamba/envs/geta_env/bin:$PATH
export PATH=/public/share/ac4w0a7em6/ryx13_software/geta/bin:$PATH
export PATH=/opt/clusconf/libexec/tools:$PATH
export PATH=/public/software/apps/blast/2.10.0/bin:$PATH
export PATH=/public/software/apps/samtools/1.9/gcc-7.3.1/bin:$PATH
export PATH=/public/share/ac4w0a7em6/ryx13_software/hmmer-3.4-install/bin:$PATH
export PATH=/public/share/ac4w0a7em6/ryx13_software/exonerate/bin:$PATH
export PATH=/public/share/ac4w0a7em6/ryx13_software/hisat2-2.1.0-src:$PATH
export PATH=/public/share/ac4w0a7em6/ryx13_software/Augustus/bin:$PATH
export PATH=/public/share/ac4w0a7em6/ryx13_software/Augustus/scripts:$PATH
export PATH=/public/share/ac4w0a7em6/ryx13_software/genometools/bin:$PATH
export PATH=/public/share/ac4w0a7em6/ryx13_software/gth/bin:$PATH
export PATH=/public/share/ac4w0a7em6/ryx13_software:$PATH

export WISECONFIGDIR=/public/share/ac4w0a7em6/ryx13_software/micromamba/envs/geta_env/share/wise2/wisecfg

REQUIRED_TOOLS="ParaFly RepeatMasker RepeatModeler java hisat2 samtools parallel mmseqs hmmsearch diamond augustus gff2gbSmallDNA.pl gt gth exonerate"
echo "[INFO] Dependency path check at $(date)"
for tool in ${REQUIRED_TOOLS}; do
    if command -v "${tool}" >/dev/null 2>&1; then
        echo "[OK] ${tool}: $(command -v "${tool}")"
    else
        echo "[ERROR] ${tool}: not found in PATH" >&2
        exit 2
    fi
done


GENOME=/public/home/ryx13/genome_cad/hifiasm_ont/ont_filt_asm.bp.p_ctg.fa
PROTEIN=/public/home/ryx13/genome_cad/geta/proteins/cleaned_proteins.fasta
PFAM=/public/home/ryx13/genome_cad/geta/pfam/Pfam-A.hmm
OUT_PREFIX=${WORKDIR}/Camptotheca_full
CPU=${SLURM_CPUS_PER_TASK:-32}
MAMBA=/public/share/ac4w0a7em6/ryx13_software/bin/micromamba

PE1=/public/home/ryx13/genome_cad/juicer/rnaseq/SRR173032_1.clean.fq.gz,/public/home/ryx13/genome_cad/juicer/rnaseq/SRR173033_1.clean.fq.gz,/public/home/ryx13/genome_cad/juicer/rnaseq/SRR173034_1.clean.fq.gz,/public/home/ryx13/genome_cad/juicer/rnaseq/SRR173035_1.clean.fq.gz,/public/home/ryx13/genome_cad/juicer/rnaseq/SRR173036_1.clean.fq.gz,/public/home/ryx13/genome_cad/juicer/rnaseq/SRR173044_1.clean.fq.gz,/public/home/ryx13/genome_cad/juicer/rnaseq/SRR173045_1.clean.fq.gz,/public/home/ryx13/genome_cad/juicer/rnaseq/SRR173046_1.clean.fq.gz,/public/home/ryx13/genome_cad/juicer/rnaseq/SRR173047_1.clean.fq.gz,/public/home/ryx13/genome_cad/juicer/rnaseq/SRR173048_1.clean.fq.gz,/public/home/ryx13/genome_cad/juicer/rnaseq/SRR173049_1.clean.fq.gz,/public/home/ryx13/genome_cad/juicer/rnaseq/SRR173050_1.clean.fq.gz,/public/home/ryx13/genome_cad/juicer/rnaseq/SRR173052_1.clean.fq.gz,/public/home/ryx13/genome_cad/juicer/rnaseq/SRR173053_1.clean.fq.gz,/public/home/ryx13/genome_cad/juicer/rnaseq/SRR173054_1.clean.fq.gz
PE2=/public/home/ryx13/genome_cad/juicer/rnaseq/SRR173032_2.clean.fq.gz,/public/home/ryx13/genome_cad/juicer/rnaseq/SRR173033_2.clean.fq.gz,/public/home/ryx13/genome_cad/juicer/rnaseq/SRR173034_2.clean.fq.gz,/public/home/ryx13/genome_cad/juicer/rnaseq/SRR173035_2.clean.fq.gz,/public/home/ryx13/genome_cad/juicer/rnaseq/SRR173036_2.clean.fq.gz,/public/home/ryx13/genome_cad/juicer/rnaseq/SRR173044_2.clean.fq.gz,/public/home/ryx13/genome_cad/juicer/rnaseq/SRR173045_2.clean.fq.gz,/public/home/ryx13/genome_cad/juicer/rnaseq/SRR173046_2.clean.fq.gz,/public/home/ryx13/genome_cad/juicer/rnaseq/SRR173047_2.clean.fq.gz,/public/home/ryx13/genome_cad/juicer/rnaseq/SRR173048_2.clean.fq.gz,/public/home/ryx13/genome_cad/juicer/rnaseq/SRR173049_2.clean.fq.gz,/public/home/ryx13/genome_cad/juicer/rnaseq/SRR173050_2.clean.fq.gz,/public/home/ryx13/genome_cad/juicer/rnaseq/SRR173052_2.clean.fq.gz,/public/home/ryx13/genome_cad/juicer/rnaseq/SRR173053_2.clean.fq.gz,/public/home/ryx13/genome_cad/juicer/rnaseq/SRR173054_2.clean.fq.gz

[[ -s "${GENOME}" ]] || { echo "[ERROR] genome not found: ${GENOME}" >&2; exit 1; }
[[ -s "${PROTEIN}" ]] || { echo "[ERROR] protein not found: ${PROTEIN}" >&2; exit 1; }
[[ -s "${PFAM}" ]] || { echo "[ERROR] Pfam HMM not found: ${PFAM}" >&2; exit 1; }

if [[ ! -s "${PFAM}.h3f" || ! -s "${PFAM}.h3i" || ! -s "${PFAM}.h3m" || ! -s "${PFAM}.h3p" ]]; then
    echo "[INFO] Pfam database is not pressed yet. Running hmmpress ..."
    hmmpress "${PFAM}"
fi

${MAMBA} run -n geta_env /public/share/ac4w0a7em6/ryx13_software/geta/bin/geta.pl \
    --genome ${GENOME} \
    --pe1 ${PE1} \
    --pe2 ${PE2} \
    --protein ${PROTEIN} \
    --HMM_db ${PFAM} \
    --RM_species_Dfam Viridiplantae \
    --RM_species_RepBase Viridiplantae \
    --augustus_species Camptotheca_acuminata \
    --out_prefix ${OUT_PREFIX} \
    --cpu ${CPU}

echo "[INFO] GETA finished at $(date)"

