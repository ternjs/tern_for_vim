if !has('python') && !has('python3')
  echo 'tern requires python support'
  finish
endif

let s:plug = expand("<sfile>:p:h:h")
let s:script = s:plug . '/script/tern.py'
if has('python3')
  execute 'py3file ' . fnameescape(s:script)
elseif has('python')
  execute 'pyfile ' . fnameescape(s:script)
endif

if !exists('g:tern#command')
  let g:tern#command = ["node", expand('<sfile>:h') . '/../node_modules/tern/bin/tern', '--no-port-file']
endif

if !exists('g:tern#arguments')
  let g:tern#arguments = []
endif

function! tern#PreviewInfo(info)
  pclose
  new +setlocal\ previewwindow|setlocal\ buftype=nofile|setlocal\ noswapfile|setlocal\ wrap
  exe "normal z" . &previewheight . "\<cr>"
  call append(0, type(a:info)==type("") ? split(a:info, "\n") : a:info)
  wincmd p
endfunction

function! tern#Complete(findstart, complWord)
  if a:findstart
    if has('python3')
      python3 tern_ensureCompletionCached()
    elseif has('python')
      python tern_ensureCompletionCached()
    endif
    return b:ternLastCompletionPos['start']
  elseif b:ternLastCompletionPos['end'] - b:ternLastCompletionPos['start'] == len(a:complWord)
    return b:ternLastCompletion
  else
    let rest = []
    for entry in b:ternLastCompletion
      if entry["word"] =~ '^\V'. escape(a:complWord, '\')
        call add(rest, entry)
      endif
    endfor
    return rest
  endif
endfunction

function! tern#LookupType()
  if has('python3')
    python3 tern_lookupType()
  elseif has('python')
    python tern_lookupType()
  endif
  return ''
endfunction

function! tern#LookupArgumentHints()
  if g:tern_show_argument_hints == 'no'
    return
  endif
  let fname = get(matchlist(getline('.')[:col('.')-2],'\([a-zA-Z0-9_]*\)([^()]*$'),1)
  let pos   = match(getline('.')[:col('.')-2],'[a-zA-Z0-9_]*([^()]*$')
  if pos >= 0
    if has('python3')
      python3 tern_lookupArgumentHints(vim.eval('fname'),int(vim.eval('pos')))
    elseif has('python')
      python tern_lookupArgumentHints(vim.eval('fname'),int(vim.eval('pos')))
    endif
  endif
  return ''
endfunction

if !exists('g:tern_show_argument_hints')
  let g:tern_show_argument_hints = 'no'
endif

if !exists('g:tern_show_signature_in_pum')
  let g:tern_show_signature_in_pum = 0
endif

if !exists('g:tern_set_omni_function')
  let g:tern_set_omni_function = 1
endif

if !exists('g:tern_map_keys')
  let g:tern_map_keys = 0
endif

if !exists('g:tern_map_prefix')
  let g:tern_map_prefix = '<LocalLeader>'
endif

if !exists('g:tern_request_timeout')
  let g:tern_request_timeout = 1
endif

if !exists('g:tern_request_query')
  let g:tern_request_query = {}
endif

if !exists('g:tern_show_loc_after_rename')
  let g:tern_show_loc_after_rename = 1
endif

if !exists('g:tern_show_loc_after_refs')
  let g:tern_show_loc_after_refs = 1
endif

function! tern#DefaultKeyMap(...)
  let prefix = len(a:000)==1 ? a:1 : "<LocalLeader>"
  execute 'nnoremap <buffer> '.prefix.'tD' ':TernDoc<CR>'
  execute 'nnoremap <buffer> '.prefix.'tb' ':TernDocBrowse<CR>'
  execute 'nnoremap <buffer> '.prefix.'tt' ':TernType<CR>'
  execute 'nnoremap <buffer> '.prefix.'td' ':TernDef<CR>'
  execute 'nnoremap <buffer> '.prefix.'tpd' ':TernDefPreview<CR>'
  execute 'nnoremap <buffer> '.prefix.'tsd' ':TernDefSplit<CR>'
  execute 'nnoremap <buffer> '.prefix.'ttd' ':TernDefTab<CR>'
  execute 'nnoremap <buffer> '.prefix.'tr' ':TernRefs<CR>'
  execute 'nnoremap <buffer> '.prefix.'tR' ':TernRename<CR>'
endfunction

function! tern#Enable()
  if stridx(&buftype, "nofile") > -1 || stridx(&buftype, "nowrite") > -1
    return
  endif

  if has('python3')
    command! -buffer TernDoc py3 tern_lookupDocumentation()
    command! -buffer TernDocBrowse py3 tern_lookupDocumentation(browse=True)
    command! -buffer TernType py3 tern_lookupType()
    command! -buffer TernDef py3 tern_lookupDefinition("edit")
    command! -buffer TernDefPreview py3 tern_lookupDefinition("pedit")
    command! -buffer TernDefSplit py3 tern_lookupDefinition("split")
    command! -buffer TernDefTab py3 tern_lookupDefinition("tabe")
    command! -buffer TernRefs py3 tern_refs()
    command! -buffer -nargs=? TernRename exe 'py3 tern_rename("'.(empty('<args>') ? input("new name? ",expand("<cword>")) : '<args>').'")'
  elseif has('python')
    command! -buffer TernDoc py tern_lookupDocumentation()
    command! -buffer TernDocBrowse py tern_lookupDocumentation(browse=True)
    command! -buffer TernType py tern_lookupType()
    command! -buffer TernDef py tern_lookupDefinition("edit")
    command! -buffer TernDefPreview py tern_lookupDefinition("pedit")
    command! -buffer TernDefSplit py tern_lookupDefinition("split")
    command! -buffer TernDefTab py tern_lookupDefinition("tabe")
    command! -buffer TernRefs py tern_refs()
    command! -buffer -nargs=? TernRename exe 'py tern_rename("'.(empty('<args>') ? input("new name? ",expand("<cword>")) : '<args>').'")'
  endif

  let b:ternProjectDir = ''
  let b:ternLastCompletion = []
  let b:ternLastCompletionPos = {'row': -1, 'start': 0, 'end': 0}
  if !exists('b:ternBufferSentAt')
    let b:ternBufferSentAt = undotree()['seq_cur']
  endif
  let b:ternInsertActive = 0
  if g:tern_set_omni_function
    setlocal omnifunc=tern#Complete
  endif
  if g:tern_map_keys
    call tern#DefaultKeyMap(g:tern_map_prefix)
  endif
  augroup TernAutoCmd
    autocmd! * <buffer>
    if has('python3')
      autocmd BufLeave <buffer> :py3 tern_sendBufferIfDirty()
    elseif has('python')
      autocmd BufLeave <buffer> :py tern_sendBufferIfDirty()
    endif

    if g:tern_show_argument_hints == 'on_move'
      autocmd CursorMoved,CursorMovedI <buffer> call tern#LookupArgumentHints()
    elseif g:tern_show_argument_hints == 'on_hold'
      autocmd CursorHold,CursorHoldI <buffer> call tern#LookupArgumentHints()
    endif
    autocmd InsertEnter <buffer> let b:ternInsertActive = 1
    autocmd InsertLeave <buffer> let b:ternInsertActive = 0
  augroup END
endfunction

augroup TernShutDown
  autocmd VimLeavePre * call tern#Shutdown()
augroup END

function! tern#Disable()
  augroup TernAutoCmd
    autocmd! * <buffer>
  augroup END
endfunction

function! tern#Shutdown()
  if has('python3')
    py3 tern_killServers()
  elseif has('python')
    py tern_killServers()
  endif
endfunction
