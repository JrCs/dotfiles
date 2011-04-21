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

" We want case sensitive matchs
syn case match

" Action examples: ACCEPT DENY AllowFTP ACCEPT:info LOG:info ACCEPT:info:ftp

syn match  swActionError    "^\s*\S\+" nextgroup=swSrcZone
syn match  swAction         "^\s*\w\+\(:\w\+\)\?\(:\w\+\)\?\(\s\|$\)"        nextgroup=swSrcZone,swSrcZoneError skipwhite

" According to http://www.shorewall.net/Documentation.htm#Zones
" Zones shuold be 5 lowercase characters or less in length, but we'll only
" check for the structure to avoid annoying *smart* users
" Zone examples: $FW all none net loc net2 zone1!zon12,zon23

syn match  swDstZoneError   "\s\+\S\+" contained nextgroup=swSrcHost,swDstZone
syn match  swSrcZone        "\$FW\|all\|none\|\w\+\!\w\+\(,\w\+\)*\|\w\+" nextgroup=swSrcHost,swSrcHostError,swDstZone contained 

" Host is host_spec,host_spec,...
" host_spec examples:
" eth4 
" eth4:192.168.4.22
" 155.186.235.151
" ~02-00-08-E3-FA-55
" 10.0.0.1-10.0.1.255 10.0.0.1/16
" Too complicated!. Let's just filter the valid characters to keep it simple.

syn match  swSrcHostError   "\S\+" contained nextgroup=DstZone
syn match  swSrcHost        ":\(\w\|[,-:~/\.]\)\+\(\s\|$\)" nextgroup=swDstZone,swDstZoneError contained skipwhite

syn match  swDstZoneError   "\s\+\S\+" contained nextgroup=swDstHost,swProto
syn match  swDstZone        "\s\+\(\$FW\|all\|none\|\w\+\!\w\+\(,\w\+\)*\|\w\+\)" nextgroup=swDstHost,swDstHostError,swProto contained 

syn match  swDstHostError   "\S\+" contained nextgroup=swProto
syn match  swDstHost        ":\(\w\|[,-:~/\.]\)\+\(\s\|$\)" nextgroup=swProto,swProtoError contained skipwhite

" (EXPERIMENTAL) Restrict protocols to: tcp, udp, icmp or all to minimize 
" spelling errors. However, any protocol from /etc/protocols is allowed.
syn match  swProtoError     "\<\S\+\>" contained nextgroup=swDstPort
syn match  swProto          "\s*\(tcp\|udp\|icmp\|all\)"  nextgroup=swDstPort,swComment,swDstPortError contained

" Port examples: 22,80 ssh,http 7070:7090 - 
" We'll just check for numbers + legal services characters (+-._)

syn match  swDstPortError   "\s\+\S\+" contained nextgroup=swSrcPort
syn match  swDstPort        "\s*\(\w\|[+-\._\,]\)\+\(\s\|$\)" nextgroup=swSrcPort,swComment,swSrcPortError contained

syn match  swSrcPortError   "\s\+\S\+" contained nextgroup=swRate
syn match  swSrcPort        "\s*\(\w\|[+-\._\,]\)\+\(\s\|$\)" nextgroup=swRate,swRateError contained

" Seventh colum is RATE LIMIT () for ACCEPT, DENY, and custom rules 
" and ORIGINAL DESTINATION in DNAT/REDIRECT rules.
" RATE LIMIT is <rate>/<interval>[:<burst>]
" ORIGINAL DESTINATION is ipaddr,ipaddr,...

syn match  swRateError      "\s\+\S\+" contained nextgroup=swUser
syn match  swRate           "\s*\(\d\+\/\(min\|sec\)\(:\d\+\)\?\)\|\([0-9\.\/\!,-]\+\)"    nextgroup=swUser,swUserError contained

" User/group is:
" [!][<user name or number>][:<group name or number>][+<program name>]
syn match  swUser           "\s*!\?\(\w\+\|:\w\+\|+\w\+\)\s*$"     contained

" Last but not least, comments
syn match  swComment /\s*#.*/


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

  HiLink swAction        Statement
  HiLink swSrcZone       Type
  HiLink swDstZone       Type
" HiLink swSrcHost       Normal
" HiLink swDstHost       Normal
  HiLink swDstPort       Statement
  HiLink swSrcPort       Identifier
  HiLink swProto         Constant
  HiLink swUser          Constant
  HiLink swRate          PreProc

  HiLink swComment       Comment

  HiLink swActionError   Error
  HiLink swSrcZoneError  Error
  HiLink swDstZoneError  Error
  HiLink swSrcHostError  Error
  HiLink swDstHostError  Error
  HiLink swSrcPortError  Error
  HiLink swDstPortError  Error
  HiLink swProtoError    Error
  HiLink swUserError     Error
  HiLink swRateError     Error

  delcommand HiLink
endif

let b:current_syntax = "shorewall"

" vim: ts=8
