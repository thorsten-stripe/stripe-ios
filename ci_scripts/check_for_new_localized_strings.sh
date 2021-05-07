#!/bin/bash

find Stripe -name \*.swift ! -name STPLocalizedString.swift -print0 | xargs -0 genstrings -s STPLocalizedString -o Stripe/Resources/Localizations/en.lproj

if [[ $? -eq 0 ]]; then

  # Genstrings outputs in utf16 but we want to store in utf8
  iconv -f utf-16 -t utf-8 Stripe/Resources/Localizations/en.lproj/Localizable.strings > Stripe/Resources/Localizations/en.lproj/Localizable.strings.utf8
  
  if [[ $? -eq 0 ]]; then
    rm Stripe/Resources/Localizations/en.lproj/Localizable.strings
    mv Stripe/Resources/Localizations/en.lproj/Localizable.strings.utf8 Stripe/Resources/Localizations/en.lproj/Localizable.strings
  else
    echo "Error recoding into utf8"
    exit 1
  fi
else
  echo "Error occurred generating english strings file."
  exit 1
fi

sh ci_scripts/check_for_invalid_formatting_strings.sh
if [[ $? -ne 0 ]]; then
    echo "check_for_invalid_formatting_strings.sh detected strings with invalid formatting characters."
    exit 1
fi

git diff --quiet --exit-code -- Stripe/Resources/Localizations/en.lproj
if [[ $? -ne 0 ]]; then
    echo -e "\t\033[0;31mNew strings detected\033[0m"
    exit 1
else
    exit 0
fi

