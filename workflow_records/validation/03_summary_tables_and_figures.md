# Summary tables and figure source-data records

This note records where manuscript validation summaries and figure source data
are stored in the submission package.

## Assembly and annotation summary tables

- ONT read QC: `supplementary_tables/Supplementary_Table_1_ONT_read_QC.tsv`
- chromosome lengths: `supplementary_tables/Supplementary_Table_2_chromosome_lengths.tsv`
- BUSCO summary: `supplementary_tables/Supplementary_Table_3_BUSCO_summary.tsv`
- telomere coordinates: `supplementary_tables/Supplementary_Table_4_telomere_information.tsv`
- centromere coordinates: `supplementary_tables/Supplementary_Table_5_centromere_coordinates.tsv`
- LAI windows: `supplementary_tables/Supplementary_Table_6_LAI_windows.tsv`
- EDTA repeat summary: `supplementary_tables/Supplementary_Table_7_EDTA_repeat_annotation_summary.tsv`
- GETA gene annotation summary: `supplementary_tables/Supplementary_Table_8_GETA_gene_annotation_summary.tsv`
- functional annotation summary: `supplementary_tables/Supplementary_Table_9_functional_annotation_summary.tsv`
- QUAST summary: `supplementary_tables/Supplementary_Table_15_QUAST_summary.tsv`
- data-record inventory: `supplementary_tables/Supplementary_Table_16_data_records_inventory.tsv`

## Source data

- ONT remapping coverage:
  `source_data/assembly_validation/ONT_filtered_reads_mapping_coverage.tsv`
- residual gaps:
  `source_data/assembly_validation/residual_gaps.tsv`
- gap-spanning and split-read summaries:
  `source_data/assembly_validation/gap_spanning_read_summary.tsv` and
  `source_data/assembly_validation/gap_split_read_support_summary.tsv`
- LAI raw output:
  `source_data/assembly_validation/LTR_retriever_LAI_raw_output.tsv`
- BUSCO short summaries:
  `source_data/busco/`
- Circos source data and plotting script:
  `source_data/figure_source_data/`

## Figure-generation records

Figure 3 was generated from the files in `source_data/figure_source_data/`,
including `circos.R`, chromosome sizes, 90-kb GC windows, 90-kb gene-density
windows, 90-kb repeat-fraction windows and MCScanX synteny links.

Figures 2, 4, 5 and 6 were generated from NanoPlot/NanoStat summaries, TIDK and
CentIER outputs, plothic Hi-C heatmaps and BUSCO short-summary files,
respectively. The corresponding raw or tabulated source data are indexed in
`supplementary_tables/Supplementary_Table_16_data_records_inventory.tsv`.
