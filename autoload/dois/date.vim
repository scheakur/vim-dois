let s:Date = {
\   'year': 1970,
\   'month': 1,
\   'day': 1,
\   'epochtime': 0
\}

function! s:Date.new(year, month, day)
    let date = copy(s:Date)
    let date.year = str2nr(a:year)
    let date.month =  str2nr(a:month)
    let date.day =  str2nr(a:day)
    let date.epochtime = s:epochtime(a:year, a:month, a:day)
    return date
endfunction

function! s:Date.next()
    if (s:is_last_day(self))
        let self.day = 1
        if (self.month == 12)
            let self.month = 1
            let self.year += 1
        else
            let self.month += 1
        endif
    else
        let self.day += 1
    endif
    return self
endfunction

function! s:Date.prev()
    if (s:is_first_day(self))
        if (self.month == 1)
            let self.month = 12
            let self.year -= 1
        else
            let self.month -= 1
        endif
        let self.day = s:get_last_day(self.year, self.month)
    else
        let self.day -= 1
    endif
    return self
endfunction

function! s:Date.format(fmt)
    return strftime(a:fmt, self.epochtime)
endfunction

function! dois#date#today()
    return s:today()
endfunction

" script local functions {{{
let s:last_days = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
let s:day_in_seconds = 60 * 60 * 24

function! s:today()
    return s:Date.new(strftime('%Y'), strftime('%m'), strftime('%d'))
endfunction

function! s:is_first_day(date)
    return a:date.day == 1
endfunction

function! s:is_last_day(date)
    let last = s:get_last_day(a:date.year, a:date.month)
    return a:date.day == last
endfunction

function! s:get_last_day(year, month)
    let last = get(s:last_days, a:month - 1)
    if (a:month == 2 && s:is_leap_year(a:year))
        let last += 1
    endif
    return last
endfunction

function! s:epochtime(year, month, day)
    let days_until_last_year = (a:year - 1970) * 365
    \   + s:count_leap_year_btween_1970_and_(a:year)
    let days_in_this_year = s:count_days_of_year(a:year, a:month, a:day)
    return (days_until_last_year + days_in_this_year) * s:day_in_seconds
endfunction

function! s:count_days_of_year(year, month, day)
    let days = 0
    for i in range(a:month - 1)
        let days += s:get_last_day(a:year, i + 1)
    endfor
    let days += a:day - 1
    return days
endfunction

function! s:is_leap_year(year)
    if (a:year % 400 == 0)
        return 1
    elseif (a:year % 100 == 0)
        return 0
    elseif (a:year % 4 == 0)
        return 1
    else
        return 0
    endif
endfunction

function! s:count_leap_year(year)
    return float2nr(
    \        floor(a:year / 4)
    \      - floor(a:year / 100)
    \      + floor(a:year / 400))
endfunction

let s:count_of_leap_year_until_1970 = s:count_leap_year(1970)

function! s:count_leap_year_btween_1970_and_(year)
    if (a:year < 1970)
        return 0
    endif
    let cnt = s:count_leap_year(a:year)
    return cnt - s:count_of_leap_year_until_1970
endfunction
" }}}
