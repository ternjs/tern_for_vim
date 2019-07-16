if !has('python') && !has('python3')
  echo 'tern requires python support'
  finish
endif

call tern#Enable()

" Menu 
menu <silent> Tern.Jump\ To\ Defintion :TernDef<CR>
menu <silent> Tern.See\ Documentation :TernDoc<CR>
menu <silent> Tern.DataType :TernType <CR>
menu <silent> Tern.Show\ all\ References :TernRefs<CR>
menu <silent> Tern.Rename :TernRename <CR> 
