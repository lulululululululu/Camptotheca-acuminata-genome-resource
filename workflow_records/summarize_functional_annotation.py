#!/usr/bin/env python
from pathlib import Path


ROOT = Path("/public/home/ryx13/genome_cad")
QUERY = ROOT / "geta/full_run/chr_liftover/Camptotheca_acuminata_T2T.protein.clean.fasta"
SWISS = ROOT / "functional_annotation/swissprot/Camptotheca_acuminata_T2T_vs_uniprot_sprot.diamond.tsv"
PFAM = ROOT / "functional_annotation/pfam/Camptotheca_acuminata_T2T_vs_Pfam.domtblout"
EGGNOG = ROOT / "functional_annotation/eggnog/Camptotheca_acuminata_T2T_eggnog.emapper.annotations"
KOFAM = ROOT / "functional_annotation/kofam/Camptotheca_acuminata_T2T_vs_Kofam.detail.tsv"
OUTDIR = ROOT / "functional_annotation/summary"
SUBMISSION = ROOT / "tables_for_submission/Supplementary_Table_9_functional_annotation_summary.tsv"
LOCAL_SUMMARY = OUTDIR / "functional_annotation_summary.tsv"


def fasta_ids(path):
    ids = set()
    with path.open() as handle:
        for line in handle:
            if line.startswith(">"):
                ids.add(line[1:].strip().split()[0])
    return ids


def swiss_ids(path):
    ids = set()
    with path.open() as handle:
        for line in handle:
            if line.strip():
                ids.add(line.split("\t", 1)[0])
    return ids


def pfam_ids(path):
    ids = set()
    with path.open() as handle:
        for line in handle:
            if line.startswith("#") or not line.strip():
                continue
            fields = line.split()
            if len(fields) >= 4:
                ids.add(fields[3])
    return ids


def eggnog_ids(path):
    all_ids, go_ids, ko_ids, pathway_ids, cog_ids = set(), set(), set(), set(), set()
    with path.open() as handle:
        for line in handle:
            if line.startswith("#") or not line.strip():
                continue
            fields = line.rstrip("\n").split("\t")
            if len(fields) < 21:
                continue
            qid = fields[0]
            all_ids.add(qid)
            if fields[5] not in {"", "-"}:
                cog_ids.add(qid)
            if fields[9] not in {"", "-"}:
                go_ids.add(qid)
            if fields[11] not in {"", "-"}:
                ko_ids.add(qid)
            if fields[12] not in {"", "-"}:
                pathway_ids.add(qid)
    return all_ids, go_ids, ko_ids, pathway_ids, cog_ids


def kofam_ids(path):
    ids = set()
    with path.open() as handle:
        for line in handle:
            if not line.startswith("*\t"):
                continue
            fields = line.rstrip("\n").split("\t")
            if len(fields) >= 3:
                ids.add(fields[1])
    return ids


def write_table(path, rows):
    header = [
        "database",
        "annotated_gene_count",
        "annotated_gene_percent",
        "evidence_record",
        "primary_output",
        "status",
    ]
    with path.open("w") as handle:
        handle.write("\t".join(header) + "\n")
        for row in rows:
            handle.write("\t".join(str(row.get(col, "")) for col in header) + "\n")


def main():
    proteins = fasta_ids(QUERY)
    total = len(proteins)
    swiss = swiss_ids(SWISS)
    pfam = pfam_ids(PFAM)
    eggnog_all, eggnog_go, eggnog_ko, eggnog_pathway, eggnog_cog = eggnog_ids(EGGNOG)
    kofam = kofam_ids(KOFAM)
    any_annotation = swiss | pfam | eggnog_all | kofam

    def row(database, ids, evidence, output):
        pct = len(ids) / total * 100 if total else 0
        return {
            "database": database,
            "annotated_gene_count": len(ids),
            "annotated_gene_percent": "{:.2f}".format(pct),
            "evidence_record": evidence,
            "primary_output": str(output),
            "status": "final",
        }

    rows = [
        row("Any functional annotation", any_annotation, "Union of Swiss-Prot, Pfam, eggNOG-mapper and KofamScan hits", LOCAL_SUMMARY),
        row("Swiss-Prot", swiss, "DIAMOND blastp best hit, e-value <= 1e-5", SWISS),
        row("Pfam", pfam, "HMMER hmmscan domain hit using Pfam gathering thresholds", PFAM),
        row("eggNOG/COG", eggnog_all, "eggNOG-mapper annotated proteins", EGGNOG),
        row("eggNOG COG category", eggnog_cog, "eggNOG-mapper proteins with non-empty COG category", EGGNOG),
        row("GO", eggnog_go, "eggNOG-mapper proteins with GO terms", EGGNOG),
        row("KEGG KO from eggNOG-mapper", eggnog_ko, "eggNOG-mapper proteins with KEGG KO terms", EGGNOG),
        row("KEGG pathway from eggNOG-mapper", eggnog_pathway, "eggNOG-mapper proteins with KEGG pathway terms", EGGNOG),
        row("KofamScan KEGG KO", kofam, "KofamScan threshold-supported KO assignment", KOFAM),
    ]

    OUTDIR.mkdir(parents=True, exist_ok=True)
    write_table(LOCAL_SUMMARY, rows)
    write_table(SUBMISSION, rows)
    print("Wrote {}".format(LOCAL_SUMMARY))
    print("Wrote {}".format(SUBMISSION))


if __name__ == "__main__":
    main()
