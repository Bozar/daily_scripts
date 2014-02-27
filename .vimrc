" Bozar's .vimrc file "{{{1
" Last Update: Feb 27, Thu | 10:34:13 | 2014

" Plugins "{{{2

set nocompatible
filetype off
filetype plugin on

" fcitx
" NerdTree
" }}}2

" Functions "{{{2

" windows or linux "{{{3
function! CheckOS() "{{{
	if has('win32')
		return 'windows'
	elseif has('win64')
		return 'windows'
	else
		return 'linux'
	endif
endfunction "}}}
" }}}3

" switch settings "{{{3
function! SwitchSettings(setting) "{{{
	if a:setting=='hlsearch'
		set hlsearch!
		set hlsearch?
	elseif a:setting=='linebreak'
		set linebreak!
		set linebreak?
	" :h expr-option
	elseif a:setting=='background'
		if &background=='dark'
			set background=light
		else
			set background=dark
		endif
	endif
endfunction "}}}
" }}}3

" put text to another file "{{{3
function! PutText(put_line) "{{{
	" 0: overwrite old text
		if a:put_line==0
			$mark j|$put "
			1,'jdelete
	" 1: insert into old text
		elseif a:put_line==1
			1put! "
			1
	" 2: append to old text
		elseif a:put_line==2
			$mark j|$put "
			'j+1
		endif
endfunction "}}}
" }}}3

" mark j & k: visual mode "{{{3
function! VisualMark() "{{{
	'<mark j
	'>mark k
endfunction "}}}
" }}}3

" fold marker "{{{3
" new(0), insert(1), append(2)
" sub-level(3), surrounding(4,5)
function! YankFoldMarker(fold_marker) "{{{
	" creat new
		if a:fold_marker==0 "{{{
			s/$/\rFOLDMARKER {{{\r }}}
			.-1,.s/$/1
			-1 "}}}
	" insert
		elseif a:fold_marker==1 "{{{
			normal [zmj]zmk
			'jyank
			'jput!
			'jput!
			'j-2,'j-1s/^.*\(\s.\{0,1\}{\{3\}\)/\1/
			'j-1s/\s\(.\{0,1\}\){{{/\1 }}}
			'j-2s/^/FOLDMARKER/ "}}}
	" append
		elseif a:fold_marker==2 "{{{
			normal [zmj]zmk
			'jyank
			'kput
			'kput
			'k+1,'k+2s/^.*\(\s.\{0,1\}{\{3\}\)/\1/
			'k+2s/\s\(.\{0,1\}\){{{/\1 }}}
			'k+1s/^/FOLDMARKER/ "}}}
	" creat sub-level
		elseif a:fold_marker==3 "{{{
			normal mh[z
			yank
			'hput
			'hput
			'h+1,'h+2s/^.*\(\s.\{0,1\}{\{3\}\)/\1/
			'h+2s/\s\(.\{0,1\}\){{{/\1 }}}
			'h+1s/^/FOLDMARKER/
			'h+1,'h+2s/\(\d\{1,2\}\)$/\=submatch(0)+1/e
			-1 "}}}
	" creat surrounding sub-level
	" normal
		elseif a:fold_marker==4 "{{{
			'j
			call YankFoldMarker(3)
			'j+1mark h
			'j+2mark l
			'l+1,'kdelete
			'hput
			'h-1,'hjoin!
			s/FOLDMARKER\(\s.\{0,1\}{\{3\}\d\{0,2\}\)$/\1/
			'l-1,'ljoin! "}}}
	" visual
		elseif a:fold_marker==5 "{{{
			call VisualMark()
			call YankFoldMarker(4) "}}}
		endif
endfunction "}}}
" }}}3

" insert bullets: special characters at the beginning of a line "{{{3
function! BulletPoint() "{{{
	" title
	" do not indent title '-'
		'j,'kg/^\(\t\{1,2\}\|\s\{4,8\}\)\-/left 0
		'j,'ks/^-//e
	" paragraph
	" '==' will be replaced with '+'
	"		indent 2 tabs (8 spaces)
		'j,'kg/^\(\|\t\|\s\{4\}\)==/left 8
		'j,'ks/^\(\t\t\)==/\1+ /e
	" '=' will be replaced with '*'
	"	indent 1 tab (4 spaces)
		'j,'kg/^\(\|\s\{4\}\)=/left 4
		'j,'ks/^\(\t\)=/\1* /e
endfunction "}}}
" }}}3

" change fold level "{{{3
function! ChangeFoldLevel(fold_level)  "{{{
	" substract (0), normal
		if a:fold_level==0
			'j,'ks/\({{{\|}}}\)\@<=\d\{1,2\}$/\=submatch(0)-1
	" substract (1), visual
		elseif a:fold_level==1
			call VisualMark()
			call ChangeFoldLevel(0)
	" add (2), normal
		elseif a:fold_level==2
			'j,'ks/\({{{\|}}}\)\@<=\d\{1,2\}$/\=submatch(0)+1
	" add (3), visual
		elseif a:fold_level==3
			call VisualMark()
			call ChangeFoldLevel(2)
		endif
endfunction "}}}
" }}}3

" delete lines "{{{3
function! EmptyLines(empty_line) "{{{
	if a:empty_line==0
		1,$-1g/^$/.+1s/^$/###DELETE_EMPTY_LINES###
		g/^###DELETE_EMPTY_LINES###$/delete
		$g/^$/delete
	elseif a:empty_line==1
		g/^$/delete
	endif
endfunction "}}}
" }}}3

" current time {{{3
" there should be at least 5 lines in a file
" year (%Y) | month (%b) | day (%d) | weekday (%a)
" hour (%H) | miniute (%M) | second (%S)
function! CurrentTime(time_stamp) "{{{
	" update time
		if a:time_stamp==0
			1,5s/\(Last\sUpdate:\s\|最后更新：\)\@<=.*$/\=strftime('%b %d, %a | %H:%M:%S | %Y')/e
			$-4,$s/\(Last\sUpdate:\s\|最后更新：\)\@<=.*$/\=strftime('%b %d, %a | %H:%M:%S | %Y')/e
	" append time
		elseif a:time_stamp==1
			s/$/\r
			s/^/\=strftime('%b %d | %a | %Y')
		endif
endfunction "}}}
" }}}3

" creat page number "{{{3
function! PageNumber() "{{{
	" creat two strings
		let a=1|g/1/s//\=a/|let a=a+10
		%s/$/\r#INSERT_NUMBER#\r
		let a=10|g/#INSERT_NUMBER#/s//\=a/|let a=a+10
	" join nearby lines
		g/0$/.-1,.j
	" add fold marker
		%s/\s/-
		%s/$/ {{{/|%s/$/\r\r }}}
		%s/\({\|}\)$/\12
	" delete additional lines
		g/^ {\{3\}2$/.,.+1delete
	" insert title
		1s/^\(.*\)$/\1\r\1
		1s/2$/1/|$s/2$/1
endfunction "}}}
" }}}3

" Scratch buffer "{{{3
" switch between Scratch and other buffers
function! Switch_Scratch() "{{{
	if bufwinnr(2)==-1
		buffer 2
	else
		execute bufwinnr(2) . 'wincmd w'
	endif
endfunction "}}}
" move text out of Scratch
function! MoveOut_Scratch() "{{{
	1,$yank
	'J
	set nofoldenable
	'Jput
	1g/^$/d
	set foldenable
endfunction "}}}
" creat (0) and edit (1)
" substitute (2), insert (3) and append (4)
" move (5,6) text between buffers
function! ScratchBuffer(scratch) "{{{
	" creat Scratch
		if a:scratch==0 "{{{
			new
			setlocal buftype=nofile
			setlocal bufhidden=hide
			setlocal noswapfile
			setlocal nobuflisted
			s/^/SCRATCH_BUFFER\r
			close "}}}
	" detect if Scratch exsists
		elseif bufexists(2)==0 "{{{
			echo 'ERROR: No Scratch Buffer 2!'
			return "}}}
	" edit Scratch
		elseif a:scratch==1 "{{{
			call Switch_Scratch() "}}}
	" substitute whole Scratch
		elseif a:scratch==2 "{{{
			call Switch_Scratch()
			call PutText(0) "}}}
	" insert text
		elseif a:scratch==3 "{{{
			call Switch_Scratch()
			call PutText(1) "}}}
	" append text
		elseif a:scratch==4 "{{{
			call Switch_Scratch()
			call PutText(2) "}}}
	" move text between Scratch and other buffers
	" normal mode
		elseif a:scratch==5 "{{{
			if bufnr('%')!=2
				set nofoldenable
				1s/^/\r
				if line("'j")==1
					'jmark J
					'j+1,'kdelete
				elseif line("'j")!=1
					'j-1mark J
					'j,'kdelete
				endif
				set foldenable
				call ScratchBuffer(0)
			elseif bufnr('%')==2
				call MoveOut_Scratch()
			endif "}}}
	" visual mode
		elseif a:scratch==6 "{{{
			call VisualMark()
			call ScratchBuffer(5) "}}}
		endif
endfunction "}}}
" }}}3

" GTD "{{{3

" Function key: <F1> "{{{4
" substitute bullet point (*) with finished mark (~)
function! Finished_GTD(day) "{{{
	if a:day==0
		s/^\t\*/\t\~
	elseif a:day==1
		s/^\t\~/\t\*
	endif
endfunction "}}}
function! F1_Normal_GTD() "{{{
	nnoremap <buffer> <silent> <f1> :call Finished_GTD(0)<cr>
endfunction "}}}
function! F1_Shift_Normal_GTD() "{{{
	nnoremap <buffer> <silent> <s-f1> :call Finished_GTD(1)<cr>
endfunction "}}}

function! F1_GTD() "{{{
	call F1_Normal_GTD()
	call F1_Shift_Normal_GTD()
endfunction "}}}
" }}}4

" Function key: <F2> "{{{4
function! AnotherDay_GTD() "{{{
	" insert new lines for another day
	"	mark j and k: yesterday
		call YankFoldMarker(1)
	"	mark h and l: another day
		'j-2mark h
		'j-1mark l
		'j,'j+2y
		'hput
	" change date
		'h+1s/\d\{1,2\}\(日\)\@=/\=submatch(0)+1
	" change foldlevel
		call ChangeFoldLevel(2)
	" fix substitution errors on rare occasions:
	" the second day in a month
	" in which case both }2 will be changed
		g/^ }\{3\}3$/.+1s/^\( }\{3\}\)3$/\12
	" delete additional lines
		'hdelete
		'l-1
		normal wma
endfunction "}}}
function! F2_Normal_GTD() "{{{
	nnoremap <buffer> <silent> <f2> :call AnotherDay_GTD()<cr>
endfunction "}}}

function! F2_GTD() "{{{
	call F2_Normal_GTD()
endfunction "}}}
" }}}4

" Function key: <F3> "{{{4
" weekly check
function! WeeklyCheck_GTD(week) "{{{
	if a:week==0
		s/\(（未完成）\|\)$/（完成）
	elseif a:week==1
		s/\(（完成）\|\)$/（未完成）
	endif
endfunction "}}}
function! F3_Normal_GTD() "{{{
	nnoremap <buffer> <silent> <f3> :call WeeklyCheck_GTD(0)<cr>
endfunction "}}}
function! F3_Shift_Normal_GTD() "{{{
	nnoremap <buffer> <silent> <s-f3> :call WeeklyCheck_GTD(1)<cr>
endfunction "}}}

function! F3_GTD() "{{{
	call F3_Normal_GTD()
	call F3_Shift_Normal_GTD()
endfunction "}}}
" }}}4

function! GetThingsDone() "{{{
	call F1_GTD()
	call F2_GTD()
	call F3_GTD()
endfunction "}}}
" }}}3

" English vocabulary "{{{3

" Function key: <F1> "{{{4
" search bracket '['
function! F1_Normal_Vocab() "{{{
	nnoremap <buffer> <silent> <f1> /\[<cr>"+yi[
endfunction "}}}
function! F1_Shift_Normal_Vocab() "{{{
	nnoremap <buffer> <silent> <s-f1> b?\[<cr>"+yi[
endfunction "}}}
function! F1_Visual_Vocab() "{{{
	vnoremap <buffer> <silent> <f1> :s/\[//gn<cr>
endfunction "}}}

function! F1_Vocab() "{{{
	call F1_Normal_Vocab()
	call F1_Shift_Normal_Vocab()
	call F1_Visual_Vocab()
endfunction "}}}
" }}}4

" Function key: <F2> "{{{4
" search word
function! F2_Normal_Vocab() "{{{
	nnoremap <buffer> <silent> <f2> "+yi[/\[<c-r>+\]<cr>zz
endfunction "}}}

function! F2_Vocab() "{{{
	call F2_Normal_Vocab()
endfunction "}}}
" }}}4

" Function key: <F3> "{{{4
" insert brackets
function! F3_Normal_Vocab() "{{{
	nnoremap <buffer> <silent> <f3> "+ciw[<c-r>"]<esc>
endfunction "}}}
function! F3_Visual_Vocab() "{{{
	vnoremap <buffer> <silent> <f3> s[<c-r>"]<esc>
endfunction "}}}
" delete brackets
function! F3_Shift_Normal_Vocab() "{{{
	nnoremap <buffer> <silent> <s-f3> di[pF[2x
endfunction "}}}

function! F3_Vocab() "{{{
	call F3_Normal_Vocab()
	call F3_Shift_Normal_Vocab()
	call F3_Visual_Vocab()
endfunction "}}}
" }}}4

" Function key: <F4> "{{{4
" update word list
" there should be ONLY ONE list in a file
" Word List {{{
" [word 1]
" [word 2]
" }}}
function! UpdateWordList_Vocab() "{{{
	" j: cursor line | k: last line
		mark j|$mark k
	" clear old list
		?^Word List {{{$?+1;/^ }}}$/-1delete
	" put whole text to the end
		1,$yank|$put
	" delete non-bracket text
		'k+1,$s/\[/\r[/g
		'k+1,$s/\]/]\r/g
		'k+1,$g!/\[/delete
	" move words back to list
		'k+1,$delete
		1
		/^Word List {\{3\}$/put
		?^Word List {\{3\}?s/$/\r
	" back to cursor line
		'j
endfunction "}}}
function! F4_Normal_Vocab() "{{{
	nnoremap <buffer> <silent> <f4> :call UpdateWordList_Vocab()<cr>
endfunction "}}}
" creat blank word list
function! F4_Shift_Normal_Vocab() "{{{
	nnoremap <buffer> <silent> <s-f4> :?{{{?+1s/^/\rWord List {{{\r\r }}}\r<cr>
endfunction "}}}

function! F4_Vocab() "{{{
	call F4_Normal_Vocab()
	call F4_Shift_Normal_Vocab()
endfunction "}}}
" }}}4

" Function key: <F5> "{{{4
" collect word lists
" j: cursor line
function! ColletWordList_Vocab() "{{{
	" clear register, mark position
		let @a=''
		mark j
	" yank word list
		1
		/^Word List {{{$/;/ }}}$/y A
		let @"=@a
	" back to cursor line
		'j
	" put list into Scratch buffer
		ScrSubs
		g/^$/d
endfunction "}}}
function! F5_Normal_Vocab() "{{{
	nnoremap <buffer> <silent> <f5> :call ColletWordList_Vocab()<cr>
endfunction "}}}

function! F5_Vocab() "{{{
	call F5_Normal_Vocab()
endfunction "}}}
" }}}4

function! Vocabulary() "{{{
	call F1_Vocab()
	call F2_Vocab()
	call F3_Vocab()
	call F4_Vocab()
	call F5_Vocab()
endfunction "}}}
" }}}3

" Repository "{{{3

" new date
function! Update_Repo() "{{{
	1s/^\(Last Update:\).*$/\1
	call CurrentTime(1)
	1,2join
endfunction "}}}
" put repository text to Scratch
function! PutIntoScratch_Repo(put) "{{{
	" normal, substitute
		if a:put==0 "{{{
			yank
			call ScratchBuffer(0) "}}}
	" visual, substitute
		elseif a:put==1 "{{{
			'<,'>yank
			call ScratchBuffer(0) "}}}
	" normal, append
		elseif a:put==2 "{{{
			yank
			call ScratchBuffer(2) "}}}
	" visual, append
		elseif a:put==3 "{{{
			'<,'>yank
			call ScratchBuffer(2) "}}}
		endif
endfunction "}}}
" move whole Scratch to repository
function! TakeOutScratch_Repo() "{{{
	mark j
	buffer 2
	1,$yank
	buffer #
	set nofoldenable
	set modifiable
	'jput
	set foldenable
endfunction "}}}

" Function key: <F1> "{{{4
" put text into Scratch, substitute
function! F1_Normal_Repo() "{{{
	nnoremap <buffer> <silent> <f1> :call PutIntoScratch_Repo(0)<cr>
endfunction "}}}
function! F1_Visual_Repo() "{{{
	vnoremap <buffer> <silent> <f1> <esc>:call PutIntoScratch_Repo(1)<cr>
endfunction "}}}
function! F1_Shift_Normal_Repo() "{{{
	nnoremap <buffer> <silent> <s-f1> :call TakeOutScratch_Repo()<cr>
endfunction "}}}

function! F1_Repo() "{{{
	call F1_Normal_Repo()
	call F1_Visual_Repo()
	call F1_Shift_Normal_Repo()
endfunction "}}}
" }}}4

" Function key: <F2> "{{{4
" put text into Scratch, append
function! F2_Normal_Repo() "{{{
	nnoremap <buffer> <silent> <f2> :call PutIntoScratch_Repo(2)<cr>
endfunction "}}}
function! F2_Visual_Repo() "{{{
	vnoremap <buffer> <silent> <f2> <esc>:call PutIntoScratch_Repo(3)<cr>
endfunction "}}}

function! F2_Repo() "{{{
	call F2_Normal_Repo()
	call F2_Visual_Repo()
endfunction "}}}
" }}}4

" Function key: <F3> "{{{4
" switch 'modifiable'
function! F3_Normal_Repo() "{{{
	nnoremap <buffer> <silent> <f3> :set modifiable!<cr>
endfunction "}}}

function! F3_Repo() "{{{
	call F3_Normal_Repo()
endfunction "}}}
" }}}4

function! Repository(repo) "{{{
	if a:repo==0
		call F1_Repo()
		call F2_Repo()
		call F3_Repo()
	elseif a:repo==1
		call Update_Repo()
	endif
endfunction "}}}
" }}}3

" Localization "{{{3

" need to tweak the Excel table first
" insert #MARK# before English column | #END# after the last column

" Chinese | English = glossary = tmp
" left | up-right = middle-right = down-right
" modeline: from left to right
" vim: set linebreak:
" vim: set linebreak nonumber nomodifiable cursorline:
" vim: set nonumber nomodifiable:

" split window equally between all buffers except for glossary
" :resize 3

" " outdated {{{4
" " search nearby lines in English buffer
" " let @d='previous search pattern'
" " let @e='current search pattern'
" function! NearbyLines_Loc() "{{{
" 	let @d=@/
" 	let @e=''
" 	?#MARK#?-20,/#MARK#/+20g=#MARK#=y E
" endfunction "}}}
" " delete all other columns except English and Chinese
" " example: A1, B1, C1(#MARK#), D1(ENG), E1(CHS), F1, ...
" function! DeleteColumns_Loc() "{{{
" 	%s/^.*#MARK#\t//e
" 	%s/\(^.\{-\}\t.\{-\}\)\t.*$/\1/e
" endfunction "}}}
" " put lines into Scratch buffer
" " the previous search pattern is shown at the center of window
" function! F6_Shift_Normal_Loc() "{{{
" 	nnoremap <buffer> <silent> <s-f6>
" 		\ :call NearbyLines_Loc()<cr>
" 		\ :1wincmd w<cr>:buffer 2\|call PutText(0)<cr>
" 		\ /<c-r>d<cr>ma
" 		\ :call DeleteColumns_Loc()<cr>
" 		\ 'azz
" endfunction "}}}
"  }}}4

function! FileFormat_Loc() "{{{
	set fileencoding=utf-8
	set fileformat=unix
	%s/\r//ge
endfunction "}}}

" Function key: <F1> "{{{4
" put cursor after the first \t
function! F1_Normal_Loc() "{{{
	nnoremap <buffer> <silent> <f1> ^f	
endfunction "}}}
" search glossary
" let @c='search pattern'
function! F1_Visual_Loc() "{{{
	vnoremap <buffer> <silent> <f1>
		\ "cy:3wincmd w<cr>gg
		\ :%s/<c-r>c\c//n<cr>
		\ /<c-r>/<cr>
endfunction "}}}
" search GUID (short line) in English buffer
" let @d='GUID'
function! F1_Shift_Normal_Loc() "{{{
  nnoremap <buffer> <silent> <s-f1>
		\ $2F	l"dyt	:2wincmd w<cr>gg
		\ :%s/<c-r>d\c//n<cr>
		\ /<c-r>/<cr>
endfunction "}}} 

function! F1_Loc() "{{{
	call F1_Normal_Loc()
	call F1_Visual_Loc()
	call F1_Shift_Normal_Loc()
endfunction "}}}
" }}}4

" Function key: <F2> "{{{4
" search current buffer and put cursor after the first '\t'
function! F2_Normal_Loc() "{{{
	nnoremap <buffer> <silent> <f2> 
		\ ^yt	gg
		\ :%s/^<c-r>"\(\t\)\@=\c//n<cr>
		\ /<c-r>/<cr>^f	
endfunction "}}}
function! F2_Visual_Loc() "{{{
	vnoremap <buffer> <silent> <f2> 
		\ ygg
		\ :%s/<c-r>"\c//n<cr>
		\ /<c-r>/<cr>^f	
endfunction "}}}
" search English buffer
function! F2_Shift_Normal_Loc() "{{{
	nnoremap <buffer> <silent> <s-f2> 
		\ ^yt	:2wincmd w<cr>gg
		\ :%s/\(\t#MARK#\t.\{-\}\)\@<=<c-r>"\c//n<cr>
		\ /<c-r>/<cr>
endfunction "}}}
function! F2_Shift_Visual_Loc() "{{{
	vnoremap <buffer> <silent> <s-f2> 
		\ y:2wincmd w<cr>gg
		\ :%s/\(\t#MARK#\t.\{-\}\)\@<=<c-r>"\c//n<cr>
		\ /<c-r>/<cr>
endfunction "}}}

function! F2_Loc() "{{{
	call F2_Normal_Loc()
	call F2_Visual_Loc()
	call F2_Shift_Normal_Loc()
	call F2_Shift_Visual_Loc()
endfunction "}}}
" }}}4

" Function key: <F3> "{{{4
" put '<c-r>/' text into tmp buffer
" let @d='search pattern'
" note: it seems that when a command will delete all characters in one buffer,
" and it is at the end of a script line,
" it will break the key mapping
" compare these two mappings
" nnoremap <f12> ggdG
" \ oTEST<esc>
" nnoremap <f12> ggdGoTEST<esc>
function! F3_Normal_Loc() "{{{
	nnoremap <buffer> <silent> <f3>
		\ :let @d=''\|:g/<c-r>//y D<cr>:4wincmd w<cr>
		\ :call PutText(0)<cr>
endfunction "}}}
" search wrong translation
" let @c='English'
" let @b='Chinese correction'
function! F3_Shift_Normal_Loc() "{{{
	nnoremap <buffer> <silent> <s-f3>
		\ :%s/<c-r>c\(.\{-\}\t.\{-\}<c-r>b\)\@!\c//n<cr>
endfunction "}}}

function! F3_Loc() "{{{
	call F3_Normal_Loc()
	call F3_Shift_Normal_Loc()
endfunction "}}}
" }}}4

" Function key: <F4> "{{{4
" substitute words
" let @c='English'
" let @b='Chinese correction'
" let @a='wrong translation'
function! F4_Normal_Loc() "{{{
	nnoremap <buffer> <silent> <f4>
		\ :%s/\(<c-r>c.\{-\}\t.\{-\}\)\@<=<c-r>a\c//n<cr>
		\ :%s/<c-r>//<c-r>b/gc<cr>
endfunction "}}}
" substitute the whole line
" mark s: substituted line
" mark a: previous line
function! F4_Shift_Normal_Loc() "{{{
	nnoremap <buffer> <silent> <s-f4>
		\ ms^"ayt	f	l"byt	
		\ :%s/^\(<c-r>a\t\).\{-\}\(\t\)/\1<c-r>b\2/gc<cr>
endfunction "}}}
" a-b substitution
function! F4_Visual_Loc() "{{{
	vnoremap <buffer> <silent> <f4>
		\ "by
		\ :%s/<c-r>a/<c-r>b/gc<cr>
endfunction "}}}
function! F4_Shift_Visual_Loc() "{{{
	vnoremap <buffer> <silent> <s-f4>
		\ "ay
		\ :%s/<c-r>a//gc<cr>
endfunction "}}}

function! F4_Loc() "{{{
	call F4_Normal_Loc()
	call F4_Shift_Normal_Loc()
	call F4_Visual_Loc()
	call F4_Shift_Visual_Loc()
endfunction "}}}
" }}}4

" Function key: <F5> "{{{4
" search and complete missing lines
" when there are more than one lines in an Excel cell
" let @d='search pattern'
" let @e='completion'
" mark S (shared between buffers): search line
function! F5_Normal_Loc() "{{{
	nnoremap <buffer> <silent> <f5>
		\ mS^"dy$
		\ :2wincmd w<cr>gg/<c-r>d/+1<cr>
		\ :let @e=''<cr>
		\ :?#MARK#?;/#END#/y E<cr>
		\ :1wincmd w<cr>'Scc<c-r>e<esc>gg
		\ :g/^$/d<cr>/<c-r>d<cr>/#END#/+1<cr>
endfunction "}}}
function! F5_Visual_Loc() "{{{
	vnoremap <buffer> <silent> <f5>
		\ mS"dy
		\ :2wincmd w<cr>gg/<c-r>d/+1<cr>
		\ :let @e=''<cr>
		\ :?#MARK#?;/#END#/y E<cr>
		\ :1wincmd w<cr>'Scc<c-r>e<esc>gg
		\ :g/^$/d<cr>/<c-r>d<cr>/#END#/+1<cr>
endfunction "}}}
" put broken lines into Scratch (left)
function! F5_Shift_Normal_Loc() "{{{
	nnoremap <buffer> <silent> <s-f5>
		\ :let @d=''<cr>
		\ :g/\(#END#\)\@<!$/d D<cr>
		\ :let @"=@d<cr>
		\ :1wincmd w<cr>:b 2<cr>:call PutText(0)<cr>
endfunction "}}}

function! F5_Loc() "{{{
	call F5_Normal_Loc()
	call F5_Visual_Loc()
	call F5_Shift_Normal_Loc()
endfunction "}}}
" }}}4

" Function key: <F6> "{{{4
" add text to bug fix
function! F6_Normal_Loc() "{{{
	nnoremap <buffer> <silent> <f6>
		\ :1,$yank<cr>:1wincmd w<cr>
		\ :b chinese.loc<cr>
		\ :$put! "<cr>'a
		\ :4wincmd w<cr>
endfunction "}}}
" search GUID (long line) in English buffer
function! F6_Shift_Normal_Loc() "{{{
	nnoremap <buffer> <silent> <s-f6>
		\ $F-T	yt	
		\ :2wincmd w<cr>gg
		\ :%s/<c-r>"\c//n<cr>
		\ /<c-r>/<cr>
endfunction "}}}

function! F6_Loc() "{{{
	call F6_Normal_Loc()
	call F6_Shift_Normal_Loc()
endfunction "}}}
" }}}4

" Function key: <F7> "{{{4
" put text into the lower-right buffer
" overwrite buffer
function! F7_Normal_Loc() "{{{
	nnoremap <buffer> <silent> <f7>
		\ :y<cr>:4wincmd w<cr>
		\ :call PutText(0)<cr>
endfunction "}}}
function! F7_Visual_Loc() "{{{
	vnoremap <buffer> <silent> <f7>
		\ :y<cr>:4wincmd w<cr>
		\ :call PutText(0)<cr>
endfunction "}}}
" append to buffer
function! F7_Shift_Normal_Loc() "{{{
	nnoremap <buffer> <silent> <s-f7>
		\ :y<cr>:4wincmd w<cr>
		\ :call PutText(2)<cr>
endfunction "}}}
function! F7_Shift_Visual_Loc() "{{{
	vnoremap <buffer> <silent> <s-f7>
		\ :y<cr>:4wincmd w<cr>
		\ :call PutText(2)<cr>
endfunction "}}}
function! F7_Loc() "{{{
	call F7_Normal_Loc()
	call F7_Visual_Loc()
	call F7_Shift_Normal_Loc()
	call F7_Shift_Visual_Loc()
endfunction "}}}
" }}}4

" Function key: <F8> "{{{4
" move cursor to Chinese in an Excel line
function! F8_Normal_Loc() "{{{
	nnoremap <buffer> <silent> <f8>
		\ ^5/\t<cr>l
endfunction "}}}
" move cursor into the top-right buffer
function! F8_Shift_Normal_Loc() "{{{
	nnoremap <buffer> <silent> <s-f8>
		\ :2wincmd w<cr>
endfunction "}}}
function! F8_Loc() "{{{
	call F8_Normal_Loc()
	call F8_Shift_Normal_Loc()
endfunction "}}}
" }}}4

function! Localization() "{{{
	call F1_Loc()
	call F2_Loc()
	call F3_Loc()
	call F4_Loc()
	call F5_Loc()
	call F6_Loc()
	call F7_Loc()
	call F8_Loc()
endfunction "}}}
" }}}3
" }}}2

" Vim settings "{{{2

" Encoding "{{{3
set encoding=utf-8
set fileencoding=utf-8
set fileencodings=ucs-bom,utf-8,cp936,latin1
set nobomb
" }}}3

" Display "{{{3
" text line
set linespace=0
set display=lastline
set nolinebreak
" syntax
syntax enable
" close buffer
set hidden
" language
" change the name of 'lang' folder will force vim to use English
" window size
" windows | linux GUI | linux terminal
if CheckOS()=='windows' "{{{
	autocmd GUIEnter * simalt ~x
elseif has('gui_running')
	set lines=999
	set columns=999
elseif CheckOS()=='linux'
	set lines=30
	set columns=100
endif "}}}
" colorscheme
set background=dark
if has('gui_running') "{{{
	colorscheme solarized
else
	colorscheme desert
endif "}}}
" status line
set laststatus=2
set ruler
" clear previous settings "{{{
set statusline=
" relative path, modified, readonly, help, preview
set statusline+=%f%m%r%h%w
" fileencoding, fileformat, buffer number, window number
set statusline+=\ [%{&fenc}][%{&ff}][%n]
" set statusline+=\ [%{&fenc}][%{&ff}][%n,%{winnr()}]
" right aligned items
set statusline+=%=
" cursor line number
" can be obtained from :echo line('.')
" keep digits from right to left (just as text item)
set statusline+=%1.4(%l%),
" number of lines
set statusline+=%1.5L
" percentage through file
set statusline+=\ %P
" column number and virtual column number
" set statusline+=[%1.3(%c%)
" set statusline+=%1.4V] "}}}
" number
set number
" command line
set showcmd
set cmdheight=2
set history=100
set wildmenu
" font
set ambiwidth=double
if CheckOS()=='windows' "{{{
	set guifont=Consolas:h15:cANSI
elseif CheckOS()=='linux'
	set guifont=DejaVu\ Sans\ \Mono\ 14
endif "}}}
" }}}3

" Editing "{{{3
set modelines=1
set backspace=indent,eol,start
set sessionoptions=buffers,folds,sesdir,slash,unix,winsize
set matchpairs+=<:>
" use both * and + registers when yanking in visual mode
" least GUI components
set guioptions=aP
" fold
set foldmethod=marker
set foldlevel=20
" search
set ignorecase
set incsearch
set smartcase
" tab
set tabstop=4
set softtabstop=4
set shiftwidth=4
set noexpandtab
" indent
set autoindent
set smartindent
" change directory
if CheckOS()=='windows' "{{{
	cd d:\Documents\
elseif CheckOS()=='linux'
	cd ~/documents/
endif "}}}
" }}}3
" }}}2

" Key mappings and abbreviations "{{{2

" use function keys and commands instead of mapleader "{{{
" see below: '; and :'
set timeoutlen=0
let mapleader='\'
" }}}
" switch case "{{{
nnoremap ` ~
vnoremap ` ~
" }}}
" search backward "{{{
nnoremap , ?
vnoremap , ?
" }}}
" save "{{{
nnoremap <silent> <cr> :wa<cr>
" }}}
" open or close fold "{{{
nnoremap <space> za
" }}}
" move to mark "{{{
nnoremap ' `
" }}}
" modified 'Y' "{{{
nnoremap Y y$
" }}}
" ';', ',' and ':' "{{{
nnoremap ; :
nnoremap <c-n> ;
nnoremap <a-n> ,
vnoremap ; :
vnoremap <c-n> ;
vnoremap <a-n> ,
" }}}
" gj and  gk "{{{
nnoremap <c-j> gj
nnoremap <c-k> gk
vnoremap <c-j> gj
vnoremap <c-k> gk
" }}}
" ^ and $ "{{{
nnoremap 0 ^
nnoremap - $
nnoremap ^ 0
vnoremap 0 ^
vnoremap - $
vnoremap ^ 0
onoremap 0 ^
onoremap - $
onoremap ^ 0
" }}}
" jump between brackets "{{{
nnoremap q %
vnoremap q %
onoremap q %
" }}}
" switch settings "{{{
nnoremap <silent> <c-\> :SwHlsearch<cr>
nnoremap <silent> <a-\> :SwLinebreak<cr>
nnoremap <silent> \ :SwBackground<cr>
" }}}
" change fold level "{{{
nnoremap <silent> <a-=> :FlAdd<cr>
vnoremap <silent> <a-=> <esc>:FlVAdd<cr>
nnoremap <silent> <a--> :FlSub<cr>
vnoremap <silent> <a--> <esc>:FlVSub<cr>
" }}}
" append, insert and creat fold marker "{{{
nnoremap <tab> :FmAppend<cr>
nnoremap <s-tab> :FmInsert<cr>
nnoremap <c-tab> :FmSubLevel<cr>
nnoremap ~ :FmCreat<cr>
nnoremap <a-q> :FmSurround<cr>
vnoremap <a-q> <esc>:FmVSurround<cr>
" }}}
" search visual selection "{{{
" forward, backward and yank match pattern
vnoremap <silent> <tab> y:%s/<c-r>"\c//gn<cr>/<c-r>/<cr>''
vnoremap <silent> <s-tab> y:%s/<c-r>"\c//gn<cr>?<c-r>/<cr>''
vnoremap <silent> <c-tab> y:%s/<c-r>"\c//gn\|let @a=''\|g/<c-r>"\c/y A\|let @"=@a<cr>
" }}}
" Scratch buffer "{{{
" edit
nnoremap <silent> <c-q> :ScrEdit<cr>
" substitute
nnoremap <silent> <backspace> :ScrSubs<cr>
vnoremap <silent> <backspace> y:ScrSubs<cr>
" append
nnoremap <silent> <s-backspace> :ScrAppend<cr>
vnoremap <silent> <s-backspace> y:ScrAppend<cr>
" insert
nnoremap <silent> <c-backspace> :ScrInsert<cr>
vnoremap <silent> <c-backspace> y:ScrInsert<cr>
" move
nnoremap <silent> <a-backspace> :ScrMove<cr>
vnoremap <silent> <a-backspace> zi<esc>:ScrVMove<cr>
" }}}
" }}}2

" User defined commands "{{{2

" insert bullet points "{{{
command! Bullet call BulletPoint()
" }}}
" creat page number "{{{
command! Page call PageNumber()
" }}}
" update current time "{{{
" search 'http://vim.wikia.com' for help
" change language settings in windows
" 时钟、语言和区域——区域和语言——格式：英语（美国）
command! TimeStamp call CurrentTime(0)|normal ''zz
command! Date call CurrentTime(1)
" }}}
" replace '\t' with '\s\s\s\s' | '\t\t' with '\t' "{{{
command! TabToSpace 'j,'ks/\(\t\)\@<!\t\(\t\)\@!/    /ge|'j,'ks/\t\t/\t/ge
" }}}
" delete empty lines "{{{
command! DelEmpty call EmptyLines(1)
command! DelAdd call EmptyLines(0)
" }}}
" Scratch buffer "{{{
" put text to Scratch
command! ScrAppend call ScratchBuffer(4)
command! ScrInsert call ScratchBuffer(3)
command! ScrSubs call ScratchBuffer(2)
" creat new Scratch
command! ScrCreat call ScratchBuffer(0)|ls!
" edit Scratch
command! ScrEdit call ScratchBuffer(1)
" move text between Scratch and other buffers
command! ScrMove call ScratchBuffer(5)
command! ScrVMove call ScratchBuffer(6)
" }}}
" folds "{{{
" change fold level
command! FlSub call ChangeFoldLevel(0)
command! FlVSub call ChangeFoldLevel(1)
command! FlAdd call ChangeFoldLevel(2)
command! FlVAdd call ChangeFoldLevel(3)
" append, insert and creat fold marker
command! FmCreat call YankFoldMarker(0)
command! FmInsert call YankFoldMarker(1)
command! FmAppend call YankFoldMarker(2)
command! FmSubLevel call YankFoldMarker(3)
command! FmSurround call YankFoldMarker(4)
command! FmVSurround call YankFoldMarker(5)
" }}}
" switch settings "{{{
command! SwHlsearch call SwitchSettings('hlsearch')
command! SwLinebreak call SwitchSettings('linebreak')
command! SwBackground call SwitchSettings('background')
" }}}
" Chines word count "{{{
command! Word %s/[^\x00-\xff]//gn
" }}}
" load key mappings "{{{
command! KeVocab call Vocabulary()
command! KeLocal call Localization()
command! KeGTD call GetThingsDone()
command! KeRepo call Repository(0)
" }}}
" localization "{{{
command! LoFormat call FileFormat_Loc()
" }}}
" edit .vimrc "{{{
command! EdVimrc e $MYVIMRC
" }}}
" autocommands "{{{
autocmd BufRead *.loc call Localization()
autocmd BufRead *.gtd call GetThingsDone()
autocmd BufRead *.vocab call Vocabulary()
autocmd BufRead *.repo call Repository(0)
autocmd BufWrite *.repo call Repository(1)
autocmd VimEnter * call ScratchBuffer(0)
" }}}
" }}}2
" vim: set nolinebreak number foldlevel=20: "}}}1
