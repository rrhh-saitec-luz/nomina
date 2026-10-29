# Frozen_string_literal: true

YEARS = -> { Concepto.pluck(:ANO).uniq }
