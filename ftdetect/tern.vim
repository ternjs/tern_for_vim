augroup TernFtdetect
  autocmd!
  autocmd BufNewFile,BufRead .tern-project setfiletype json
  autocmd BufNewFile,BufRead .tern-config setfiletype json
augroup END
