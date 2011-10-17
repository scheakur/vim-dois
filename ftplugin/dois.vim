let s:save_cpo = &cpo
set cpo&vim

command! -nargs=? -complete=customlist,dois#complete_tag AddTag call s:add_tag(<q-args>)
function! s:add_tag(args)
    call dois#add_tag(a:args, 0)
endfunction

command! -nargs=? -complete=customlist,dois#complete_tag AddTagWithTimestamp call s:add_tag(<q-args>)
function! s:add_tag_with_timestamp(args)
    call dois#add_tag(a:args, 1)
endfunction

command! -nargs=? -complete=customlist,dois#complete_tag RemoveTag call s:remove_tag(<q-args>)
function! s:remove_tag(args)
    call dois#remove_tag(a:args)
endfunction

command! -nargs=? -complete=customlist,dois#complete_tag ToggleTag call s:toggle_tag(<q-args>)
function! s:toggle_tag(args)
    call dois#toggle_tag(a:args, 0)
endfunction

command! -nargs=? -complete=customlist,dois#complete_tag ToggleTagWithTimestamp call s:toggle_tag_with_timestamp(<q-args>)
function! s:toggle_tag_with_timestamp(args)
    call dois#toggle_tag(a:args, 1)
endfunction

command! -nargs=0 ToggleDone call s:toggle_done()
function! s:toggle_done()
    call dois#toggle_tag('done', 1)
endfunction

nnoremap <buffer> <Plug>(dois:n:add-tag)  :<C-u>AddTag<Return>
nnoremap <buffer> <Plug>(dois:n:remove-tag)  :<C-u>RemoveTag<Return>
nnoremap <buffer> <Plug>(dois:n:toggle-tag)  :<C-u>ToggleTag<Return>
nnoremap <buffer><silent> <Plug>(dois:n:toggle-done)  :<C-u>ToggleDone<Return>

nmap <buffer> <LocalLeader>a  <Plug>(dois:n:add-tag)
nmap <buffer> <LocalLeader>r  <Plug>(dois:n:remove-tag)
nmap <buffer> <LocalLeader>t  <Plug>(dois:n:toggle-tag)
nmap <buffer> <LocalLeader><Return>  <Plug>(dois:n:toggle-done)

let &cpo = s:save_cpo
unlet s:save_cpo
