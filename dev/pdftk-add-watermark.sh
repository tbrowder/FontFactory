# Given a form scanned into pdf,
# use pdftk to convert it into
# a "watermark" of an existing pdf
# page.

# pdftk in.pdf background back.pdf \
#   output out.pdf

INPDF=myinput.pdf
BACKGROUNDPDF=sample-form.pdf
OUTPDF=with-watermark.pdf

pdftk $INPDF background $BACKGROUNDPDF output $OUTPDF

echo See new pdf $OUTPDF
