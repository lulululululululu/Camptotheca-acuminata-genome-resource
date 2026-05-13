# =========================
# Circos final script (no legend, tunable)
# =========================

library(data.table)
library(circlize)
library(grid)

# ==========================================================
# A) 用户可调参数区（你主要改这里）
# ==========================================================

# ---- A1. 染色体与整体布局 ----
CHR_ORDER <- paste0("chr", 1:21)   # 染色体顺序
START_DEGREE <- 90                 # 圆图起始角度（可试 88/90/270）
GAP_SMALL <- 1.2                   # 染色体间小间隔
GAP_BIG <- 7                       # 最后一个大间隔（开口）
PDF_W <- 10
PDF_H <- 10

# ---- A2. 坐标轴（“染色体长度信息不要太密集”核心参数）----
AXIS_MODE <- "sparse"              # "sparse" / "medium" / "dense"
AXIS_LABEL_CEX <- 0.30             # 坐标字体大小（可调 0.22~0.35）
AXIS_UNIT <- "Mb"                  # "Mb" 或 "Kb"

# ---- A3. 三轨峰值放大（“峰范围更大”核心参数）----
# 说明：
# q_low / q_high: 分位裁剪范围；范围越窄越容易拉大峰谷对比
# gamma: <1 会抬高中低值，让峰更“鼓”；>1 会压平
# amp: 额外振幅放大倍数，>1 增加峰高
GC_Q_LOW <- 0.02
GC_Q_HIGH <- 0.995
GC_GAMMA <- 0.7
GC_AMP <- 0.9

GENE_Q_LOW <- 0.05
GENE_Q_HIGH <- 0.990
GENE_GAMMA <- 0.9
GENE_AMP <- 0.9
GENE_SMOOTH_N <- 3

REP_Q_LOW <- 0.02
REP_Q_HIGH <- 0.995
REP_GAMMA <- 0.9
REP_AMP <- 0.9

# ---- A4. link 参数 ----
N_LINK_PLOT <- 229                 # 你当前link总数就是229；可改小
LINK_ALPHA <- 0.32
LINK_LWD <- 0.28

# ---- A5. 轨道高度（可微调）----
H_LABEL <- 0.042
H_IDEO <- 0.050
H_SIG <- 0.190                      # 三条信号轨道高度

# ---- A6. a/b/c/d/e 位置（按你图可直接改数值）----
POS_A <- c(0.481, 0.880)
POS_B <- c(0.481, 0.825)
POS_C <- c(0.481, 0.750)
POS_D <- c(0.481, 0.675)
POS_E <- c(0.481, 0.620)
PANEL_FONTSIZE <- 12

# ---- A7. 输出 ----
OUT_PDF <- "circos_paper_style_no_legend_tuned14.pdf"

# ==========================================================
# B) 读入数据
# ==========================================================
chr <- fread("circos_chr_size.fixed.txt", header = FALSE)
gc <- fread("gc_90kb.fixed.txt", header = FALSE)
gene <- fread("gene_density_90kb.fixed.txt", header = FALSE)
repeat_data <- fread("repeat_percent_90kb.fixed.txt", header = FALSE)
link <- fread("synteny_blocks.links.6col.txt", header = FALSE)

setnames(chr, c("chr", "start", "end"))
setnames(gc, c("chr", "start", "end", "value"))
setnames(gene, c("chr", "start", "end", "value"))
setnames(repeat_data, c("chr", "start", "end", "value"))
setnames(link, c("chr1", "start1", "end1", "chr2", "start2", "end2"))

# ==========================================================
# C) 清洗
# ==========================================================
chr[, chr := trimws(as.character(chr))]
gc[, chr := trimws(as.character(chr))]
gene[, chr := trimws(as.character(chr))]
repeat_data[, chr := trimws(as.character(repeat_data$chr))]
link[, chr1 := trimws(as.character(chr1))]
link[, chr2 := trimws(as.character(chr2))]

chr[, `:=`(start = as.numeric(start), end = as.numeric(end))]
gc[, `:=`(start = as.numeric(start), end = as.numeric(end), value = as.numeric(value))]
gene[, `:=`(start = as.numeric(start), end = as.numeric(end), value = as.numeric(value))]
repeat_data[, `:=`(start = as.numeric(start), end = as.numeric(end), value = as.numeric(value))]
link[, `:=`(
  start1 = as.numeric(start1), end1 = as.numeric(end1),
  start2 = as.numeric(start2), end2 = as.numeric(end2)
)]

# ==========================================================
# D) 染色体顺序与筛选
# ==========================================================
chr <- chr[chr %in% CHR_ORDER]
chr[, chr := factor(chr, levels = CHR_ORDER)]
setorder(chr, chr)
chr_levels <- as.character(chr$chr)

gc <- gc[chr %in% chr_levels]
gene <- gene[chr %in% chr_levels]
repeat_data <- repeat_data[chr %in% chr_levels]
link <- link[
  chr1 %in% chr_levels & chr2 %in% chr_levels &
    !is.na(start1) & !is.na(end1) & !is.na(start2) & !is.na(end2) &
    start1 < end1 & start2 < end2
]

gc[, chr := factor(chr, levels = chr_levels)]
gene[, chr := factor(chr, levels = chr_levels)]
repeat_data[, chr := factor(chr, levels = chr_levels)]

# ==========================================================
# E) 坐标尺度修正（若长度像Kb则自动放大）
# ==========================================================
chr_median_len <- median(chr$end, na.rm = TRUE)
coord_scale <- ifelse(chr_median_len < 1e6, 1000, 1)

if (coord_scale != 1) {
  chr[, `:=`(start = start * coord_scale, end = end * coord_scale)]
  gc[, `:=`(start = start * coord_scale, end = end * coord_scale)]
  gene[, `:=`(start = start * coord_scale, end = end * coord_scale)]
  repeat_data[, `:=`(start = start * coord_scale, end = end * coord_scale)]
  link[, `:=`(
    start1 = start1 * coord_scale, end1 = end1 * coord_scale,
    start2 = start2 * coord_scale, end2 = end2 * coord_scale
  )]
}

# ==========================================================
# F) 轨道峰值整形函数（峰更大）
# ==========================================================
scale_track <- function(x, q_low, q_high, gamma = 1, amp = 1) {
  lo <- as.numeric(quantile(x, q_low, na.rm = TRUE))
  hi <- as.numeric(quantile(x, q_high, na.rm = TRUE))
  x2 <- pmin(pmax(x, lo), hi)
  x2 <- (x2 - lo) / (hi - lo + 1e-12)   # 0~1
  x2 <- x2^gamma
  x2 <- pmin(1, x2 * amp)               # 振幅放大
  x2
}

# GC
gc_plot <- copy(gc)
gc_plot[, value := scale_track(value, GC_Q_LOW, GC_Q_HIGH, GC_GAMMA, GC_AMP)]

# Gene（log + 平滑 + 放大）
gene[, value_log := log2(value + 1)]
gene[, value_smooth := frollmean(value_log, n = GENE_SMOOTH_N, align = "center"), by = chr]
gene[is.na(value_smooth), value_smooth := value_log]
gene_plot <- gene[, .(
  chr, start, end,
  value = scale_track(value_smooth, GENE_Q_LOW, GENE_Q_HIGH, GENE_GAMMA, GENE_AMP)
)]

# Repeat
rep_plot <- copy(repeat_data)
rep_plot[, value := scale_track(value, REP_Q_LOW, REP_Q_HIGH, REP_GAMMA, REP_AMP)]

# ==========================================================
# G) Link 处理
# ==========================================================
link[, len1 := end1 - start1]
link[, len2 := end2 - start2]
link[, score := pmin(len1, len2)]

n_link_plot <- min(N_LINK_PLOT, nrow(link))
link2 <- link[order(-score)][1:n_link_plot]

bed1 <- as.data.frame(link2[, .(chr1, start1, end1)])
bed2 <- as.data.frame(link2[, .(chr2, start2, end2)])
colnames(bed1) <- c("chr", "start", "end")
colnames(bed2) <- c("chr", "start", "end")

# ==========================================================
# H) 配色
# ==========================================================
ideo_col <- setNames(rep("#0A0FA8", length(chr_levels)), chr_levels)

link_cols <- setNames(
  colorRampPalette(c(
    "#6A00A8", "#B12A90", "#E16462", "#FCA636",
    "#A6D854", "#66C2A5", "#4DBBD5", "#3C5488"
  ))(length(chr_levels)),
  chr_levels
)

link_color_vec <- adjustcolor(link_cols[link2$chr1], alpha.f = LINK_ALPHA)
gc_col <- "#3D63D8"
gene_col <- "#2E8B83"
repeat_col <- "#D96B3B"

# ==========================================================
# I) 坐标轴刻度函数（稀疏/中等/密集）
# ==========================================================
get_axis_step <- function(chr_len, mode = "sparse") {
  if (mode == "sparse") {
    if (chr_len > 8e7) return(2e7)
    if (chr_len > 4e7) return(1e7)
    if (chr_len > 2e7) return(5e6)
    return(4e6)
  } else if (mode == "medium") {
    if (chr_len > 8e7) return(1e7)
    if (chr_len > 4e7) return(5e6)
    if (chr_len > 2e7) return(3e6)
    return(2e6)
  } else {
    if (chr_len > 8e7) return(5e6)
    if (chr_len > 4e7) return(3e6)
    if (chr_len > 2e7) return(2e6)
    return(1e6)
  }
}

axis_label_fun <- function(x) {
  if (AXIS_UNIT == "Kb") paste0(round(x / 1e3), "K") else paste0(round(x / 1e6), "M")
}

# ==========================================================
# J) 绘图
# ==========================================================
pdf(OUT_PDF, width = PDF_W, height = PDF_H, useDingbats = FALSE)
circos.clear()

circos.par(
  start.degree = START_DEGREE,
  gap.degree = c(rep(GAP_SMALL, length(chr_levels) - 1), GAP_BIG),
  track.margin = c(0.002, 0.002),
  cell.padding = c(0, 0, 0, 0),
  points.overflow.warning = FALSE,
  canvas.xlim = c(-1.08, 1.08),
  canvas.ylim = c(-1.08, 1.08)
)

circos.initialize(
  factors = chr$chr,
  xlim = as.matrix(chr[, .(start, end)])
)

# (a) Chr label
circos.trackPlotRegion(
  ylim = c(0, 1), track.height = H_LABEL,
  bg.col = "white", bg.border = NA,
  panel.fun = function(x, y) {
    circos.text(
      CELL_META$xcenter, 1.16, CELL_META$sector.index,
      cex = 0.85, facing = "bending", niceFacing = TRUE, font = 2
    )
  }
)

# (b) Ideogram
circos.trackPlotRegion(
  ylim = c(0, 1), track.height = H_IDEO,
  bg.col = ideo_col[as.character(chr$chr)],
  bg.border = NA,
  panel.fun = function(x, y) {}
)

# Chr axis (更稀疏)
circos.track(
  track.index = get.current.track.index(),
  bg.border = NA,
  panel.fun = function(x, y) {
    chr_len <- CELL_META$xlim[2]
    major_by <- get_axis_step(chr_len, AXIS_MODE)
    major_at <- seq(0, chr_len, by = major_by)
    circos.genomicAxis(
      h = "top",
      major.at = major_at,
      labels = axis_label_fun(major_at),
      labels.cex = AXIS_LABEL_CEX,
      direction = "outside"
    )
  }
)

# (c) GC
circos.genomicTrackPlotRegion(
  gc_plot,
  ylim = c(0, 1), track.height = H_SIG,
  bg.col = "#F3F3F3", bg.border = "white",
  panel.fun = function(region, value, ...) {
    circos.genomicLines(
      region, value[[1]],
      area = TRUE, baseline = 0,
      col = gc_col, border = NA, lwd = 0.50
    )
  }
)

# (d) Gene
circos.genomicTrackPlotRegion(
  gene_plot,
  ylim = c(0, 1), track.height = H_SIG,
  bg.col = "#F3F3F3", bg.border = "white",
  panel.fun = function(region, value, ...) {
    circos.genomicLines(
      region, value[[1]],
      area = TRUE, baseline = 0,
      col = gene_col, border = NA, lwd = 0.50
    )
  }
)

# (e) Repeat
circos.genomicTrackPlotRegion(
  rep_plot,
  ylim = c(0, 1), track.height = H_SIG,
  bg.col = "#F3F3F3", bg.border = "white",
  panel.fun = function(region, value, ...) {
    circos.genomicLines(
      region, value[[1]],
      area = TRUE, baseline = 0,
      col = repeat_col, border = NA, lwd = 0.50
    )
  }
)

# Links
circos.genomicLink(
  bed1, bed2,
  col = link_color_vec,
  border = "#FFFFFF30",
  lwd = LINK_LWD
)

# a/b/c/d/e（位置可调）
grid.text("a", x = unit(POS_A[1], "npc"), y = unit(POS_A[2], "npc"), gp = gpar(fontsize = PANEL_FONTSIZE))
grid.text("b", x = unit(POS_B[1], "npc"), y = unit(POS_B[2], "npc"), gp = gpar(fontsize = PANEL_FONTSIZE))
grid.text("c", x = unit(POS_C[1], "npc"), y = unit(POS_C[2], "npc"), gp = gpar(fontsize = PANEL_FONTSIZE))
grid.text("d", x = unit(POS_D[1], "npc"), y = unit(POS_D[2], "npc"), gp = gpar(fontsize = PANEL_FONTSIZE))
grid.text("e", x = unit(POS_E[1], "npc"), y = unit(POS_E[2], "npc"), gp = gpar(fontsize = PANEL_FONTSIZE))

dev.off()
circos.clear()
