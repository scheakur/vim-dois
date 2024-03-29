function! dois#open_file(filepath)
    let file = s:select_target_file(a:filepath, dois#option#get('file'))
    if file != ''
        execute 'edit' file
    else
        echohl ErrorMsg
        echo
        \ 'There are no valid files for dois.' . "\n" .
        \ 'Please check the option value "g:dois_file" or ' .
        \ 'specify a valid filepath as an argument.'
        echohl None
    endif
endfunction

function! dois#open_daily_file()
    let file = s:select_daily_file()
    execute 'edit' file
endfunction

function! dois#open_previous_daily_file()
    let prev = s:select_previous_daily_file()
    if (prev != '')
        execute 'edit' prev
    else
        call dois#open_daily_file()
    endif
endfunction

function! dois#open_daily_file_from_previous()
    let file = s:select_daily_file()
    let prev = s:select_previous_daily_file()
    "TODO
endfunction

function! dois#add_task(task)
    let file = s:select_target_file(dois#option#get('file'))
    call s:add_task(a:task, file)
endfunction

function! dois#add_daily_task(task)
    let file = s:select_daily_file()
    if !filereadable(file)
        execute 'silent write' file
    endif
    call s:add_task(a:task, file)
endfunction

function! dois#complete_tag(arglead, cmdline, cursorpos)
    let b:dois_tag_cache = get(b:, 'dois_tag_cache', [])
    if empty(b:dois_tag_cache)
        let b:dois_tag_cache = s:collect_tags()
    endif
    return filter(copy(b:dois_tag_cache), 'stridx(v:val, a:arglead) == 0')
endfunction

function! dois#toggle_tag(tag, with_timestamp)
    call s:handle_tag(a:tag, function('s:toggle_tag'), a:with_timestamp)
endfunction

function! dois#add_tag(tag, with_timestamp)
    call s:handle_tag(a:tag, function('s:add_tag'), a:with_timestamp)
endfunction

function! dois#remove_tag(tag)
    call s:handle_tag(a:tag, function('s:remove_tag'), 0)
endfunction

" script local functions {{{
" file {{{
function! s:select_target_file(...)
    for filepath in a:000
        if (filepath != '')
            return s:modify_filepath(filepath)
        endif
    endfor
    let file = input('TaskPaper file: ', '', 'file')
    return file
endfunction

function! s:select_base_dir()
    if dois#option#has('dir')
        return dois#option#get('dir')
    else
        return $HOME . '/tmp/taskpaper'
    endif
endfunction

function! s:select_daily_dir(date)
    let base_dir = s:select_base_dir()
    let dir = base_dir . a:date.format('/%Y/%m')
    if !isdirectory(dir)
        call mkdir(dir, 'p')
    endif
    return dir
endfunction

function! s:select_daily_file()
    let today = dois#date#today()
    let dir = s:select_daily_dir(today)
    let filepath = dir . today.format('/%Y-%m-%d')
    return s:modify_filepath(filepath)
endfunction

function! s:select_previous_daily_file(...)
    let base = get(a:, 1, dois#date#today())
    let prev = base.prev()
    let dir = s:select_daily_dir(prev)
    let filepath = dir . prev.format('/%Y-%m-%d')
    let file = s:modify_filepath(filepath)
    if (filereadable(file))
        return file
    endif
    let loop_num = get(a:, 2, 0)
    if (loop_num > 7)
        return ''
    endif
    return s:select_previous_daily_file(prev, loop_num + 1)
endfunction

function! s:modify_filepath(filepath)
    let filepath = fnamemodify(a:filepath, ':p')
    let filepath = s:add_extension(filepath)
    return filepath
endfunction

function! s:add_extension(filename)
    let filename = a:filename
    if (filename !~ '\.taskpaper$')
        if (filename !~ '\.$')
            let filename .= '.'
        endif
        let filename .= 'taskpaper'
    endif
    return filename
endfunction

function! s:add_task(task, file)
    if !filereadable(a:file)
        echohl ErrorMsg
        echo
        \ 'There are no valid files for dois.' . "\n" .
        \ 'Please check the option value "g:dois_file"'
        echohl None
        return 0
    endif
    let task = a:task
    if empty(task)
        let task = input('New task: ', '')
    endif
    if empty(task)
        echo 'Please specify a task to add.'
        return 0
    endif
    call s:add_task_(task, a:file)
endfunction

function! s:add_task_(task, file)
    let prefix = dois#option#get('task_prefix', '- ')
    let newLine = prefix . a:task
    let newLine = s:add_tag(newLine, 'new', 1)
    let curr = readfile(a:file)
    let index = len(curr) - 1
    while index >= 0
       let line = curr[index]
       if line =~ '^\s*$'
           call remove(curr, index)
       else
           break
       endif
       let index -= 1
    endwhile
    call add(curr, newLine)
    call writefile(curr, a:file)
endfunction
" }}}

" tag {{{
function! s:handle_tag(tag, handler, with_timestamp)
    let tag = s:get_tag(a:tag)
    if empty(tag)
        return
    endif
    let line = getline('.')
    let new_line = a:handler(line, tag, a:with_timestamp)
    call setline('.', new_line)
endfunction

function! s:get_tag(tag)
    let tag = a:tag
    if empty(a:tag)
        let tag = input('Input tag: ', tag, 'customlist,dois#complete_tag')
    endif
    return tag
endfunction

function! s:update_cache(tag)
    let b:dois_tag_cache = get(b:, 'dois_tag_cache', [])
    if index(b:dois_tag_cache, a:tag) < 0
        call add(b:dois_tag_cache, a:tag)
        call sort(b:dois_tag_cache)
    endif
endfunction

function! s:add_tag(line, tag, with_timestamp)
    if s:has_tag(a:line, a:tag)
        return a:line
    endif
    call s:update_cache(a:tag)
    if a:with_timestamp
        let dt_format = dois#option#get('dt_format', '%Y-%m-%d,%H:%M')
        let date = strftime(dt_format)
        let tag_str = ' @' . a:tag . '(' . date . ')'
    else
        let tag_str = ' @' . a:tag
    endif
    let new_line = substitute(a:line, '$', tag_str, 'g')
    return new_line
endfunction

function! s:remove_tag(line, tag, with_timestamp)
    "NOTE: a:with_timestamp is not used.
    "But that is need to call from the function s:handle_tag
    let new_line = substitute(a:line, ' \?@' . a:tag . '\(([^)]*)\)\?', '', 'g')
    return new_line
endfunction

function! s:has_tag(line, tag)
    return (a:line =~ '@'. a:tag)
endfunction

function! s:toggle_tag(line, tag, with_timestamp)
    if s:has_tag(a:line, a:tag)
        return s:remove_tag(a:line, a:tag, a:with_timestamp)
    else
        return s:add_tag(a:line, a:tag, a:with_timestamp)
    endif
endfunction

" ugly...
function! s:collect_tags()
    let tags = {}
    let last = getpos('w$')[1]
    call cursor(1, 1)
    let matched = search('@', 'W')
    while(matched > 0)
        let line = getline('.')
        let words = s:extract_tags(line)
        for word in words
            if (!has_key(tags, word))
                let tag_as_str = word
                let tags[word] = tag_as_str
            endif
        endfor
        call cursor(matched + 1, 1)
        if (matched >= last)
            break
        endif
        let matched = search('@', 'W')
    endwhile
    return sort(values(tags))
endfunction

function! s:extract_tags(line)
    return split(substitute(a:line, '[^@]*@\([^ (]*\)[^@]*', '\1,', 'g'), ',')
endfunction
" }}}
" }}}
