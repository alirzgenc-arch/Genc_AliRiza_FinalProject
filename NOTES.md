# Spain Track A - project notes

## 2026-10-29 - CIS raw file replacements (before any extraction was verified)
Four files were CIS "marginales" documents, not the "Estimacion de voto" PDF.
Detected by 02_extract_cis.R (REVIEW_HEADER_NOT_FOUND). Replaced with the correct
Estimacion PDFs downloaded from cis.es on 2026-10-29. Old files and SHA-256:
- 3420  3420mar.pdf        1188c7854e9f1b31d36f89084ccc09649bc3cb67a6978504265ca13dfb09360d
- 3423  es3423mar-2.pdf    88def2eeb6ceecf766b00f17c070098035583064379f3867ad46ef4b95b37905
- 3427  es3427mar.pdf      54800105452422e49d266630461b1a11369d305b41b79952533d893fe1e32466
- 3431  es3431mar-pdf.pdf  a258d9600aeb2dd0d5546c43ecb8c42a46a191c21780c542bb7f547b87f1c02d
New hashes: see reports/qa/cis_raw_inventory.csv.

