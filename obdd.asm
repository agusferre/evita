extern free
extern malloc
extern is_constant
extern dictionary_add_entry

%define null 0

;nodo offset:
%define offset_var_ID 0
%define offset_node_ID 4
%define offset_ref_count 8
%define offset_high_obdd 12
%define offset_low_obdd 20
%define size_nodo 28

;mgr offset:
%define offset_ID 0
%define offset_greatest_node_ID 4
%define offset_greatest_var_ID 8
%define offset_true_obbd 12
%define offset_false_obbd 20
%define offset_vars_dict 28
%define size_mgr 36

;obdd offset:
%define offset_mgr 0 
%define offset_root 8
%define size_obdd 16

global obdd_mgr_mk_node

;rdi contiene puntero a mgr
;rsi contiene puntero a var
;rdx contiene puntero a high
;rcx contiene puntero a low
obdd_mgr_mk_node:
	push rbp
	mov rbp, rsp
	push rbx
	push r12
	push r13
	push r14
	push r15
	sub rsp, 8   		;cuanto????? /////////////////////////////////////////////////////////

	mov r12, rdi						;r12 contiene puntero a mgr
	mov r14, rdx						;r14 contiene puntero a high
	mov r15, rcx						;r15 contiene puntero a low

	mov rdi, [r12 + offset_vars_dict]
	call dictionary_add_entry
	mov rbx, rax						;rbx contiene uint32_t var_ID
	
	mov rdi, size_nodo
	call malloc
	mov r13, rax						;r13 contiene obdd_node* new_node

	mov [r13 + offset_var_ID], rbx		;new_node->var_ID = var_ID;
	mov rdi, r12						
	call obdd_mgr_get_next_node_ID
	mov [r13 + offset_node_ID], rax 	;new_node->node_ID = obdd_mgr_get_next_node_ID(mgr);

	mov [r13 + offset_high_obdd], r14	;new_node->high_obdd = high;

	cmp r14, null
	je .highNull
	add [r14 + offset_ref_count], 1  	;high->ref_count++;

.highNull
	mov [r13 + offset_low_obdd], r15	;new_node->low_obdd	= low;

	cmp r15, null
	je .lowNull
	add [r15 + offset_ref_count], 1

.lowNull
	mov [r13 + offset_ref_count], 0		;new_node->ref_count = 0;
	mov rax, r13

	add rsp, 8 ;/////////////////////////////////////////////////////////////////////////////
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbx
	pop rbp
	ret

global obdd_node_destroy
obdd_node_destroy:
ret

global obdd_create

;rdi contiene puntero a mgr
;rsi contiene puntero a root
obdd_create:
	push rbp
	mov rbp, rsp
	push r12
	push r13

	mov r12, [rdi]
	mov r13, [rsi]
	mov rdi, size_obdd
	call malloc   					;rax contiene puntero a new_obdd
	mov [rax + offset_mgr], r12		;new_obdd->mgr = mgr
	mov [rax + offset_root], r13	;new_obdd->root_obdd = root

	pop r13
	pop r12
	pop rbp
	ret

global obdd_destroy
obdd_destroy:
ret

global obdd_node_apply

;
obdd_node_apply:
ret

global is_tautology

;rdi contiene puntero a mgr
;rsi contiene puntero a root
is_tautology:
	push rbp
	mov rbp, rsp
	push r12
	push r13
	sub rsp, 8  ;//////////////////////////////////////////////
	
	mov r12, rdi
	mov r13, rsi
	call is_constant
	cmp rax, 0
	je .else 								

	mov rdi, r12
	mov rsi, r13
	call is_true
	jmp .end							;return is_true(mgr, root);

.else
	mov rdi, r12
	mov rsi, [r13 + offset_high_obdd]
	call is_tautology					;is_tautology(mgr, root->high_obdd)
	cmp rax, 0
	je .end

	mov rdi, r12
	mov rsi, [r13 + offset_low_obdd]
	call is_tautology					;is_tautology(mgr, root->low_obdd);

.end
	add rsp, 8
	pop r13
	pop r12
	pop rbp
	ret

global is_sat

;rdi contiene puntero a mgr
;rsi contiene puntero a root
is_sat:
	push rbp
	mov rbp, rsp
	push r12
	push r13
	sub rsp, 8  ;//////////////////////////////////////////////
	
	mov r12, rdi
	mov r13, rsi
	call is_constant
	cmp rax, 0
	je .else 								

	mov rdi, r12
	mov rsi, r13
	call is_true
	jmp .end							;return is_true(mgr, root);

.else
	mov rdi, r12
	mov rsi, [r13 + offset_high_obdd]
	call is_sat							;is_sat(mgr, root->high_obdd)
	cmp rax, 1
	je .end

	mov rdi, r12
	mov rsi, [r13 + offset_low_obdd]
	call is_sat							;is_sat(mgr, root->low_obdd);

.end
	add rsp, 8
	pop r13
	pop r12
	pop rbp
	ret

; AUXILIARES

global str_len
str_len:
ret

global str_copy
str_copy:
ret

global str_cmp
str_cmp:
ret
