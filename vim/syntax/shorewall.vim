" Vim syntax file
" Language:	shorewall 2.x
" Version:      0.2
" Maintainer:	Pablo Hoffman <pablo@pablohoffman.com>
" Filenames:    /etc/shorewall/rules
" URL:		http://pablohoffman.com/software/vim/shorewall.vim
" Last change:	Thu Dev 14 2006
"
" ChangeLog: v0.2 11/14/06 by Daniel Graña <dangra@gmail.com>
"               fix valid syntax with comments at end of line

" Shorewall rules line format:
"TARGET SOURCE DEST PROTO DEST SOURCE_PORT RATE_LIMIT/ORIG.DEST USER/GROUP

" For version 5.x: Clear all syntax items
" For version 6.x: Quit when a syntax file was already loaded
if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

" Shorewall rules file syntax match according to:
" http://www.shorewall.net/Documentation.htm#Rules

" Set the local value of the 'iskeyword' option
if version >= 600
  setlocal iskeyword=@,+,-,!,$
else
  set iskeyword=@,+,-,!,$
endif

let s:cpo_save = &cpo
set cpo-=C  " Allow line continuations

" We want case sensitive matchs
syn case match

" Keywords
syn keyword swAction ACCEPT ACCEPT+ ACCEPT! NONAT DROP DROP! REJECT REJECT! contained
syn keyword swAction DNAT DNAT- REDIRECT REDIRECT- CONTINUE CONTINUE! contained
syn keyword swAction LOG QUEUE QUEUE! NFQUEUE NFQUEUE! COUNT ADD DEL contained

syn keyword swZoneConst $FW all all+ all- all+- any any+ any- none contained containedin=swComment,swSrcZone,swSrcHost
syn keyword swRandConst random contained containedin=swDstPort

" Action Field
syn cluster swAction  contains=swTargetError,swTarget,swMacro
syn region  swActionField start="^\s*\w"  end="\ze\%(\_s\|\\\)" contains=@swAction nextgroup=swLineCont1,swSrcField skipwhite
syn match   swTargetError /\S\+/ contained
syn match   swTarget      /\w\+/ contained contains=swTargetError,swAction nextgroup=swTargetLog
" old macro syntax: macro/action
syn match   swMacro       /^\w\+[/]\%(\w\|,\)\+\>/ contained contains=swAction nextgroup=swTargetLog
" new macro syntax: macro(action)
syn match   swMacro       /^\w\+(\%(\w\|,\)\+)/ contained contains=swAction nextgroup=swTargetLog
syn match   swTargetLog   ":$\?\w\+[!]\?"hs=s+1 contained nextgroup=swTargetTag
syn match   swTargetTag   ":$\?\w\+"hs=s+1 contained

" Source Field
syn region  swSrcField  start="\S" end="\ze\%(\_s\|\\\)"  contained contains=swSrcError,swSrcZone nextgroup=swLineCont2,swDstField skipwhite
syn match   swSrcError  /\S\+/ contained
syn match   swSrcZone   /-\|\$\?\w\+[+]\?[-]\?\>/ contained nextgroup=swSrcHost
syn match   swSrcHost   /:\%($\?\w\|[-!,~&/\[\].+]\)\+/hs=s+1 contained

" Destination Field
syn region  swDstField  start="\S" end="\ze\%(\_s\|\\\)"  contained contains=swDstError,swDstZone nextgroup=swLineCont3,swProtoField skipwhite
syn match   swDstError  /\S\+/ contained
" A zone without variable. Examples: dmz -
syn match   swDstZone   /-\|\w\+[+]\?[-]\?\>/ contained nextgroup=swDstHost
syn match   swDstHost   /:\%($\?\w\|[-!,~&/\[\].+]\)\+/hs=s+1 contained nextgroup=swDstZonePort
" A zone:host defined in a variable. Examples: $SERVER1
syn match   swDstZone   /\$\w\+\>/ contained nextgroup=swDstZonePort
" Port examples: 21,80,ssh,moira_db,7070-7090
" We'll just check for numbers + legal services characters (-_)
syn match   swDstZonePort   /:\%(\%(\$\?\%(\w\|-\)\+\)[,]\?\)\+\%(:random\)\?/hs=s+1 contained

" Proto Field
syn region  swProtoField  start=/\S/ end=/\ze\%(\_s\|\\\)/  contained contains=swProtoError,swProto nextgroup=swLineCont4,swDstPortField skipwhite
syn match   swProtoError  /\S\+/ contained
syn match   swProto       "-\|\%(\w\|,\)\+" contained

" Destination Port Field
syn region  swDstPortField start=/\S/ end=/\ze\%(\_s\|\\\)/  contained contains=swDstPortError,swDstPort nextgroup=swLineCont5,swSrcPortField skipwhite
syn match   swDstPortError /\S\+/ contained
" Port examples: ssh,1024:1030,!1026
" for ICMP: 3/4
syn match   swDstPort     "\$\?\%(\h\|-\)\+[,]\?" contained
syn match   swDstPort     "[!]\?\d\{1,5}\%([:/]\d\{1,5}\)\?[,]\?" contained

" Source Port Field
syn region  swSrcPortField start=/\S/ end=/\ze\%(\_s\|\\\)/  contained contains=swSrcPortError,swSrcPort nextgroup=swLineCont6,swOrigDstField skipwhite
syn match   swSrcPortError /\S\+/ contained
" Port examples: ssh,1024:1030
syn match   swSrcPort     "\$\?\%(\h\|-\)\+[,]\?" contained
syn match   swSrcPort     "\d\{1,5}\%([:]\d\{1,5}\)\?[,]\?" contained

" Original destination Field
syn region  swOrigDstField start=/\S/ end=/\ze\%(\_s\|\\\)/  contained contains=swOrigDstError,swOrigDst
syn match   swOrigDstError /\S\+/ contained
syn match   swOrigDst      /\%($\?\w\|[-!,&/\[\].]\)\+/ contained

" Other Directive
syn region  swCommentAction matchgroup=swSpecial start="^\s*COMMENT" end="\_$"
syn region  swSectionAction matchgroup=swSpecial start="^\s*SECTION" end="\_$"
syn region  swIncludeAction matchgroup=swSpecial start="^\s*INCLUDE" end="\_$"
syn region  swScriptAction  matchgroup=swSpecial start="^\s*\%(SHELL\|PERL\)" end="\_$"
syn region  swScriptAction  matchgroup=swSpecial start="^\s*BEGIN\s\+\z(SHELL\|PERL\)" end="END\(\s\+\%(\z1\)\)\?"

" Line Break
syn match   swLineCont1 "\\$" contained nextgroup=swSrcField   skipwhite skipnl
syn match   swLineCont2 "\\$" contained nextgroup=swDstField   skipwhite skipnl
syn match   swLineCont3 "\\$" contained nextgroup=swProtoField skipwhite skipnl
syn match   swLineCont4 "\\$" contained nextgroup=swDstPortField  skipwhite skipnl
syn match   swLineCont5 "\\$" contained nextgroup=swSrcPortField  skipwhite skipnl
syn match   swLineCont6 "\\$" contained nextgroup=swOrigDstField  skipwhite skipnl

" Variables
syn match   swVariable  "\$\w\+" containedin=swComment,swMacro,swTargetLog,swTargetTag,swSrcZone,swSrcHost,swDstZone,swDstHost,swDstZonePort,swDstPort,swSrcPort,swOrigDst

" Last but not least, comments
syn match   swComment /\s*#.*/ contains=swZoneConst

" Define the default highlighting.
" For version 5.7 and earlier: only when not done already
" For version 5.8 and later: only when an item doesn't have highlighting yet
if version >= 508 || !exists("did_shorewall_syn_inits")
  if version < 508
    let did_shorewall_syn_inits = 1
    command -nargs=+ HiLink hi link <args>
  else
    command -nargs=+ HiLink hi def link <args>
  endif

  HiLink swShellAction   Todo
  HiLink swZoneConst     Constant

  HiLink swActionField   PreProc
  HiLink swAction        Statement
  HiLink swTargetError   Error
  HiLink swTarget        Type
  HiLink swMacro         Constant
  HiLink swTargetLog     Special
  HiLink swTargetTag     Identifier

  " HiLink swCommentAction String
  HiLink swSectionAction Type
  " HiLink swIncludeAction String
  HiLink swScriptAction  Special

  HiLink swSrcField      Normal
  HiLink swSrcError      Error
  HiLink swSrcZone       Type
  HiLink swSrcHost       Special

  "HiLink swDstField      Normal
  HiLink swDstField      Preproc
  HiLink swDstError      Error
  HiLink swDstZone       Type
  HiLink swDstHost       Special
  HiLink swDstZonePort   Identifier
  HiLink swRandConst     Constant

  HiLink swProtoField    Preproc
  HiLink swProtoError    Error
  HiLink swProto         Constant

  HiLink swDstPortField  Preproc
  HiLink swDstPortError  Error
  HiLink swDstPort       Constant

  HiLink swSrcPortField  Preproc
  HiLink swSrcPortError  Error
  HiLink swSrcPort       Constant

  HiLink swOrigDstField  Preproc
  HiLink swOrigDstError  Error
  HiLink swOrigDst       Constant

  HiLink swComment       Comment
  HiLink swVariable      PreProc
  HiLink swSpecial       Special
  HiLink swConstant      Constant

  HiLink swLineCont1     Special
  HiLink swLineCont2     Special
  HiLink swLineCont3     Special
  HiLink swLineCont4     Special
  HiLink swLineCont5     Special
  HiLink swLineCont6     Special

  delcommand HiLink
endif

let b:current_syntax = "shorewall"

" vim: ts=8
