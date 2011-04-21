" Shorewall
let s:lnum = 1
while s:lnum < 10
    if getline(s:lnum) =~ '#\s*Shorewall'
        setfiletype shorewall
        break
    endif
    let s:lnum += 1
endwhile
unlet s:lnum
