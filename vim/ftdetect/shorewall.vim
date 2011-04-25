" Vim filetype detection plugin
" Language:     Shorewall configuration files
" Author:       Yves Blusseau <yves.blusseau@gmail.com>

if has("autocmd")

  au BufRead,BufNewFile *   if &ft == 'hog' | call s:MyFTRules() | endif

  " Override filetype detection if file is in a shorewall directory
  func! s:MyFTRules()
    let filepath = expand('<amatch>:p')
    if filepath =~ '/shorewall/'
      " Use set filetype instead of setfiletype to override detection
      setlocal filetype=shorewall
      return
    endif
    try
      let config_lines = readfile(filepath,'',30)
    catch /^Vim\%((\a\+)\)\=:E484/
      return
    endtry
    for line in config_lines
      if line =~ "shorewall"
        " Use set filetype instead of setfiletype to override detection
        setlocal filetype=shorewall
        break
      endif
    endfor
  endfunc

endif " has("autocmd")
