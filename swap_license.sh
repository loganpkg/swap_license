#! /bin/sh

#
# Copyright (c) 2025 Logan Ryan McLintock. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
# 3. Neither the name of the copyright holder nor the names of its
#    contributors may be used to endorse or promote products derived
#    from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#

# A simple script to assist in changing the license of a software project.

set -e
set -u
set -x

# Existing license height.
h=15

# New license directory.
new_l=bsd_3

export h new_l

find . -type f ! -path '*.git/*' ! -name '*_new' -exec sh -c '
    set -e
    set -u
    set -x

    fn="$1"

    y=$(git log --follow --date=format:%Y --pretty=format:%ad -- "$fn" \
        | sort --uniq | tr "\n" "," | sed -E -e "s/,/, /g" -e "s/, $//")

    t=$(head -n 1 "$fn")

    if [ "$t" = "/*" ]
    then
        sed -E "s/<YEAR>/$y/" ../"$new_l"/c_license > "$fn"_new
        tail -n +"$((h + 1))" "$fn" >> "$fn"_new
    elif printf %s "$t" | grep -E "^#! /"
    then
        head -n 2 "$fn" > "$fn"_new
        sed -E "s/<YEAR>/$y/" ../"$new_l"/sh_license >> "$fn"_new
        tail -n +"$((2 + h + 1))" "$fn" >> "$fn"_new
        chmod 700 "$fn"_new
    elif [ "$t" = "divert(-1)" ]
    then
        head -n 2 "$fn" > "$fn"_new
        sed -E "s/<YEAR>/$y/" ../"$new_l"/sh_license >> "$fn"_new
        tail -n +"$((2 + h + 1))" "$fn" >> "$fn"_new
    elif [ "$t" = "::" ]
    then
        sed -E "s/<YEAR>/$y/" ../"$new_l"/cmd_license > "$fn"_new
        tail -n +"$((h + 1))" "$fn" >> "$fn"_new
    elif [ "$t" = "#" ]
    then
        sed -E "s/<YEAR>/$y/" ../"$new_l"/sh_license > "$fn"_new
        tail -n +"$((h + 1))" "$fn" >> "$fn"_new
    elif [ "$t" = ";" ]
    then
        sed -E "s/<YEAR>/$y/" ../"$new_l"/asm_license > "$fn"_new
        tail -n +"$((h + 1))" "$fn" >> "$fn"_new
    elif [ "$t" = "<!--" ]
    then
        head -n 2 "$fn" > "$fn"_new
        sed -E "s/<YEAR>/$y/" ../"$new_l"/LICENSE >> "$fn"_new
        tail -n +"$((h + 1))" "$fn" >> "$fn"_new
    elif printf %s "$t" | grep -E "^((Copyright)|(SPDX))"
    then
        sed -E "s/<YEAR>/$y/" ../"$new_l"/LICENSE > "$fn"_new
    fi
    ' sh '{}' \;


find . -type f ! -path '*.git/*' -name '*_new' -exec sh -c '
    set -e
    set -u
    set -x

    fn="$1"
    h=$(printf %s "$fn" | sed -E "s/_new$//")
    mv "$fn" "$h"
    ' sh '{}' \;
