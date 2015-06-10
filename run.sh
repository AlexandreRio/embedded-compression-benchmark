#!/bin/bash
VALGRIND_EXEC='valgrind --tool=massif --stacks=yes -q'

mkdir -p stats/ tmp/ reports/
rm -R tmp/* reports/* stats/* 2> /dev/null

# Huffman coding
ALGO=huffman
echo -n "" > stats/$ALGO-compression
for file in `ls models/`; do
  du -b models/$file | cut -f 1 >> stats/$ALGO-compression
  $VALGRIND_EXEC ./bin/huffman -c models/$file tmp/$file-$ALGO-coded
  echo -n "," >> stats/$ALGO-compression
  du -b tmp/$file-$ALGO-coded | cut -f 1 >> stats/$ALGO-compression
done
mkdir -p reports/reports-$ALGO-coding
mv massif* reports/reports-$ALGO-coding
# Huffman decoding
for file in `ls models/`; do
  $VALGRIND_EXEC ./bin/huffman -u tmp/$file-$ALGO-coded tmp/$file-$ALGO-decoded
done
mkdir -p reports/reports-$ALGO-decoding
mv massif* reports/reports-$ALGO-decoding

# fastlz-1 coding
ALGO=fastlz-1
echo -n "" > stats/$ALGO-compression
for file in `ls models/`; do
  du -b models/$file | cut -f 1 >> stats/$ALGO-compression
  $VALGRIND_EXEC ./bin/6pack -1 models/$file tmp/$file-$ALGO-coded
  echo -n "," >> stats/$ALGO-compression
  du -b tmp/$file-$ALGO-coded | cut -f 1 >> stats/$ALGO-compression
done
mkdir -p reports/reports-$ALGO-coding
mv massif* reports/reports-$ALGO-coding

# fastlz-1 decoding
for file in `ls models/`; do
  $VALGRIND_EXEC ./bin/6unpack tmp/$file-$ALGO-coded
  mv $file tmp/$file-$ALGO-decoded
done
mkdir -p reports/reports-$ALGO-decoding
mv massif* reports/reports-$ALGO-decoding

# fastlz-2 coding
ALGO=fastlz-2
echo -n "" > stats/$ALGO-compression
for file in `ls models/`; do
  du -b models/$file | cut -f 1 >> stats/$ALGO-compression
  $VALGRIND_EXEC ./bin/6pack -2 models/$file tmp/$file-$ALGO-coded
  echo -n "," >> stats/$ALGO-compression
  du -b tmp/$file-$ALGO-coded | cut -f 1 >> stats/$ALGO-compression
done
mkdir -p reports/reports-$ALGO-coding
mv massif* reports/reports-$ALGO-coding

# fastlz-2 decoding
for file in `ls models/`; do
  $VALGRIND_EXEC ./bin/6unpack tmp/$file-$ALGO-coded
  mv $file tmp/$file-$ALGO-decoded
done
mkdir -p reports/reports-$ALGO-decoding
mv massif* reports/reports-$ALGO-decoding

# lzf coding
ALGO=lzf
echo -n "" > stats/$ALGO-compression
for file in `ls models/`; do
  du -b models/$file | cut -f 1 >> stats/$ALGO-compression
  # lzf override the input file
  cp models/$file tmp/$file-$ALGO
  $VALGRIND_EXEC ./bin/lzf -c tmp/$file-$ALGO
  mv tmp/$file-$ALGO\.lzf tmp/$file-$ALGO-coded #default output name
  echo -n "," >> stats/$ALGO-compression
  du -b tmp/$file-$ALGO-coded | cut -f 1 >> stats/$ALGO-compression
done
mkdir -p reports/reports-$ALGO-coding
mv massif* reports/reports-$ALGO-coding

# lzf decoding
for file in `ls models/`; do
  cp tmp/$file-$ALGO-coded tmp/$file-$ALGO-decoded.lzf
  $VALGRIND_EXEC ./bin/lzf -d tmp/$file-$ALGO-decoded.lzf
done
mkdir -p reports/reports-$ALGO-decoding
mv massif* reports/reports-$ALGO-decoding
