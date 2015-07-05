" keyMapTmp.vim

" Last Update: Jul 05, Sun | 14:05:46 | 2015

" global
function s:KeyFuncLoop(begin,end)
    let l:i = a:begin
    while l:i <= a:end
        execute 'nnoremap <buffer> <silent>'
        \ ' <f' . l:i . '>'
        \ ' :call <sid>SearchFold(' . l:i . ',' .
        \ "'f'" . ')' .
        \ '<cr>'
        execute 'nnoremap <buffer> <silent>'
        \ ' <s-f' . l:i . '>'
        \ ' :call <sid>SearchFold(' . l:i . ',' .
        \ "'b'" . ')' .
        \ '<cr>'
        let l:i = l:i + 1
    endwhile
endfunction

function s:OneWindow()
    if winnr('$') ># 1
        only
    endif
    vsplit
endfunction

function s:KeyCR()
    nnoremap <buffer> <silent> <cr> <c-w>w
    nnoremap <buffer> <silent> <s-cr> <c-w>W
    nnoremap <buffer> <silent> <c-cr>
    \ :call <sid>OneWindow()<cr>
endfunction

function s:AddNum4Note(note,fold)
    let l:scene = '^\d\{1,2} {\{3}' . a:fold . '$'
    execute 'normal! gg0'
    while search(l:scene,'W')
        let l:num_scene = substitute(getline('.'),
        \ '^\(\d\{1,2}\).*$','\1','')
        call moveCursor#SetLineJKFold()
        execute moveCursor#TakeLineNr('J','')
        execute 'normal! 0'
        let l:pat_note = '^' . a:note
        let l:pat_note .= '\d\{0,2}\.\{0,1}'
        let l:pat_note .= '\d\{0,2}'
        let l:new = a:note . l:num_scene . '\.'
        if search(l:pat_note,'c',
        \ line(moveCursor#TakeLineNr('K',''))
        \ )
            execute moveCursor#TakeLineNr('J','K') .
            \ 's/' . l:pat_note . '/' .
            \ l:new . '/'
            execute 'let i=1|' .
            \ moveCursor#TakeLineNr('J','K') . 'g/' .
            \ '\(' . l:new . '\)\@<=/'
            \ 's//\=i/|let i=i+1'
        endif
        execute moveCursor#TakeLineNr('K','')
        execute 'normal! 0'
    endwhile
endfunction

function s:SearchFold(level,move)
    let l:pattern = ' {\{3\}' . a:level . '$'
    if a:move == 'f'
        call search(l:pattern,'w')
        execute 'normal! $'
    elseif a:move == 'b'
        call search(l:pattern,'bw')
        execute 'normal! 0'
    endif
    execute 'normal zt'
endfunction

function s:AddBlankLine()
    g;};-1s;^\(.\)\(}\)\@!;###MARK###\1;e
    %s;^\(###MARK###.*\)$;\1\r;e
    %s;^###MARK###;;e
endfunction

function s:InsertBullet(bullet)
    '<,'>left 0
    if a:bullet == 0
        if line("'<") == line("'>")
            '<s;^;=;
        else
            '<s;^;=;
            '<+1,'>g;^.;s;^;-;
        endif
    elseif a:bullet == 1
        '<,'>g;^.;s;^;-;
    elseif a:bullet == 2
        '<s;^;==;
        '<+1,'>g;^.;s;^;--;
    elseif a:bullet == 3
        '<,'>g;^.;s;^;--;
    endif
endfunction

function s:GlossaryIab(title)
    iabclear <buffer>
    1
    if search(a:title . ' {\{3}\d$') == 0
        return
    endif
    +2
    call moveCursor#SetLineNr('.','J')
    '}
    call moveCursor#SetLineNr('.','K')
    "execute moveCursor#TakeLineNr('J','K') .'s/' .
    "\ '^\s\+//e'
    execute moveCursor#TakeLineNr('J','')
    while line('.') <
    \ moveCursor#TakeLineNr('K','')
        if substitute(getline('.'),'\t','','')
        \ == getline('.')
            echo 'ERROR: Tab not found in Line ' .
            \ line('.') . '!'
            return
        endif
        let l:line = '^\(\s*\*\s*\)\(\S\{-1,}\)\t\(.*\)$'
        let l:left =
        \ substitute(getline('.'),l:line,'\2','')
        let l:right =
        \ substitute(getline('.'),l:line,'\3','')
        exe 'iab <buffer> ' . l:left . ' ' . l:right
        +1
    endwhile
endfunction

function s:AddNote(pattern,level)
    if a:level == foldlevel('.')
        call moveCursor#SetLineJKFold()
        execute moveCursor#TakeLineNr('K','')
        execute 'normal! 0'
    endif
    exe 's;$;\r' . a:pattern . ' {{{' .
    \ a:level . '\r\r\r }}}' . a:level . ';'
    if search('}}}\d\{0,2}$','nW')
    \ == line('.') + 2 && search('^$','nW')
    \ == line('.') + 1
        +1g/^$/delete
    endif
    exe 'normal k[zj'
endfunction

function s:AddSpace()
    4,$s;\(\s\)\@<!+; +;ge
    4,$s;+\(\s\)\@!;+ ;ge
endfunction

function s:IndentFold(pattern,foldlevel)
    let combine = '^' . a:pattern . ' {\{3}'
    let combine .= a:foldlevel .'$'
    1
    while line('.')<line('$')
        call search(combine,'W')
        if substitute(getline('.'),combine,'','')
        \ != getline('.')
            call moveCursor#GetLineNr('.','J')
            exe 'normal ]z'
            call moveCursor#GetLineNr('.','K')
            execute
            \ moveCursor#TakeLineNr('J','K',1,-1) . 's/' .
            \ '^\(\t\{0,1}\)\(\S\)/\t\t\2/e'
            execute moveCursor#TakeLineNr('K','') + 1
        else
            $
        endif
    endwhile
endfunction

function s:SubsQuote()
    4,$s;‘;“;ge
    4,$s;’;”;ge
endfunction

function s:JoinLines()
    exe 'normal {j'
    call moveCursor#GetLineNr('.','J')
    exe 'normal }k'
    call moveCursor#GetLineNr('.','K')
    execute moveCursor#TakeLineNr('J','K') . 'left 0'
    execute moveCursor#TakeLineNr('J','K') . 'join'
    call space#DelSpaceCJK()
    s;^;\t;
endfunction

" files

" commom key mappings

function s:KeyCommon()
    set foldlevel=20
    call <sid>KeyFuncLoop(1,5)
    call <sid>KeyCR()
    call <sid>GlossaryIab('Glossary')
endfunction

au Bufread,BufNew *.read,*.write,*.note
\ call <sid>KeyCommon()

" fisherman.write

function s:Format_Fisherman()
    call moveCursor#KeepPos(0)
    call <sid>AddNum4Note('片段 ',4)
    call <sid>AddNum4Note('摘要 ',4)
    call moveCursor#KeepPos(1)
    Bullet w
    call moveCursor#KeepPos(1)
endfunction

function s:Key_Fisherman()
    call <sid>KeyCR()
    call <sid>KeyFuncLoop(2,5)
    nno <buffer> <silent> <f6>
    \ :call <sid>AddNote('片段 ',5)<cr>
    nno <buffer> <silent> <f12>
    \ :call <sid>Format_Fisherman()<cr>
endfunction

" command

au Bufread fisherman.write
\ call <sid>Key_Fisherman()

" vim: set fdm=indent :
