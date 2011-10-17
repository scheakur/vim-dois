function! dois#option#has(option_name)
    let key = s:key(a:option_name)
    return has_key(b:, key) || has_key(g:, key)
endfunction

" option#get(option_name, [default_value])
function! dois#option#get(option_name, ...)
    let key = s:key(a:option_name)
    let val = get(b:, key)
    if !empty(val)
        return val
    endif
    let def = 0
    if a:0 > 0
        let def = a:1
    endif
    let val = get(g:, key, def)
    return val
endfunction

function! s:key(option_name)
    return 'dois_' . a:option_name
endfunction
