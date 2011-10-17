if exists('b:current_syntax')
  finish
endif

syn case ignore
syn sync fromstart

syn match dois_Comment  /^.*$/
syn match dois_Project  /^.\+:\s*$/
syn match dois_Task  /^\s*-\s\+.*$/
syn match dois_Context  / @[A-Za-z0-9_(\-#,:]\+\()\)\?/ containedin=dois_Task contained
syn match dois_Done  /.* @done.*$/ containedin=dois_Task contained

syn region dois_ProjectFold start=/^.\+:\s*$/ end=/^\s*$/ keepend transparent fold

hi def link dois_Comment  Normal
hi def link dois_Project  Title
hi def link dois_Task  Statement
hi def link dois_Context  Identifier
hi def link dois_Done  NonText

setlocal foldmethod=syntax

let b:current_syntax = 'dois'

