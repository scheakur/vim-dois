if exists('b:current_syntax')
  finish
endif

syn case ignore
syn sync fromstart

syn match dois_Comment  /^.*$/
syn match dois_Project  /^.\+:\s*$/
syn match dois_Task  /^\s*-\s\+.*$/
syn match dois_Context  / @[A-Za-z0-9_(\-#,:]\+\()\)\?/ containedin=dois_Task contained

syn region dois_Done  start=/.* @done.*$/ end=/\ze\(^\s*-\s\+.*$\)/

syn region dois_ProjectFold start=/^.\+:\s*$/ end=/^\s*$/ keepend transparent fold

hi def link dois_Comment  Normal
hi def link dois_Project  Title
hi def link dois_Task  Statement
hi def link dois_Context  Identifier
hi def link dois_Done  NonText

setlocal foldmethod=syntax

if &foldenable && dois#option#get('foldopen_init', 1)
    setlocal foldlevel=10
endif

let b:current_syntax = 'dois'

