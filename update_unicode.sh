#!/bin/sh
#See http://www.unicode.org/reports/tr44/
#
#Me Enclosing_Mark  an enclosing combining mark
#Mn Nonspacing_Mark a nonspacing combining mark (zero advance width)
#Cf Format          a format control character
#
UNICODEWIDTH_H=../unicode_width.h
if ! test -d unicode; then
	mkdir unicode
fi &&
( cd unicode &&
	wget -N http://www.unicode.org/Public/UCD/latest/ucd/UnicodeData.txt \
		http://www.unicode.org/Public/UCD/latest/ucd/EastAsianWidth.txt &&
	if ! test -d uniset; then
		git clone https://github.com/depp/uniset.git
	else
	(
		cd uniset &&
		git pull
	)
	fi &&
	(
		cd uniset &&
		if ! test -x uniset; then
			autoreconf -i &&
			./configure --enable-warnings=-Werror CFLAGS='-O0 -ggdb'
		fi &&
		make
	) &&
	UNICODE_DIR=. && export UNICODE_DIR &&
	cat >$UNICODEWIDTH_H <<-EOF
	static const struct interval zero_width[] = {
		$(uniset/uniset --32 cat:Me,Mn,Cf + U+1160..U+11FF - U+00AD)
	};
	static const struct interval double_width[] = {
		$(uniset/uniset --32 eaw:F,W)
	};
	EOF
)
