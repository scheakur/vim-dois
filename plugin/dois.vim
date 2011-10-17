if exists('g:loaded_dois')
    finish
endif

let s:save_cpo = &cpo
set cpo&vim

command! -nargs=? Dois call s:dois(<q-args>)
function! s:dois(args)
    call dois#open_file(a:args)
    redraw!
endfunction

command! -nargs=0 DoisDaily call s:dois_daily()
function! s:dois_daily()
    call dois#open_daily_file()
    redraw!
endfunction

command! -nargs=? DoisAddTask call s:dois_add_task(<q-args>)
function! s:dois_add_task(args)
    call dois#add_task(a:args)
    redraw!
endfunction

command! -nargs=? DoisAddDailyTask call s:dois_add_daily_task(<q-args>)
function! s:dois_add_daily_task(args)
    call dois#add_daily_task(a:args)
    redraw!
endfunction

nnoremap <Plug>(dois:n:dois)  :<C-u>Dois<Return>
nnoremap <silent> <Plug>(dois:n:dois-daily)  :<C-u>DoisDaily<Return>
nnoremap <Plug>(dois:n:add-task)  :<C-u>DoisAddTask<Return>
nnoremap <Plug>(dois:n:add-daily-task)  :<C-u>DoisAddDailyTask<Return>

let g:loaded_dois = 1

let &cpo = s:save_cpo
unlet s:save_cpo
