#!/usr/bin/env nu

[ nu_plugin_inc
  nu_plugin_polars
  nu_plugin_gstat
  nu_plugin_formats
  nu_plugin_query
  nu_plugin_emoji
] | each { cargo install $in --locked } | ignore

glob ~/.cargo/bin/nu_plugin_* |
  each { |name|
    print -e $">> (ansi cyan)($name)(ansi reset)"
    try {
      plugin add $name
    } catch { |err|
        print -e $"(ansi red)($err.msg)(ansi reset)"
    }
  }
