#!/usr/bin/env bash
#SBATCH -J ont_map_stats
#SBATCH -p hebhcnormal03
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -c 32
#SBATCH --mem=80G
#SBATCH --chdir=/public/home/ryx13/genome_cad
#SBATCH -o /public/home/ryx13/genome_cad/logs/ont_map_stats.%j.out
#SBATCH -e /public/home/ryx13/genome_cad/logs/ont_map_stats.%j.err

set -euo pipefail

# Slurm opens stdout/stderr before executing this script, so the logs directory
# must already exist before running sbatch.

REF="/public/home/ryx13/genome_cad/juicer/run_3ddna/review/Ont_filt_asm.bp.p_ctg.top21.chr.seqkit.fasta"
READS="/public/home/ryx13/genome_cad/hifiasm_ont/ONT_raw.filtlong.fastq.gz"
OUTDIR="/public/home/ryx13/genome_cad/assembly_validation/ont_mapping"

MINIMAP2="/public/share/ac4w0a7em6/ryx13_software/micromamba/envs/centier_env/bin/minimap2"
SAMTOOLS="/public/software/apps/samtools/1.9/gcc-7.3.1/bin/samtools"

THREADS="${SLURM_CPUS_PER_TASK:-32}"

mkdir -p "${OUTDIR}" /public/home/ryx13/genome_cad/logs

BAM="${OUTDIR}/ONT_raw.filtlong.to_T2T_top21.sorted.bam"
FLAGSTAT="${OUTDIR}/ONT_raw.filtlong.to_T2T_top21.flagstat.txt"
COVERAGE="${OUTDIR}/ONT_raw.filtlong.to_T2T_top21.samtools_coverage.tsv"
DEPTH_GZ="${OUTDIR}/ONT_raw.filtlong.to_T2T_top21.depth.tsv.gz"
DEPTH_SUMMARY="${OUTDIR}/ONT_raw.filtlong.to_T2T_top21.depth_summary.tsv"
SUMMARY="${OUTDIR}/ONT_mapping_summary.tsv"

echo "[INFO] Reference: ${REF}"
echo "[INFO] Reads: ${READS}"
echo "[INFO] Output directory: ${OUTDIR}"
echo "[INFO] Threads: ${THREADS}"

"${MINIMAP2}" -t "${THREADS}" -ax map-ont "${REF}" "${READS}" \
  | "${SAMTOOLS}" sort -@ 8 -m 3G -o "${BAM}" -

"${SAMTOOLS}" index "${BAM}"
"${SAMTOOLS}" flagstat "${BAM}" > "${FLAGSTAT}"
"${SAMTOOLS}" coverage "${BAM}" > "${COVERAGE}"

"${SAMTOOLS}" depth -aa "${BAM}" | gzip -c > "${DEPTH_GZ}"

gzip -dc "${DEPTH_GZ}" \
  | awk 'BEGIN{OFS="\t"; print "chromosome","length_bp","covered_bp","coverage_breadth_percent","mean_depth"}
         {
           len[$1]++;
           depth_sum[$1]+=$3;
           if ($3 > 0) covered[$1]++;
         }
         END{
           for (chr in len) {
             printf "%s\t%d\t%d\t%.6f\t%.6f\n", chr, len[chr], covered[chr], covered[chr] * 100 / len[chr], depth_sum[chr] / len[chr];
           }
         }' \
  | sort -k1,1V > "${DEPTH_SUMMARY}"

awk '
  BEGIN{OFS="\t"}
  NR==1{next}
  {
    len+=$3;
    cov+=$5;
    depth_sum += $7 * $3;
  }
  END{
    print "metric","value","note";
    print "reference_fasta","/public/home/ryx13/genome_cad/juicer/run_3ddna/review/Ont_filt_asm.bp.p_ctg.top21.chr.seqkit.fasta","Final 21-chromosome assembly FASTA";
    print "ont_reads","/public/home/ryx13/genome_cad/hifiasm_ont/ONT_raw.filtlong.fastq.gz","Filtered ONT reads";
    print "samtools_coverage_reference_length_bp",len,"Sum of rname lengths in samtools coverage";
    print "samtools_coverage_covered_bases_bp",cov,"Bases with depth >0 from samtools coverage";
    print "samtools_coverage_breadth_percent",cov * 100 / len,"Covered bases / reference length";
    print "samtools_coverage_weighted_mean_depth",depth_sum / len,"Length-weighted mean depth";
  }' "${COVERAGE}" > "${SUMMARY}"

{
  echo
  echo "[INFO] samtools flagstat:"
  cat "${FLAGSTAT}"
  echo
  echo "[INFO] Summary:"
  cat "${SUMMARY}"
} > "${OUTDIR}/ONT_mapping_report.txt"

echo "[DONE] Results written to ${OUTDIR}"
