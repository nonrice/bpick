if exists('g:loaded_bpick')
    finish
endif
let g:loaded_bpick = 1

let g:buf_list = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

function! s:idx_to_label(idx)
    return (a:idx == 9) ? '0' : string(a:idx + 1)
endfunction

function! s:label_to_idx(char)
    if a:char == '0'
        return 9
    elseif a:char =~# '^[1-9]$'
        return str2nr(a:char) - 1
    endif
    return -1
endfunction

function! s:format_name(buf_nr)
    if a:buf_nr == 0 || !bufexists(a:buf_nr)
        return 'EMPTY'
    endif
    let l:name = bufname(a:buf_nr)
    return empty(l:name) ? '[No Name]' : fnamemodify(l:name, ':t')
endfunction

function! s:is_special_buf(buf_nr)
    let l:type = getbufvar(a:buf_nr, '&buftype')
    let l:listed = getbufvar(a:buf_nr, '&buflisted')
    let l:name = bufname(a:buf_nr)

    return (l:type != '' || l:listed == 0 || empty(l:name))
endfunction

function! BPickPrint()
    redraw
    for i in range(5)
        let l:idx_left = i
        let l:idx_right = i+5

        let l:name_left = s:format_name(g:buf_list[idx_left])
        let l:name_right = s:format_name(g:buf_list[idx_right])

        let l:line = printf("%s -> %-12.12S | %s -> %-12.12S",
                    \ s:idx_to_label(l:idx_left), l:name_left,
                    \ s:idx_to_label(l:idx_right), l:name_right)
        echo l:line
    endfor
endfunction

function! BPick()
    call BPickPrint()
    let l:char = getcharstr()
    let l:idx = s:label_to_idx(l:char)

    if l:idx >= 0
        let l:buf = g:buf_list[l:idx]
        if l:buf != 0 && bufexists(l:buf)
            execute 'silent buffer ' . l:buf
            filetype detect
            redraw
        else
            redraw | echo "Slot empty."
        endif
    else
        redraw | echo "Cancelled."
    endif
endfunction

function! BPickSet()
    let l:cur_buf_nr = bufnr('%')

    if s:is_special_buf(cur_buf_nr)
        echo "Invalid buffer type."
        return
    endif

    call BPickPrint()
    let l:char = getcharstr()
    let l:target_idx = s:label_to_idx(l:char)

    if l:target_idx >= 0
        let l:existing_idx = index(g:buf_list, l:cur_buf_nr)

        if l:existing_idx != -1
            let l:temp = g:buf_list[l:target_idx]
            let g:buf_list[l:target_idx] = l:cur_buf_nr
            let g:buf_list[l:existing_idx] = l:temp
        else
            let g:buf_list[l:target_idx] = l:cur_buf_nr
        endif
    else
        redraw | echo "Cancelled."
    endif
endfunction

function! s:BPickAutoFill()
    let l:cur_buf_nr = str2nr(expand('<abuf>'))

    if s:is_special_buf(cur_buf_nr)
        echo "Invalid buffer type."
        return
    endif

    if index(g:buf_list, l:cur_buf_nr) != -1
        return
    endif

    for idx in range(10)
        let l:val = g:buf_list[idx]

        if l:val == 0
            let g:buf_list[idx] = l:cur_buf_nr
            return
        endif
    endfor
endfunction

function! s:BPickAutoDelete()
    let l:buf_nr = str2nr(expand('<abuf>'))
    let l:idx = index(g:buf_list, l:buf_nr)

    if l:idx != -1
        let g:buf_list[l:idx] = 0
    endif
endfunction

command! BPick call BPick()
command! BPickSet call BPickSet()

augroup BPickAuto 
    autocmd!
    autocmd BufReadPost,BufNewFile * call s:BPickAutoFill()
    autocmd BufDelete * call s:BPickAutoDelete()
augroup END
