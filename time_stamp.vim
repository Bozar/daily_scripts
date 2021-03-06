" time stamp "{{{1
" functions "{{{2
" 'Date:' and 'Last Update:'
" year (%Y) | month (%b) | day (%d) | weekday (%a)
" hour (%H) | miniute (%M) | second (%S)
function! TimeStamp_Origin(time,echo) "{{{
		let Date_Time="s/\\(Date: \\)\\@<=.*$/\\=strftime('%b %d | %a | %Y')/e"
		let Update_Time="s/\\(Last Update: \\)\\@<=.*$/\\=strftime('%b %d, %a | %H:%M:%S | %Y')/e"
		let String_Time='Last Update: '
		let SaveCursor=getpos('.')
		set nofoldenable
	" check lines
		if line('$')<3 "{{{
			call setpos('.', SaveCursor)
			set foldenable
			if a:echo==1
				echo 'ERROR: There should be at least 3 lines!'
			endif
			return
		endif "}}}
	" creat new date
		if a:time==0 "{{{
			s/$/\rLast Update: /
			execute Update_Time
			s/$/\rDate: /
			execute Date_Time
			"}}}
	" update time
		elseif a:time==1 "{{{
			1
			call search(String_Time,'c',3)
			if substitute(getline('.'),String_Time,'','')==getline('.')
				$-2
				call search('Last Update: ','c','$')
				if substitute(getline('.'),String_Time,'','')==getline('.')
					call setpos('.', SaveCursor)
					set foldenable
					if a:echo==1
						echo 'ERROR: Time stamp not found!'
					endif
					return
				endif
			endif
			execute '1,3'.Update_Time
			execute '$-2,$'.Update_Time
			call setpos('.', SaveCursor)
			if a:echo==1
				echo 'NOTE: Time stamp updated!'
			endif
		endif "}}}
		set foldenable
endfunction "}}}
 "}}}2

" commdands "{{{2
" update current time
" search 'http://vim.wikia.com' for help
" change language settings in windows
" 时钟、语言和区域——区域和语言——格式：英语（美国）

command! Time call TimeStamp_Origin(1,1)
"command! Date call TimeStamp(0,1)
" autocmd BufRead * call TimeStamp(1,0)
 "}}}2
 "}}}1
