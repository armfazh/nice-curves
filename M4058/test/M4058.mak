#+-----------------------------------------------------------------------------+
#| This code corresponds to the the paper "Nice curves" authored by            |
#| Kaushik Nath,  Indian Statistical Institute, Kolkata, India, and            |
#| Palash Sarkar, Indian Statistical Institute, Kolkata, India.	               |
#+-----------------------------------------------------------------------------+
#| Copyright (c) 2019, Kaushik Nath, Palash Sarkar.                            |
#|                                                                             |
#| Permission to use this code is granted.                          	       |
#|                                                                             |
#| Redistribution and use in source and binary forms, with or without          |
#| modification, are permitted provided that the following conditions are      |
#| met:                                                                        |
#|                                                                             |
#| * Redistributions of source code must retain the above copyright notice,    |
#|   this list of conditions and the following disclaimer.                     |
#|                                                                             |
#| * Redistributions in binary form must reproduce the above copyright         |
#|   notice, this list of conditions and the following disclaimer in the       |
#|   documentation and/or other materials provided with the distribution.      |
#|                                                                             |
#| * The names of the contributors may not be used to endorse or promote       |
#|   products derived from this software without specific prior written        |
#|   permission.                                                               |
#+-----------------------------------------------------------------------------+
#| THIS SOFTWARE IS PROVIDED BY THE AUTHORS ""AS IS"" AND ANY EXPRESS OR       |
#| IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES   |
#| OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.     |
#| IN NO EVENT SHALL THE CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,      |
#| INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT    |
#| NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,   |
#| DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY       |
#| THEORY LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING |
#| NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,| 
#| EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.                          |
#+-----------------------------------------------------------------------------+
#

INCDRS = -I../include/

SRCFLS = ../source/M4058_const.S 		\
	 ../source/M4058_ladder.S		\
	 ../source/gf_p44417_mul.S 		\
	 ../source/gf_p44417_nsqr.S 		\
	 ../source/gf_p44417_inv.c 		\
	 ../source/gf_p44417_makeunique.c 	\
	 ../source/M4058_smult.c		\
	 ../source/gf_p44417_pack.c		\
	  ./M4058_test.c
         
OBJFLS = ../source/M4058_const.o 		\
	 ../source/M4058_ladder.o		\
	 ../source/gf_p44417_mul.o 		\
	 ../source/gf_p44417_nsqr.o 		\
	 ../source/gf_p44417_inv.o 		\
	 ../source/gf_p44417_makeunique.o 	\
	 ../source/M4058_smult.o		\
	 ../source/gf_p44417_pack.o		\
	  ./M4058_test.o

EXE    = M4058_test

CFLAGS = -march=skylake -mtune=skylake -m64 -O3 -funroll-loops -fomit-frame-pointer

CC     = gcc
LL     = gcc

$(EXE): $(OBJFLS)
	$(LL) -o $@ $(OBJFLS) -lm

.c.o:
	$(CC) $(INCDRS) $(CFLAGS) -o $@ -c $<

clean:
	-rm $(EXE)
	-rm $(OBJFLS)
