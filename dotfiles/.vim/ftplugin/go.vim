" run :GoBuild or :GoTestCompile based on the go file
function! s:build_go_files()
  let l:file = expand('%')
  if l:file =~# '^\f\+_test\.go$'
    call go#test#Test(0, 1)
  elseif l:file =~# '^\f\+\.go$'
    call go#cmd#Build(0)
  endif
endfunction

nmap <leader>b  :<C-u>call <SID>build_go_files()<CR>

nnoremap <buffer> <silent> gr <Plug>(go-referrers)
nnoremap <buffer> <silent> gI <Plug>(go-info)
