/*
+-----------------------------------------------------------------------------+
| This code corresponds to the the paper "Nice curves" authored by	      |
| Kaushik Nath,  Indian Statistical Institute, Kolkata, India, and            |
| Palash Sarkar, Indian Statistical Institute, Kolkata, India.	              |
+-----------------------------------------------------------------------------+
| Copyright (c) 2019, Kaushik Nath and Palash Sarkar.                         |
|                                                                             |
| Permission to use this code is granted.                          	      |
|                                                                             |
| Redistribution and use in source and binary forms, with or without          |
| modification, are permitted provided that the following conditions are      |
| met:                                                                        |
|                                                                             |
| * Redistributions of source code must retain the above copyright notice,    |
|   this list of conditions and the following disclaimer.                     |
|                                                                             |
| * Redistributions in binary form must reproduce the above copyright         |
|   notice, this list of conditions and the following disclaimer in the       |
|   documentation and/or other materials provided with the distribution.      |
|                                                                             |
| * The names of the contributors may not be used to endorse or promote       |
|   products derived from this software without specific prior written        |
|   permission.                                                               |
+-----------------------------------------------------------------------------+
| THIS SOFTWARE IS PROVIDED BY THE AUTHORS ""AS IS"" AND ANY EXPRESS OR       |
| IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES   |
| OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.     |
| IN NO EVENT SHALL THE CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,      |
| INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT    |
| NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,   |
| DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY       |
| THEORY LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING |
| NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,|
| EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.                          |
+-----------------------------------------------------------------------------+
*/

// Montgomery ladder for the Montgomery curve M[4698]

.p2align 5
.globl M4698_ladder
M4698_ladder:

movq 	%rsp, %r11
subq 	$512, %rsp

movq 	%r11,  0(%rsp)
movq 	%r12,  8(%rsp)
movq 	%r13, 16(%rsp)
movq 	%r14, 24(%rsp)
movq 	%r15, 32(%rsp)
movq 	%rbx, 40(%rsp)
movq 	%rbp, 48(%rsp)
movq 	%rdi, 56(%rsp)

// X1: rsp(72)-rsp(96),
// X2: rsp(104)-rsp(128), Z2: rsp(136)-rsp(160),
// X3: rsp(168)-rsp(192), Z3: rsp(200)-rsp(224).

movq	0(%rsi), %r8
movq	%r8, 72(%rsp)
movq	%r8, 168(%rsp)
movq	8(%rsi), %r8
movq	%r8, 80(%rsp)
movq	%r8, 176(%rsp)
movq	16(%rsi), %r8
movq	%r8, 88(%rsp)
movq	%r8, 184(%rsp)
movq	24(%rsi), %r8
movq	%r8, 96(%rsp)
movq	%r8, 192(%rsp)  ; // X1 = XP, X3 = XP

movq	$1, 104(%rsp)
movq	$0, 112(%rsp)
movq	$0, 120(%rsp)
movq	$0, 128(%rsp) 	; // X2 = 1

movq	$0, 136(%rsp)
movq	$0, 144(%rsp)
movq	$0, 152(%rsp)
movq	$0, 160(%rsp)	; // Z2 = 0

movq	$1, 200(%rsp)
movq	$0, 208(%rsp)
movq	$0, 216(%rsp)
movq	$0, 224(%rsp)   ; // Z3 = 1

leaq	104(%rsp), %r11 ; // &X2
leaq	136(%rsp), %r12 ; // &Z2
leaq	168(%rsp), %r13 ; // &X3
leaq	200(%rsp), %r14 ; // &Z3

movq	%r11, 232(%rsp) ; // &X2
movq	%r12, 240(%rsp) ; // &Z2
movq	%r13, 248(%rsp) ; // &X3
movq	%r14, 256(%rsp) ; // &Z3

movq	%r13, 264(%rsp) ; // &X3
movq	%r14, 272(%rsp) ; // &Z3
movq	%r11, 280(%rsp) ; // &X2
movq	%r12, 288(%rsp) ; // &Z2

movq    $31, 304(%rsp)
movb	$2, 296(%rsp)
movq    %rdx, 64(%rsp)

movq    %rdx, %rax

// Montgomery ladder loop

.L1:
addq    304(%rsp), %rax
movb    0(%rax), %r14b
movb    %r14b, 298(%rsp)

.L2:
movb	296(%rsp), %cl
movb	298(%rsp), %bl
shrb    %cl, %bl
andb    $1, %bl    	;// %bl = bit

leaq    232(%rsp), %rdx
leaq    264(%rsp), %rax
cmpb    $1, %bl
cmove   %rax, %rdx
movq    %rdx, 504(%rsp)

/*
 * Montgomery ladder step
 *
 * T1 <- X2 + Z2
 * T2 <- X2 - Z2
 * T3 <- X3 + Z3
 * T4 <- X3 - Z3
 * T5 <- T1^2
 * T6 <- T2^2
 * T2 <- T2 · T3
 * T1 <- T1 · T4
 * T1 <- T1 + T2
 * T2 <- T1 - T2
 * X3 <- T1^2
 * T2 <- T2^2
 * Z3 <- T2 · X1
 * X2 <- T5 · T6
 * T5 <- T5 - T6
 * T1 <- ((A + 2)/4) · T5
 * T6 <- T6 + T1
 * Z2 <- T5 · T6
 *
 */

// X2
movq    0(%rdx),  %rcx

movq    0(%rcx),   %r8
movq    8(%rcx),   %r9
movq    16(%rcx), %r10
movq    24(%rcx), %r11

// copy X2
movq    %r8,  %rax
movq    %r9,  %rbx
movq    %r10, %rbp
movq    %r11, %rsi

// Z2
movq    8(%rdx),  %rcx

movq    0(%rcx),  %r12
movq    8(%rcx),  %r13
movq    16(%rcx), %r14
movq    24(%rcx), %r15

// T1 = X2 + Z2
addq    %r12,  %r8
adcq    %r13,  %r9
adcq    %r14, %r10
adcq    %r15, %r11

movq    %r8,  312(%rsp)
movq    %r9,  320(%rsp)
movq    %r10, 328(%rsp)
movq    %r11, 336(%rsp)

// T2 = X2 - Z2
addq    _4p0(%rip),  %rax
adcq    _4p12(%rip), %rbx
adcq    _4p12(%rip), %rbp
adcq    _4p3(%rip),  %rsi

subq    %r12, %rax
sbbq    %r13, %rbx
sbbq    %r14, %rbp
sbbq    %r15, %rsi

movq    %rax, 344(%rsp)
movq    %rbx, 352(%rsp)
movq    %rbp, 360(%rsp)
movq    %rsi, 368(%rsp)

// X3
movq    16(%rdx), %rcx

movq    0(%rcx),   %r8
movq    8(%rcx),   %r9
movq    16(%rcx), %r10
movq    24(%rcx), %r11

// copy X3
movq    %r8,  %rax
movq    %r9,  %rbx
movq    %r10, %rbp
movq    %r11, %rsi

// Z3
movq    24(%rdx), %rcx

movq    0(%rcx),  %r12
movq    8(%rcx),  %r13
movq    16(%rcx), %r14
movq    24(%rcx), %r15

// T3 = X3 + Z3
addq    %r12,  %r8
adcq    %r13,  %r9
adcq    %r14, %r10
adcq    %r15, %r11

movq    %r8,  376(%rsp)
movq    %r9,  384(%rsp)
movq    %r10, 392(%rsp)
movq    %r11, 400(%rsp)

// T4 = X3 - Z3
addq    _4p0(%rip),  %rax
adcq    _4p12(%rip), %rbx
adcq    _4p12(%rip), %rbp
adcq    _4p3(%rip),  %rsi

subq    %r12, %rax
sbbq    %r13, %rbx
sbbq    %r14, %rbp
sbbq    %r15, %rsi

movq    %rax, 408(%rsp)
movq    %rbx, 416(%rsp)
movq    %rbp, 424(%rsp)
movq    %rsi, 432(%rsp)

// T5 = T1^2
xorq    %r13, %r13
movq    312(%rsp), %rdx

mulx    320(%rsp), %r9, %r10

mulx    328(%rsp), %rcx, %r11
adcx    %rcx, %r10

mulx    336(%rsp), %rcx, %r12
adcx    %rcx, %r11
adcx    %r13, %r12

movq    320(%rsp), %rdx
xorq    %r14, %r14

mulx    328(%rsp), %rcx, %rdi
adcx    %rcx, %r11
adox    %rdi, %r12

mulx    336(%rsp), %rcx, %rdi
adcx    %rcx, %r12
adox    %rdi, %r13
adcx    %r14, %r13

xorq    %r15, %r15
movq    328(%rsp), %rdx

mulx    336(%rsp), %rcx, %r14
adcx    %rcx, %r13
adcx    %r15, %r14

shld    $1, %r14, %r15
shld    $1, %r13, %r14
shld    $1, %r12, %r13
shld    $1, %r11, %r12
shld    $1, %r10, %r11
shld    $1, %r9, %r10
shlq    $1, %r9

xorq    %rdx, %rdx
movq    312(%rsp), %rdx
mulx    %rdx, %r8, %rdx
adcx    %rdx, %r9

movq    320(%rsp), %rdx
mulx    %rdx, %rcx, %rdx
adcx    %rcx, %r10
adcx    %rdx, %r11

movq    328(%rsp), %rdx
mulx    %rdx, %rcx, %rdx
adcx    %rcx, %r12
adcx    %rdx, %r13

movq    336(%rsp), %rdx
mulx    %rdx, %rcx, %rdx
adcx    %rcx, %r14
adcx    %rdx, %r15

xorq    %rbp, %rbp
movq    $288, %rdx

mulx    %r12, %rbx, %rbp
adcx    %r8, %rbx
adox    %r9, %rbp

mulx    %r13, %rcx, %rax
adcx    %rcx, %rbp
adox    %r10, %rax

mulx    %r14, %rcx, %rsi
adcx    %rcx, %rax
adox    %r11, %rsi

mulx    %r15, %rcx, %r15
adcx    %rcx, %rsi
adox    zero(%rip), %r15
adcx    zero(%rip), %r15

shld    $5, %rsi, %r15
andq    mask59(%rip), %rsi

imul    $9, %r15, %r15
addq    %r15, %rbx
adcq    $0, %rbp
adcq    $0, %rax
adcq    $0, %rsi

movq    %rbx, 440(%rsp)
movq    %rbp, 448(%rsp)
movq    %rax, 456(%rsp)
movq    %rsi, 464(%rsp)

// T6 = T2^2
xorq    %r13, %r13
movq    344(%rsp), %rdx

mulx    352(%rsp), %r9, %r10

mulx    360(%rsp), %rcx, %r11
adcx    %rcx, %r10

mulx    368(%rsp), %rcx, %r12
adcx    %rcx, %r11
adcx    %r13, %r12

movq    352(%rsp), %rdx
xorq    %r14, %r14

mulx    360(%rsp), %rcx, %rdi
adcx    %rcx, %r11
adox    %rdi, %r12

mulx    368(%rsp), %rcx, %rdi
adcx    %rcx, %r12
adox    %rdi, %r13
adcx    %r14, %r13

xorq    %r15, %r15
movq    360(%rsp), %rdx

mulx    368(%rsp), %rcx, %r14
adcx    %rcx, %r13
adcx    %r15, %r14

shld    $1, %r14, %r15
shld    $1, %r13, %r14
shld    $1, %r12, %r13
shld    $1, %r11, %r12
shld    $1, %r10, %r11
shld    $1, %r9, %r10
shlq    $1, %r9

xorq    %rdx, %rdx
movq    344(%rsp), %rdx
mulx    %rdx, %r8, %rdx
adcx    %rdx, %r9

movq    352(%rsp), %rdx
mulx    %rdx, %rcx, %rdx
adcx    %rcx, %r10
adcx    %rdx, %r11

movq    360(%rsp), %rdx
mulx    %rdx, %rcx, %rdx
adcx    %rcx, %r12
adcx    %rdx, %r13

movq    368(%rsp), %rdx
mulx    %rdx, %rcx, %rdx
adcx    %rcx, %r14
adcx    %rdx, %r15

xorq    %rbp, %rbp
movq    $288, %rdx

mulx    %r12, %rbx, %rbp
adcx    %r8, %rbx
adox    %r9, %rbp

mulx    %r13, %rcx, %rax
adcx    %rcx, %rbp
adox    %r10, %rax

mulx    %r14, %rcx, %rsi
adcx    %rcx, %rax
adox    %r11, %rsi

mulx    %r15, %rcx, %r15
adcx    %rcx, %rsi
adox    zero(%rip), %r15
adcx    zero(%rip), %r15

shld    $5, %rsi, %r15
andq    mask59(%rip), %rsi

imul    $9, %r15, %r15
addq    %r15, %rbx
adcq    $0, %rbp
adcq    $0, %rax
adcq    $0, %rsi

movq    %rbx, 472(%rsp)
movq    %rbp, 480(%rsp)
movq    %rax, 488(%rsp)
movq    %rsi, 496(%rsp)

// T2 = T2 · T3
xorq    %r13, %r13
movq    344(%rsp), %rdx

mulx    376(%rsp), %r8, %r9
mulx    384(%rsp), %rcx, %r10
adcx    %rcx, %r9

mulx    392(%rsp), %rcx, %r11
adcx    %rcx, %r10

mulx    400(%rsp), %rcx, %r12
adcx    %rcx, %r11
adcx    %r13, %r12

xorq    %r14, %r14
movq    352(%rsp), %rdx

mulx    376(%rsp), %rcx, %rbp
adcx    %rcx, %r9
adox    %rbp, %r10

mulx    384(%rsp), %rcx, %rbp
adcx    %rcx, %r10
adox    %rbp, %r11

mulx    392(%rsp), %rcx, %rbp
adcx    %rcx, %r11
adox    %rbp, %r12

mulx    400(%rsp), %rcx, %rbp
adcx    %rcx, %r12
adox    %rbp, %r13
adcx    %r14, %r13

xorq    %r15, %r15
movq    360(%rsp), %rdx

mulx    376(%rsp), %rcx, %rbp
adcx    %rcx, %r10
adox    %rbp, %r11

mulx    384(%rsp), %rcx, %rbp
adcx    %rcx, %r11
adox    %rbp, %r12

mulx    392(%rsp), %rcx, %rbp
adcx    %rcx, %r12
adox    %rbp, %r13

mulx    400(%rsp), %rcx, %rbp
adcx    %rcx, %r13
adox    %rbp, %r14
adcx    %r15, %r14

xorq    %rax, %rax
movq    368(%rsp), %rdx

mulx    376(%rsp), %rcx, %rbp
adcx    %rcx, %r11
adox    %rbp, %r12

mulx    384(%rsp), %rcx, %rbp
adcx    %rcx, %r12
adox    %rbp, %r13

mulx    392(%rsp), %rcx, %rbp
adcx    %rcx, %r13
adox    %rbp, %r14

mulx    400(%rsp), %rcx, %rbp
adcx    %rcx, %r14
adox    %rbp, %r15
adcx    %rax, %r15

xorq    %rbp, %rbp
movq    $288, %rdx

mulx    %r12, %rax, %r12
adcx    %rax, %r8
adox    %r12, %r9

mulx    %r13, %rcx, %r13
adcx    %rcx, %r9
adox    %r13, %r10

mulx    %r14, %rcx, %r14
adcx    %rcx, %r10
adox    %r14, %r11

mulx    %r15, %rcx, %r15
adcx    %rcx, %r11
adox    zero(%rip), %r15
adcx    zero(%rip), %r15

shld    $5, %r11, %r15
andq    mask59(%rip), %r11

imul    $9, %r15, %r15
addq    %r15, %r8
adcq    $0, %r9
adcq    $0, %r10
adcq    $0, %r11

movq    %r8,  344(%rsp)
movq    %r9,  352(%rsp)
movq    %r10, 360(%rsp)
movq    %r11, 368(%rsp)

// T1 = T1 · T4
xorq    %r13, %r13
movq    312(%rsp), %rdx

mulx    408(%rsp), %r8, %r9
mulx    416(%rsp), %rcx, %r10
adcx    %rcx, %r9

mulx    424(%rsp), %rcx, %r11
adcx    %rcx, %r10

mulx    432(%rsp), %rcx, %r12
adcx    %rcx, %r11
adcx    %r13, %r12

xorq    %r14, %r14
movq    320(%rsp), %rdx

mulx    408(%rsp), %rcx, %rbp
adcx    %rcx, %r9
adox    %rbp, %r10

mulx    416(%rsp), %rcx, %rbp
adcx    %rcx, %r10
adox    %rbp, %r11

mulx    424(%rsp), %rcx, %rbp
adcx    %rcx, %r11
adox    %rbp, %r12

mulx    432(%rsp), %rcx, %rbp
adcx    %rcx, %r12
adox    %rbp, %r13
adcx    %r14, %r13

xorq    %r15, %r15
movq    328(%rsp), %rdx

mulx    408(%rsp), %rcx, %rbp
adcx    %rcx, %r10
adox    %rbp, %r11

mulx    416(%rsp), %rcx, %rbp
adcx    %rcx, %r11
adox    %rbp, %r12

mulx    424(%rsp), %rcx, %rbp
adcx    %rcx, %r12
adox    %rbp, %r13

mulx    432(%rsp), %rcx, %rbp
adcx    %rcx, %r13
adox    %rbp, %r14
adcx    %r15, %r14

xorq    %rax, %rax
movq    336(%rsp), %rdx

mulx    408(%rsp), %rcx, %rbp
adcx    %rcx, %r11
adox    %rbp, %r12

mulx    416(%rsp), %rcx, %rbp
adcx    %rcx, %r12
adox    %rbp, %r13

mulx    424(%rsp), %rcx, %rbp
adcx    %rcx, %r13
adox    %rbp, %r14

mulx    432(%rsp), %rcx, %rbp
adcx    %rcx, %r14
adox    %rbp, %r15
adcx    %rax, %r15

xorq    %rbp, %rbp
movq    $288, %rdx

mulx    %r12, %rax, %r12
adcx    %rax, %r8
adox    %r12, %r9

mulx    %r13, %rcx, %r13
adcx    %rcx, %r9
adox    %r13, %r10

mulx    %r14, %rcx, %r14
adcx    %rcx, %r10
adox    %r14, %r11

mulx    %r15, %rcx, %r15
adcx    %rcx, %r11
adox    zero(%rip), %r15
adcx    zero(%rip), %r15

shld    $5, %r11, %r15
andq    mask59(%rip), %r11

imul    $9, %r15, %r15
addq    %r15, %r8
adcq    $0, %r9
adcq    $0, %r10
adcq    $0, %r11

// copy T1
movq    %r8,  %r12
movq    %r9,  %r13
movq    %r10, %r14
movq    %r11, %r15

// T1 = T1 + T2
addq    344(%rsp),  %r8
adcq    352(%rsp),  %r9
adcq    360(%rsp), %r10
adcq    368(%rsp), %r11

movq    %r8,  312(%rsp)
movq    %r9,  320(%rsp)
movq    %r10, 328(%rsp)
movq    %r11, 336(%rsp)

// T2 = T1 - T2
addq    _4p0(%rip),  %r12
adcq    _4p12(%rip), %r13
adcq    _4p12(%rip), %r14
adcq    _4p3(%rip),  %r15

subq    344(%rsp), %r12
sbbq    352(%rsp), %r13
sbbq    360(%rsp), %r14
sbbq    368(%rsp), %r15

movq    %r12, 344(%rsp)
movq    %r13, 352(%rsp)
movq    %r14, 360(%rsp)
movq    %r15, 368(%rsp)

// X3 = T1^2
xorq    %r13, %r13
movq    312(%rsp), %rdx

mulx    320(%rsp), %r9, %r10

mulx    328(%rsp), %rcx, %r11
adcx    %rcx, %r10

mulx    336(%rsp), %rcx, %r12
adcx    %rcx, %r11
adcx    %r13, %r12

movq    320(%rsp), %rdx
xorq    %r14, %r14

mulx    328(%rsp), %rcx, %rdi
adcx    %rcx, %r11
adox    %rdi, %r12

mulx    336(%rsp), %rcx, %rdi
adcx    %rcx, %r12
adox    %rdi, %r13
adcx    %r14, %r13

xorq    %r15, %r15
movq    328(%rsp), %rdx

mulx    336(%rsp), %rcx, %r14
adcx    %rcx, %r13
adcx    %r15, %r14

shld    $1, %r14, %r15
shld    $1, %r13, %r14
shld    $1, %r12, %r13
shld    $1, %r11, %r12
shld    $1, %r10, %r11
shld    $1, %r9, %r10
shlq    $1, %r9

xorq    %rdx, %rdx
movq    312(%rsp), %rdx
mulx    %rdx, %r8, %rdx
adcx    %rdx, %r9

movq    320(%rsp), %rdx
mulx    %rdx, %rcx, %rdx
adcx    %rcx, %r10
adcx    %rdx, %r11

movq    328(%rsp), %rdx
mulx    %rdx, %rcx, %rdx
adcx    %rcx, %r12
adcx    %rdx, %r13

movq    336(%rsp), %rdx
mulx    %rdx, %rcx, %rdx
adcx    %rcx, %r14
adcx    %rdx, %r15

xorq    %rbp, %rbp
movq    $288, %rdx

mulx    %r12, %rbx, %rbp
adcx    %r8, %rbx
adox    %r9, %rbp

mulx    %r13, %rcx, %rax
adcx    %rcx, %rbp
adox    %r10, %rax

mulx    %r14, %rcx, %rsi
adcx    %rcx, %rax
adox    %r11, %rsi

mulx    %r15, %rcx, %r15
adcx    %rcx, %rsi
adox    zero(%rip), %r15
adcx    zero(%rip), %r15

shld    $5, %rsi, %r15
andq    mask59(%rip), %rsi

imul    $9, %r15, %r15
addq    %r15, %rbx
adcq    $0, %rbp
adcq    $0, %rax
adcq    $0, %rsi

movq    504(%rsp), %rdx
movq    16(%rdx), %rcx

movq    %rbx,  0(%rcx); // update X3
movq    %rbp,  8(%rcx)
movq    %rax, 16(%rcx)
movq    %rsi, 24(%rcx)

// T2 = T2^2
xorq    %r13, %r13
movq    344(%rsp), %rdx

mulx    352(%rsp), %r9, %r10

mulx    360(%rsp), %rcx, %r11
adcx    %rcx, %r10

mulx    368(%rsp), %rcx, %r12
adcx    %rcx, %r11
adcx    %r13, %r12

movq    352(%rsp), %rdx
xorq    %r14, %r14

mulx    360(%rsp), %rcx, %rdi
adcx    %rcx, %r11
adox    %rdi, %r12

mulx    368(%rsp), %rcx, %rdi
adcx    %rcx, %r12
adox    %rdi, %r13
adcx    %r14, %r13

xorq    %r15, %r15
movq    360(%rsp), %rdx

mulx    368(%rsp), %rcx, %r14
adcx    %rcx, %r13
adcx    %r15, %r14

shld    $1, %r14, %r15
shld    $1, %r13, %r14
shld    $1, %r12, %r13
shld    $1, %r11, %r12
shld    $1, %r10, %r11
shld    $1, %r9, %r10
shlq    $1, %r9

xorq    %rdx, %rdx
movq    344(%rsp), %rdx
mulx    %rdx, %r8, %rdx
adcx    %rdx, %r9

movq    352(%rsp), %rdx
mulx    %rdx, %rcx, %rdx
adcx    %rcx, %r10
adcx    %rdx, %r11

movq    360(%rsp), %rdx
mulx    %rdx, %rcx, %rdx
adcx    %rcx, %r12
adcx    %rdx, %r13

movq    368(%rsp), %rdx
mulx    %rdx, %rcx, %rdx
adcx    %rcx, %r14
adcx    %rdx, %r15

xorq    %rbp, %rbp
movq    $288, %rdx

mulx    %r12, %rbx, %rbp
adcx    %r8, %rbx
adox    %r9, %rbp

mulx    %r13, %rcx, %rax
adcx    %rcx, %rbp
adox    %r10, %rax

mulx    %r14, %rcx, %rsi
adcx    %rcx, %rax
adox    %r11, %rsi

mulx    %r15, %rcx, %r15
adcx    %rcx, %rsi
adox    zero(%rip), %r15
adcx    zero(%rip), %r15

shld    $5, %rsi, %r15
andq    mask59(%rip), %rsi

imul    $9, %r15, %r15
addq    %r15, %rbx
adcq    $0, %rbp
adcq    $0, %rax
adcq    $0, %rsi

// Z3 = T2 · X1
xorq    %r13, %r13
movq    72(%rsp), %rdx

mulx    %rbx, %r8, %r9
mulx    %rbp, %rcx, %r10
adcx    %rcx, %r9

mulx    %rax, %rcx, %r11
adcx    %rcx, %r10

mulx    %rsi, %rcx, %r12
adcx    %rcx, %r11
adcx    %r13, %r12

xorq    %r14, %r14
movq    80(%rsp), %rdx

mulx    %rbx, %rcx, %rdi
adcx    %rcx, %r9
adox    %rdi, %r10

mulx    %rbp, %rcx, %rdi
adcx    %rcx, %r10
adox    %rdi, %r11

mulx    %rax, %rcx, %rdi
adcx    %rcx, %r11
adox    %rdi, %r12

mulx    %rsi, %rcx, %rdi
adcx    %rcx, %r12
adox    %rdi, %r13
adcx    %r14, %r13

xorq    %r15, %r15
movq    88(%rsp), %rdx

mulx    %rbx, %rcx, %rdi
adcx    %rcx, %r10
adox    %rdi, %r11

mulx    %rbp, %rcx, %rdi
adcx    %rcx, %r11
adox    %rdi, %r12

mulx    %rax, %rcx, %rdi
adcx    %rcx, %r12
adox    %rdi, %r13

mulx    %rsi, %rcx, %rdi
adcx    %rcx, %r13
adox    %rdi, %r14
adcx    %r15, %r14

movq    96(%rsp), %rdx

mulx    %rbx, %rcx, %rdi
adcx    %rcx, %r11
adox    %rdi, %r12

mulx    %rbp, %rcx, %rdi
adcx    %rcx, %r12
adox    %rdi, %r13

mulx    %rax, %rcx, %rdi
adcx    %rcx, %r13
adox    %rdi, %r14

mulx    %rsi, %rcx, %rdi
adcx    %rcx, %r14
adox    %rdi, %r15
adcq    $0, %r15

xorq    %rbp, %rbp
movq    $288, %rdx

mulx    %r12, %rax, %r12
adcx    %rax, %r8
adox    %r12, %r9

mulx    %r13, %rcx, %r13
adcx    %rcx, %r9
adox    %r13, %r10

mulx    %r14, %rcx, %r14
adcx    %rcx, %r10
adox    %r14, %r11

mulx    %r15, %rcx, %r15
adcx    %rcx, %r11
adox    zero(%rip), %r15
adcx    zero(%rip), %r15

shld    $5, %r11, %r15
andq    mask59(%rip), %r11

imul    $9, %r15, %r15
addq    %r15, %r8
adcq    $0, %r9
adcq    $0, %r10
adcq    $0, %r11

movq    504(%rsp), %rdx
movq    24(%rdx), %rcx

movq    %r8,   0(%rcx); // update Z3
movq    %r9,   8(%rcx)
movq    %r10, 16(%rcx)
movq    %r11, 24(%rcx)

// X2 = T5 · T6
xorq    %r13, %r13
movq    440(%rsp), %rdx

mulx    472(%rsp), %r8, %r9
mulx    480(%rsp), %rcx, %r10
adcx    %rcx, %r9

mulx    488(%rsp), %rcx, %r11
adcx    %rcx, %r10

mulx    496(%rsp), %rcx, %r12
adcx    %rcx, %r11
adcx    %r13, %r12

xorq    %r14, %r14
movq    448(%rsp), %rdx

mulx    472(%rsp), %rcx, %rbp
adcx    %rcx, %r9
adox    %rbp, %r10

mulx    480(%rsp), %rcx, %rbp
adcx    %rcx, %r10
adox    %rbp, %r11

mulx    488(%rsp), %rcx, %rbp
adcx    %rcx, %r11
adox    %rbp, %r12

mulx    496(%rsp), %rcx, %rbp
adcx    %rcx, %r12
adox    %rbp, %r13
adcx    %r14, %r13

xorq    %r15, %r15
movq    456(%rsp), %rdx

mulx    472(%rsp), %rcx, %rbp
adcx    %rcx, %r10
adox    %rbp, %r11

mulx    480(%rsp), %rcx, %rbp
adcx    %rcx, %r11
adox    %rbp, %r12

mulx    488(%rsp), %rcx, %rbp
adcx    %rcx, %r12
adox    %rbp, %r13

mulx    496(%rsp), %rcx, %rbp
adcx    %rcx, %r13
adox    %rbp, %r14
adcx    %r15, %r14

xorq    %rax, %rax
movq    464(%rsp), %rdx

mulx    472(%rsp), %rcx, %rbp
adcx    %rcx, %r11
adox    %rbp, %r12

mulx    480(%rsp), %rcx, %rbp
adcx    %rcx, %r12
adox    %rbp, %r13

mulx    488(%rsp), %rcx, %rbp
adcx    %rcx, %r13
adox    %rbp, %r14

mulx    496(%rsp), %rcx, %rbp
adcx    %rcx, %r14
adox    %rbp, %r15
adcx    %rax, %r15

xorq    %rbp, %rbp
movq    $288, %rdx

mulx    %r12, %rax, %r12
adcx    %rax, %r8
adox    %r12, %r9

mulx    %r13, %rcx, %r13
adcx    %rcx, %r9
adox    %r13, %r10

mulx    %r14, %rcx, %r14
adcx    %rcx, %r10
adox    %r14, %r11

mulx    %r15, %rcx, %r15
adcx    %rcx, %r11
adox    zero(%rip), %r15
adcx    zero(%rip), %r15

shld    $5, %r11, %r15
andq    mask59(%rip), %r11

imul    $9, %r15, %r15
addq    %r15, %r8
adcq    $0, %r9
adcq    $0, %r10
adcq    $0, %r11

movq    504(%rsp), %rdx
movq    0(%rdx), %rcx

movq    %r8,   0(%rcx); // update X2
movq    %r9,   8(%rcx)
movq    %r10, 16(%rcx)
movq    %r11, 24(%rcx)

// T5 = T5 - T6
movq    440(%rsp), %rbx
movq    448(%rsp), %rbp
movq    456(%rsp), %rax
movq    464(%rsp), %rsi

addq    _4p0(%rip),  %rbx
adcq    _4p12(%rip), %rbp
adcq    _4p12(%rip), %rax
adcq    _4p3(%rip),  %rsi

subq    472(%rsp), %rbx
sbbq    480(%rsp), %rbp
sbbq    488(%rsp), %rax
sbbq    496(%rsp), %rsi

movq    %rbx, 440(%rsp)
movq    %rbp, 448(%rsp)
movq    %rax, 456(%rsp)
movq    %rsi, 464(%rsp)

// T1 <- ((A + 2)/4) · T5
xorq    %r13, %r13
movq    a24(%rip), %rdx

mulx    %rbx, %rbx, %r9
mulx    %rbp, %rbp, %r10
adcx    %r9, %rbp

mulx    %rax, %rax, %r9
adcx    %r10, %rax

mulx    %rsi, %rsi, %r10
adcx    %r9, %rsi
adcx    %r13, %r10

shld    $5, %rsi, %r10
andq    mask59(%rip), %rsi

imul    $9, %r10, %r10
addq    %r10, %rbx
adcq    $0, %rbp
adcq    $0, %rax
adcq    $0, %rsi

// T6 = T6 + T1
addq    472(%rsp), %rbx
adcq    480(%rsp), %rbp
adcq    488(%rsp), %rax
adcq    496(%rsp), %rsi

// Z2 = T5 · T6
xorq    %r13, %r13
movq    440(%rsp), %rdx

mulx    %rbx, %r8, %r9
mulx    %rbp, %rcx, %r10
adcx    %rcx, %r9

mulx    %rax, %rcx, %r11
adcx    %rcx, %r10

mulx    %rsi, %rcx, %r12
adcx    %rcx, %r11
adcx    %r13, %r12

xorq    %r14, %r14
movq    448(%rsp), %rdx

mulx    %rbx, %rcx, %rdi
adcx    %rcx, %r9
adox    %rdi, %r10

mulx    %rbp, %rcx, %rdi
adcx    %rcx, %r10
adox    %rdi, %r11

mulx    %rax, %rcx, %rdi
adcx    %rcx, %r11
adox    %rdi, %r12

mulx    %rsi, %rcx, %rdi
adcx    %rcx, %r12
adox    %rdi, %r13
adcx    %r14, %r13

xorq    %r15, %r15
movq    456(%rsp), %rdx

mulx    %rbx, %rcx, %rdi
adcx    %rcx, %r10
adox    %rdi, %r11

mulx    %rbp, %rcx, %rdi
adcx    %rcx, %r11
adox    %rdi, %r12

mulx    %rax, %rcx, %rdi
adcx    %rcx, %r12
adox    %rdi, %r13

mulx    %rsi, %rcx, %rdi
adcx    %rcx, %r13
adox    %rdi, %r14
adcx    %r15, %r14

movq    464(%rsp), %rdx

mulx    %rbx, %rcx, %rdi
adcx    %rcx, %r11
adox    %rdi, %r12

mulx    %rbp, %rcx, %rdi
adcx    %rcx, %r12
adox    %rdi, %r13

mulx    %rax, %rcx, %rdi
adcx    %rcx, %r13
adox    %rdi, %r14

mulx    %rsi, %rcx, %rdi
adcx    %rcx, %r14
adox    %rdi, %r15
adcq    $0, %r15

xorq    %rbp, %rbp
movq    $288, %rdx

mulx    %r12, %rax, %r12
adcx    %rax, %r8
adox    %r12, %r9

mulx    %r13, %rcx, %r13
adcx    %rcx, %r9
adox    %r13, %r10

mulx    %r14, %rcx, %r14
adcx    %rcx, %r10
adox    %r14, %r11

mulx    %r15, %rcx, %r15
adcx    %rcx, %r11
adox    zero(%rip), %r15
adcx    zero(%rip), %r15

shld    $5, %r11, %r15
andq    mask59(%rip), %r11

imul    $9, %r15, %r15
addq    %r15, %r8
adcq    $0, %r9
adcq    $0, %r10
adcq    $0, %r11

movq    504(%rsp), %rdx
movq    8(%rdx), %rcx

movq    %r8,   0(%rcx); // update Z2
movq    %r9,   8(%rcx)
movq    %r10, 16(%rcx)
movq    %r11, 24(%rcx)

movb    296(%rsp), %cl
subb    $1, %cl
movb    %cl, 296(%rsp)
cmpb	$0, %cl
jge     .L2

movb    $7, 296(%rsp)
movq    64(%rsp), %rax
movq    304(%rsp), %r15
subq    $1, %r15
movq    %r15, 304(%rsp)
cmpq	$0, %r15
jge     .L1

movq    56(%rsp), %rdi

movq    504(%rsp), %rdx
movq    0(%rdx), %rcx

movq     0(%rcx), %r8
movq     8(%rcx), %r9
movq    16(%rcx), %r10
movq    24(%rcx), %r11

movq    %r8,   0(%rdi); // final value of X2
movq    %r9,   8(%rdi)
movq    %r10, 16(%rdi)
movq    %r11, 24(%rdi)

movq    8(%rdx), %rcx

movq     0(%rcx), %r8
movq     8(%rcx), %r9
movq    16(%rcx), %r10
movq    24(%rcx), %r11

movq    %r8,  32(%rdi); // final value of Z2
movq    %r9,  40(%rdi)
movq    %r10, 48(%rdi)
movq    %r11, 56(%rdi)

movq 	 0(%rsp), %r11
movq 	 8(%rsp), %r12
movq 	16(%rsp), %r13
movq 	24(%rsp), %r14
movq 	32(%rsp), %r15
movq 	40(%rsp), %rbx
movq 	48(%rsp), %rbp

movq 	%r11, %rsp

ret