" Bozar's .vimrc file "{{{1

" Last Update: Nov 22, Sat | 12:49:01 | 2014

" Plugins "{{{2

set nocompatible
filetype off
filetype plugin on

" fcitx
 "}}}2

" Functions "{{{2

" variables "{{{3
 "}}}3

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
 "}}}3

" switch settings "{{{3
function! SwitchSettings(setting) "{{{
		if a:setting==0 "{{{
			set hlsearch!
			set hlsearch? "}}}
		elseif a:setting==1 "{{{
			set linebreak!
			set linebreak? "}}}
	" :h expr-option
		elseif a:setting==2 "{{{
			if &background=='dark'
				set background=light
			else
				set background=dark
			endif "}}}
		elseif a:setting==3 "{{{
			set modifiable!
			set modifiable? "}}}
		elseif a:setting==4
			if substitute(&colorcolumn,50,'','')
			\ == &colorcolumn
				set colorcolumn=50
			else
				set colorcolumn-=50
			endif
		endif
endfunction "}}}
 "}}}3

" search pattern "{{{3
function! SearchPattern(pattern) "{{{
		let SaveCursor=getpos('.')
		let @z=@"
	" a-b substitution
		if a:pattern==0 "{{{
			call search(@a,'c')
			if substitute(getline('.'),@a,'','')==getline('.')
				call setpos('.', SaveCursor)
				echo 'ERROR:' @a 'not found!' 
				return
			else
				execute '%s/'.@a.'/'.@b.'/gc'
			return
			endif "}}}
	" search
		elseif a:pattern==1 "{{{
			let @/=@" "}}}
	" yank all matched pattern
		elseif a:pattern==2 "{{{
			let @x=''
			execute 'g/'.@".'/yank X'
			let @"=@x
			call setpos('.', SaveCursor) "}}}
	" vim grep
		elseif a:pattern==3 "{{{
			execute 'vim /'.@".'/ %'
			"}}}
		endif
	" count matches
		execute '%s/'.@z.'//gn'
endfunction "}}}
 "}}}3

" overwrite whole buffer with @" text "{{{3
function! OverwriteBuffer() "{{{
	1put!
	+1,$delete
endfunction "}}}
 "}}}3

" mapping markers "{{{3
function! MappingMarker(marker) "{{{
	" visual markers to j,k
		if a:marker==0
			'<mark j
			'>mark k
	" h,l to j,k
		elseif a:marker==1
			'hmark j
			'lmark k
		endif
endfunction "}}}
 "}}}3

" fold marker "{{{3
" DO NOT call 'CreatFoldMarker()' alone
" call 'MoveFoldMarker()' instead
" which has fail-safe protocol 'substitute()'
function! CreatFoldMarker(creat) "{{{
	" level one
		if a:creat==0 "{{{
			s/$/\rFOLDMARKER {{{\r }}}/
			.-1,.s/$/1/
		endif "}}}
	" move cursor
		if substitute(getline('.'),
			\'{\{3}\d\{0,2}$','','') != getline('.')
			+1
		endif
	" same level
		if a:creat==1 "{{{
			execute 'normal [zmh]zml'
			'hyank
			'hput
			'hput
			'h+1,'h+2s/^.*\( .\{0,1}{\{3}\d\{0,2}\)$/\1/
			'h+2s/{{{/}}}/
			'h+1s/^/FOLDMARKER/ "}}}
	" higher level
		elseif a:creat==2 "{{{
			call CreatFoldMarker(1)
			'h+1,'h+2s/\(\d\{1,2}\)$/\=submatch(0)+1/e "}}}
		endif
endfunction "}}}
" new (0), after (1), before (2)
" inside (3), wrap text (4,5)
function! MoveFoldMarker(move) "{{{

	" creat level one marker
		if a:move==0 "{{{
			call CreatFoldMarker(0)
			mark k
			-1mark j
			-1
		endif "}}}

	" remember position
		execute 'normal H'
		let Top=line('.')
		''

	" detect fold
		let SaveCursor=getpos('.')
		if substitute(getline('.'),
			\'{\{3}\d\{0,2}$','','') != getline('.')
			+1
		endif
		execute 'normal [z'
		if substitute(getline('.'),'{\{3}\d\{0,2}$','','')==getline('.') "{{{
			echo "ERROR: Fold '[z' not found!"
			call setpos('.', SaveCursor)
			return
		else
			call setpos('.', SaveCursor)
		endif "}}}

	" after
		if a:move==1 "{{{
			call CreatFoldMarker(1)
			'h+1,'h+2delete
			'lput
			execute Top ' | normal zt'
			'l+1 "}}}

	" before
		elseif a:move==2 "{{{
			call CreatFoldMarker(1)
			'h+1,'h+2delete
			'hput!
			execute Top ' | normal zt'
			'h-1 "}}}

	" inside
		elseif a:move==3 "{{{
			mark z
			call CreatFoldMarker(2)
			'h+1,'h+2delete
			'zput
			execute Top ' | normal zt'
			'z+1 "}}}

	" wrap text, normal
		elseif a:move==4 "{{{
			call CreatFoldMarker(2)
			'h+1,'h+2s/\d\{0,2}$//
			'h+1,'h+2delete
			'jput
			'j+1s/^FOLDMARKER//
			'j+2delete
			'kput
			'j,'j+1join!
			'k,'k+1join!
			execute 'normal [z'
			execute Top ' | normal zt'
			'' "}}}

	" wrap text, visual
		elseif a:move==5 "{{{
			call MappingMarker(0)
			call MoveFoldMarker(4)
			execute Top ' | normal zt'
			'' "}}}
		endif

endfunction "}}}
 "}}}3

" change fold level "{{{3
" minus (0,1); plus (2,3)
" delete number (4,5); append number (6,7)
function! ChangeFoldLevel(level)  "{{{
		let SaveCursor=getpos('.')
	" minus, normal
		if a:level==0 "{{{
			" detect level one marker
				'j "{{{
				call search("{{{\|}}}","cW","'k")
				if substitute(getline('.'),'\({{{\|}}}\)1$','','')!=getline('.')
					call setpos('.', SaveCursor)
					echo 'ERROR: Fold level 1 detected!'
					return
				endif "}}}
				'j,'ks/\({{{\|}}}\)\@<=\d\{1,2}$/\=submatch(0)-1/e "}}}
	" minus, visual
		elseif a:level==1 "{{{
			call MappingMarker(0)
			call ChangeFoldLevel(0) "}}}
	" plus, normal
		elseif a:level==2 "{{{
			" fold level exceeds 20
				'j "{{{
				call search("\({{{\|}}}\)[2-9][0-9]$","cW","'k")
				if substitute(getline("."),'\({{{\|}}}\)[2-9][0-9]$','','')!=getline('.')
					call setpos('.', SaveCursor)
					echo 'ERROR: Fold level exceeds 20!'
					return
				endif "}}}
				'j,'ks/\({{{\|}}}\)\@<=\d\{1,2}$/\=submatch(0)+1/e "}}}
	" plus, visual
		elseif a:level==3 "{{{
			call MappingMarker(0)
			call ChangeFoldLevel(2) "}}}
	" delete number, normal
		elseif a:level==4 "{{{
			'j,'ks/\({{{\|}}}\)\@<=\d\{1,2}$//e "}}}
	" delete number, visual
		elseif a:level==5 "{{{
			call MappingMarker(0)
			call ChangeFoldLevel(4) "}}}
	" append number, normal
		elseif a:level==6 "{{{
			'j
			while line(".")<=line("'k")
				if search('\({{{\|}}}\)$','cW',line("'k"))==0
					call setpos('.', SaveCursor)
					return
				endif
				call search('\({{{\|}}}\)$','cW',line("'k"))
				s/\({{{\|}}}\)\@<=$/\=foldlevel(line('.'))/e
				+1
			endwhile "}}}
	" append number, visual
		elseif a:level==7 "{{{
			call MappingMarker(0)
			call ChangeFoldLevel(6) "}}}
		endif
		call setpos('.', SaveCursor)
endfunction "}}}
 "}}}3

" make session "{{{3
function! MakeSession(file) "{{{
	if a:file=='NONEXSIST' "{{{
		let Session=s:NONEXSIST
	elseif a:file=='NONEXSIST'
		let Session=s:NONEXSIST
	endif "}}}
	execute 'mksession!' Session
	echo "NOTE:'" Session "' updated!"
endfunction "}}}
 "}}}3

" time stamp "{{{3
" search 'http://vim.wikia.com' for help
" year (%Y) | month (%b) | day (%d) | weekday (%a)
" hour (%H) | miniute (%M) | second (%S)
function! TimeStamp() "{{{
	s/$/\r/
	s/^/\=strftime('%b %d | %a | %Y')/
endfunction "}}}
 "}}}3

" numbers "{{{3
function! CreatNumber(fold) "{{{
		let NoHyphen='^\(\D*\)\(\d\+\)\(\D*\)$'
		let Hyphen='^\(\D*\)\(\d\+\)-\(\d\+\)\(\D*\)$'
		$s/$/\r
		1
	" chapter
		if substitute(getline('.'),NoHyphen,'','')!=getline('.') "{{{
			let a=substitute(getline('.'),NoHyphen,'\1','')
			let i=substitute(getline('.'),NoHyphen,'\2','')
			let b=substitute(getline('.'),NoHyphen,'\3','')
			while line('.')<line('$')
				let i=i+1
				+1
				execute 's/^.*$/'.a.i.b.'/'
			endwhile "}}}
	" page
		elseif substitute(getline('.'),Hyphen,'','')!=getline('.') "{{{
			let a=substitute(getline('.'),Hyphen,'\1','')
			let i=substitute(getline('.'),Hyphen,'\2','')
			let j=substitute(getline('.'),Hyphen,'\3','')
			let b=substitute(getline('.'),Hyphen,'\4','')
			let k=j-i
			while line('.')<line('$')
				let i=j+1
				let j=j+k+1
				+1
				execute 's/^.*$/'.a.i.'-'.j.b.'/'
			endwhile "}}}
		else
			$delete
			echo 'ERROR: Number pattern not found in the first line!'
			return
		endif
		$delete
	" foldmarker
		if a:fold==0 "{{{
			return
		elseif a:fold==1
			%s/$/ {{{\r\r }}}/
			g/{\|}/s/$/2/
			1s/^/FOLDMARKER {{{\r/
			1s/$/1/
			$s/$/\r }}}/
			$s/$/1/
			1mark j
			$mark k
		endif "}}}
endfunction "}}}
 "}}}3

" Scratch buffer "{{{3
function! SwitchToScratch() "{{{
	if bufwinnr(2)==-1
		buffer 2
	elseif bufwinnr(2)!=bufwinnr('%')
		execute bufwinnr(2).'wincmd w'
	endif
endfunction "}}}
" creat the first Scratch (0), edit (1)
" substitute (2), insert (3) and append (4)
" move (5,6) text between buffers
" creat more Scratches (7)
function! ScratchBuffer(scratch) "{{{
	" creat Scratch
		if a:scratch==0 "{{{
			new
			setlocal buftype=nofile
			setlocal bufhidden=hide
			setlocal noswapfile
			setlocal nobuflisted
			s/^/SCRATCH_BUFFER\r/
			close
		endif "}}}
	" detect if Scratch exsists
		if bufexists(2)==0 "{{{
			echo 'ERROR: Scratch Buffer 2 not found!'
			return
		endif "}}}
	" edit Scratch
		if a:scratch==1 "{{{
			call SwitchToScratch() "}}}
	" substitute whole Scratch
		elseif a:scratch==2 "{{{
			call SwitchToScratch()
			call OverwriteBuffer() "}}}
	" before
		elseif a:scratch==3 "{{{
			call SwitchToScratch()
			1put! "}}}
	" after
		elseif a:scratch==4 "{{{
			call SwitchToScratch()
			$put "}}}
	" move text between Scratch and other buffers
	" normal mode
		elseif a:scratch==5 "{{{
			if bufnr('%')!=2 "{{{
				set nofoldenable
				1s/^/\r/
				if line("'j")==1
					'jmark H
					'j+1,'kdelete
				elseif line("'j")!=1
					'j-1mark H
					'j,'kdelete
				endif
				set foldenable
				call ScratchBuffer(2) "}}}
			elseif bufnr('%')==2 "{{{
				1,$yank
				'H
				set nofoldenable
				'Hput
				1g/^$/d
				set foldenable
				'H
				delmarks H "}}}
			endif "}}}
	" visual mode
		elseif a:scratch==6 "{{{
			call MappingMarker(0)
			call ScratchBuffer(5) "}}}
	" creat more Scratches
		elseif a:scratch==7 "{{{
			call ScratchBuffer(0)
			echo 'Scratch buffer' bufnr('$') 'created!'
			"}}}
		endif
endfunction "}}}
 "}}}3

" English vocabulary "{{{3

" Function key: <F1> "{{{4
" search bracket '['
function! F1_Normal_Vocab() "{{{
	nnoremap <buffer> <silent> <f1> /[<cr>"+yi[
endfunction "}}}
function! F1_Shift_Normal_Vocab() "{{{
	nnoremap <buffer> <silent> <s-f1> 2?[<cr>"+yi[
endfunction "}}}

function! F1_Vocab() "{{{
	call F1_Normal_Vocab()
	call F1_Shift_Normal_Vocab()
endfunction "}}}
 "}}}4

" Function key: <F2> "{{{4
" search word
function Bracket_Vocab() "{{{

	execute 'normal "+yi['
	let @+ = substitute(@+,'\(\(\_.\t\)\| \)',
	\'\\(\\(\\_.\\t\\)\\| \\)','g')
	execute '/\[' . @+ . '\]'

endfunction "}}}
function! F2_Normal_Vocab() "{{{
	nnoremap <buffer> <silent> <f2> :call Bracket_Vocab()<cr>zz
endfunction "}}}

function! F2_Vocab() "{{{
	call F2_Normal_Vocab()
endfunction "}}}
 "}}}4

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
 "}}}4

" Function key: <F4> "{{{4
" update word list
" there should be ONLY ONE list in a file
" Word List "{{{
" [word 1]
" [word 2]
 "}}}
function! UpdateWordList_Vocab() "{{{
		mark h
		let List_Vocab='^\(Word List\)\|\(生词表\) {{{$' "}}}
	" detect word list in the first five lines
		if line('$')<5 "{{{
			echo 'ERROR: There should be at least 5 lines!'
			return
		endif
		1
		call search(List_Vocab,'c')
	" add new Word List if necessary
		if substitute(getline('.'),List_Vocab,'','')==getline('.')
			2s/$/\rWord List {{{\r\r\r }}}/
			'h
		endif "}}}
	" move cursor out of word list
		if line("'h")<=5 "{{{
			execute 'normal [z'
			mark h
		endif "}}}
	" clear old list
	" put whole text to the end
		1 "{{{
		execute '/'.List_Vocab.'/+2;/^ }\{3}$/-1delete'
		$mark z
		1,$yank
		'zput
		$mark x "}}}
	" delete text outside brackets
		'z+1,'xs/\[/\r[/ge "{{{
		'z+1,'xs/\]/]\r/ge
		'z+1,'xg!/\[/delete "}}}
	" add a blank line in the end
		$s;$;\r
	" move words back to list
		'z+1,$delete "{{{
		1
		execute '/'.List_Vocab.'/+1put'
		'h "}}}
endfunction "}}}
function! F4_Normal_Vocab() "{{{
	nnoremap <buffer> <silent> <f4> :call UpdateWordList_Vocab()<cr>
endfunction "}}}

function! F4_Vocab() "{{{
	call F4_Normal_Vocab()
endfunction "}}}
 "}}}4

function! Vocabulary() "{{{4
	let i=1
	while i<5
		execute substitute('call F0_Vocab()',0,i,'')
		let i=i+1
	endwhile
endfunction "}}}4
 "}}}3

" translation "{{{3
" 3 rows: english = chinese = glossary
function! SameLine_Trans(WinNr,WinR,WinC,FType) "{{{
	" detect number of windows
		if winnr('$')!=a:WinNr "{{{
			echo 'ERROR: There should be exact' a:WinNr 'windows for' a:FType.'!'
			return
		endif "}}}
	" move cursor "{{{
		execute a:WinC.'wincmd w'
		let i=line('.')
		execute a:WinR.'wincmd w'
		execute i
		execute 'normal ztma'
		execute a:WinC.'wincmd w'
		"}}}
endfunction "}}}
function! SwitchWindow_Trans(WinN,WinR,WinC,WinG,FType) "{{{
	" WinNumber, WinChinese, WinReference, WinGlossary
	" detect number of windows
		if winnr('$')!=a:WinN "{{{
			echo 'ERROR: There should be exact' a:WinN 'windows for' a:FType.'!'
			return
		endif "}}}
	" yank glossary
		if bufwinnr('%')==a:WinG "{{{
			let @"=substitute(getline('.'),'^.\{-}\t\(.\{-}\)\t.*$','\1','')
		endif "}}}
	" switch between window Chinese and Reference
		if bufwinnr('%')==a:WinC "{{{
			execute a:WinR.'wincmd w'
		else
			execute a:WinC.'wincmd w'
		endif "}}}
endfunction "}}}
" switch buffer
function! SwitchBuffer_Trans(project) "{{{
	" variables
	" translation and localization
		if a:project=='t' "{{{
			let BufR=s:BufE_Pro
			let BufC=s:BufC_Pro
			let BufG=s:BufG_Pro
		elseif a:project=='l'
			let BufR=s:BufT_Loc
			let BufC=s:BufC_Loc
			let BufG=s:BufG_Loc
		endif "}}}
	" detect buffer
		if bufexists(bufname(BufG))==0 "{{{
			echo "ERROR: Buffer '".BufG."' not found!"
			return
		elseif bufexists(bufname(BufC))==0
			echo "ERROR: Buffer '".BufC."' not found!"
			return
		elseif bufexists(bufname(BufR))==0
			echo "ERROR: Buffer '".BufR."' not found!"
			return
		endif "}}}
	" switch buffer
		if bufname('%')==BufG "{{{
			execute 'buffer' BufC
		elseif bufname('%')==BufC
			execute 'buffer' BufR
		else
			execute 'buffer' BufG
		endif "}}}
endfunction "}}}
function! SearchGlossary_Trans(WinN,WinG,FType) "{{{
	" detect number of windows
		if winnr('$')!=a:WinN "{{{
			echo 'ERROR: There should be exact' a:WinN 'windows for' a:FType.'!'
			return
		endif "}}}
	" search "{{{
		execute a:WinG.'wincmd w'
		let @/=@"
		call search(@",'c')
		if substitute(getline('.'),@",'','')==getline('.')
			echo "ERROR: '".@"."' not found!"
			return
		else
			execute '%s/\('.@".'\)/\1/gn'
		endif "}}}
endfunction "}}}

" Function key: <F1> "{{{4
" switch window
function! F1_Normal_Trans() "{{{
	nnoremap <buffer> <silent> <f1> :call SwitchWindow_Trans(3,1,2,3,'trans')<cr>
endfunction "}}}
" search glossary
function! F1_Visual_Trans() "{{{
	vnoremap <buffer> <silent> <f1> y:call SearchGlossary_Trans(3,3,'trans')<cr>
endfunction "}}}

function! F1_Trans() "{{{
	call F1_Normal_Trans()
	call F1_Visual_Trans()
endfunction "}}}
 "}}}4

" Function key: <F2> "{{{4
" same line
function! F2_Normal_Trans() "{{{
	nnoremap <buffer> <silent> <f2> :call SameLine_Trans(3,1,2,'trans')<cr>
endfunction "}}}

function! F2_Trans() "{{{
	call F2_Normal_Trans()
endfunction "}}}
 "}}}4

function! Translation() "{{{4
	let i=1
	while i<3
		execute substitute('call F0_Trans()',0,i,'')
		let i=i+1
	endwhile
endfunction "}}}4
 "}}}3

 "}}}2

" Vim settings "{{{2

set encoding=utf-8
set fileencoding=utf-8
set fileencodings=ucs-bom,utf-8,cp936,latin1

set nobomb
set nolinebreak
set hidden
syntax enable

set linespace=0
set display=lastline

" language
" change the name of 'lang' folder will force vim to use English

" window size
" windows | linux GUI | linux terminal
if CheckOS()=='windows' "{{{
	autocmd GUIEnter * simalt ~x
	set background=light
elseif CheckOS()=='linux'
	set lines=31
	set columns=123
	set background=dark
endif "}}}

if has('gui_running') "{{{
	colorscheme solarized
else
	colorscheme desert
endif "}}}

set laststatus=2
set ruler

" status line "{{{
" clear previous settings
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
" set statusline+=%1.4V]
 "}}}

set number
set showcmd
set wildmenu
set ambiwidth=double

set cmdheight=2
set history=99

" fonts
if CheckOS()=='windows' "{{{
	set guifont=Consolas:h15:cANSI
elseif CheckOS()=='linux'
	set guifont=DejaVu\ Sans\ \Mono\ 14
endif "}}}

set modelines=1
set backspace=indent,eol,start
set sessionoptions=buffers,folds,sesdir,slash,unix,winsize

" matchpairs
set matchpairs+=<:>
set matchpairs+=《:》
set matchpairs+=“:”
set matchpairs+=‘:’
set matchpairs+=（:）

" use both * and + registers when yanking in visual mode
" least GUI components
set guioptions=aP

set foldmethod=marker
set foldlevel=20

set ignorecase
set incsearch
set nosmartcase

set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab

set autoindent
set smartindent

" change directory
if CheckOS()=='windows' "{{{
	cd d:\Documents\
elseif CheckOS()=='linux'
	cd ~/documents/
endif "}}}
 "}}}2

" Key mappings and abbreviations "{{{2

" use function keys and commands instead of mapleader
" see below: '; and :'
set timeoutlen=0
let mapleader='\'

" switch case 
noremap ` ~
vnoremap ` ~

" set lines
nnoremap <silent> <c-down> :set lines+=1<cr>
nnoremap <silent> <c-up> :set lines-=1<cr>

" search backward
noremap , ?

" switch between windows
nnoremap <silent> <a-j> <c-w>w
nnoremap <silent> <a-k> <c-w>W

" save
nnoremap <silent> <cr> :wa<cr>

" open or close fold
nnoremap <space> za

" move to mark
noremap ' `

" modified 'Y'
noremap Y y$

" ';', ',' and ':'
noremap ; :
noremap <c-n> ;
noremap <a-n> ,

" gj and  gk
noremap <c-j> gj
noremap <c-k> gk

" move between paragraphs
noremap <c-h> {
noremap <c-l> }

" ^ and $
noremap 0 ^
noremap - $
noremap ^ 0

" jump between brackets
" noremap q %

" jump between marks
" seperate <c-i> between <tab>
nnoremap <a-o> <c-i>

" a-b substitution
nnoremap <silent> <a-q> :ABSubs<cr>
vnoremap <silent> <a-q> "by:ABSubs<cr>

" switch settings
nnoremap <silent> \ :SwBackground<cr>
nnoremap <silent> <c-\> :SwHlsearch<cr>
nnoremap <silent> \| :SwColorColumn<cr>
nnoremap <silent> <a-\> :SwLinebreak<cr>

" change fold level
nnoremap <silent> <a-=> :FlPlus<cr>
vnoremap <silent> <a-=> <esc>:FlVPlus<cr>
nnoremap <silent> <a--> :FlMinus<cr>
vnoremap <silent> <a--> <esc>:FlVMinus<cr>
nnoremap <silent> _ :FlDelNum<cr>
vnoremap <silent> _ <esc>:FlVDelNum<cr>
nnoremap <silent> + :FlAppNum<cr>
vnoremap <silent> + <esc>:FlVAppNum<cr>

" append, insert and creat fold marker
nnoremap <silent> <tab> :FmAfter<cr>
nnoremap <silent> <s-tab> :FmBefore<cr>
nnoremap <silent> <c-tab> :FmInside<cr>
nnoremap <silent> ~ :FmCreat<cr>
nnoremap <silent> Q :FmWrap<cr>
vnoremap <silent> Q <esc>:FmVWrap<cr>

" search visual selection
" forward, backward and yank match pattern
vnoremap <silent> <tab> y:SearchForward<cr>
vnoremap <silent> <s-tab> y:SearchYankAll<cr>
vnoremap <silent> <c-tab> y:SearchGrep<cr>:copen<cr>

" Scratch buffer
" edit
nnoremap <silent> <c-q> :ScrEdit<cr>
" substitute
nnoremap <silent> <backspace> :ScrSubs<cr>
vnoremap <silent> <backspace> y:ScrSubs<cr>
" append
nnoremap <silent> <s-backspace> :ScrAfter<cr>
vnoremap <silent> <s-backspace> y:ScrAfter<cr>
" insert
nnoremap <silent> <c-backspace> :ScrBefore<cr>
vnoremap <silent> <c-backspace> y:ScrBefore<cr>
" move
nnoremap <silent> <a-backspace> :ScrMove<cr>
vnoremap <silent> <a-backspace> zi<esc>:ScrVMove<cr>

" markdown link
inoremap <silent> <a-l> []()T[

" command range
inoremap <a-j> 'j,'k
cnoremap <a-j> 'j,'k
inoremap <a-k> 1,$
cnoremap <a-k> 1,$

 "}}}2

" User defined commands "{{{2

" update current time
" search 'http://vim.wikia.com' for help
" change language settings in windows
" 时钟、语言和区域——区域和语言——格式：英语（美国）
command! Date call TimeStamp()

" creat number
command! NumNoFold call CreatNumber(0)
command! NumFold call CreatNumber(1)

" delete empty lines {{{3

function s:DelLine(line) "{{{4

	call space#DelSpaceTrail()
	if a:line == 0
		call space#DelLine(0)
	elseif a:line == 1
		call space#DelLine(1)
	endif

endfunction "}}}4

command DelEmpty call <sid>DelLine(1)
command DelAdd call <sid>DelLine(0)

 "}}}3

" a-b substitution
command! ABSubs call SearchPattern(0)

" foward/backward search
command! SearchForward call SearchPattern(1)
command! SearchYankAll call SearchPattern(2)
command! SearchGrep call SearchPattern(3)

" Scratch buffer

" put text to Scratch
command! ScrAfter call ScratchBuffer(4)
command! ScrBefore call ScratchBuffer(3)
command! ScrSubs call ScratchBuffer(2)

" creat new Scratch
command! ScrCreat call ScratchBuffer(7)

" edit Scratch
command! ScrEdit call ScratchBuffer(1)

" move text between Scratch and other buffers
command! ScrMove call ScratchBuffer(5)
command! ScrVMove call ScratchBuffer(6)

" folds

" change fold level
command! FlMinus call ChangeFoldLevel(0)
command! FlVMinus call ChangeFoldLevel(1)
command! FlPlus call ChangeFoldLevel(2)
command! FlVPlus call ChangeFoldLevel(3)
command! FlDelNum call ChangeFoldLevel(4)
command! FlVDelNum call ChangeFoldLevel(5)
command! FlAppNum call ChangeFoldLevel(6)
command! FlVAppNum call ChangeFoldLevel(7)

" append, insert and creat fold marker
command! FmCreat call MoveFoldMarker(0)
command! FmAfter call MoveFoldMarker(1)
command! FmBefore call MoveFoldMarker(2)
command! FmInside call MoveFoldMarker(3)
command! FmWrap call MoveFoldMarker(4)
command! FmVWrap call MoveFoldMarker(5)

" switch settings
command SwHlsearch call SwitchSettings(0)
command SwLinebreak call SwitchSettings(1)
command SwBackground call SwitchSettings(2)
command SwModifiable call SwitchSettings(3)
command SwColorColumn call SwitchSettings(4)

" Chines word count

function s:CountChineseWord() "{{{

	if search('[^\x00-\xff]','n') == 0
		echo 'NOTE: Chinese words not found!'
		return
	else
		%s/[^\x00-\xff]//gn
	endif

endfunction "}}}

command Word call <sid>CountChineseWord()

" load key mappings
command! KeVocab call Vocabulary()
command! KeTranslation call Translation()

" edit files
command Ed0Vimrc e $MYVIMRC
command Ed1Achieve e ~/documents/achieve.daily|
\ cd ~/documents
command Ed2KeyMap e ~/.vim/plugin/keymap_tmp.vim

" autocommands
autocmd BufRead *.vocab call Vocabulary()
autocmd VimEnter * call ScratchBuffer(0)

let s:ColorColumn = '*.vim'
let s:ColorColumn .= ',*.vimrc'

execute 'autocmd BufRead,BufNewFile ' . s:ColorColumn .
\ ' setl tw=50'
execute 'autocmd BufRead,BufNewFile ' . s:ColorColumn .
\ ' setl colorcolumn=+0'
execute 'autocmd BufRead,BufNewFile ' . s:ColorColumn .
\ ' setl fo+=1mBj'

let g:AutoLoad_Bullet = '*.read'
let g:AutoLoad_Bullet .= ',*.write'
let g:AutoLoad_Bullet .= ',*.note'

let g:TextWidth_Bullet = 50

command BuP0TW Bullet p
command BuP1NoTW Bullet pn

command BuW0TW Bullet w
command BuW1NoTW Bullet wn

command BuE0Set Bullet s
command BuE1Bul Bullet b

autocmd BufRead achieve.daily setl comments=:*,:~
autocmd BufRead achieve.daily setl fo+=ro

let g:AutoLoad_Achieve = '*.daily'

function s:GotoSameLine() "{{{3

    let l:bufNr = bufnr('%')

    let l:cursor = getpos('.')

    call moveCursor#GotoColumn1('w0','str')
    let l:top = getpos('.')

    call setpos('.',l:cursor)

    wincmd w

    execute 'buffer' . ' ' . l:bufNr

    call setpos('.',l:top)
    execute 'normal zt'

    call setpos('.',l:cursor)

    wincmd W

endfunction "}}}3

command SameLine call <sid>GotoSameLine()

 "}}}2
" vim: set fdm=marker fdl=20: "}}}1
