let s:Date = {
\   'year': 1970,
\   'month': 1,
\   'day': 1
\}

let s:last_days = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
let s:day_in_seconds = 60 * 60 * 24

function! s:Date.new(year, month, day)
    let date = copy(s:Date)
    let date.year = str2nr(a:year)
    let date.month =  str2nr(a:month)
    let date.day =  str2nr(a:day)
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

function! s:Date.yyyy()
    return printf('%04d', self.year)
endfunction

function! s:Date.mm()
    return printf('%02d', self.month)
endfunction

function! s:Date.dd()
    return printf('%02d', self.day)
endfunction

function! s:Date.format(fmt)
    let str = a:fmt
    let str = substitute(str, '%Y', self.yyyy(), 'g')
    let str = substitute(str, '%m', self.mm(), 'g')
    let str = substitute(str, '%d', self.dd(), 'g')
    return str
endfunction


function! dois#date#today()
    return s:today()
endfunction

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
