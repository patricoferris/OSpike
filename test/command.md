# Simple instruction counting 
```sh
$ cat test.txt | ospike stdin 
(sd): 29
(addi): 7
(ld): 4
(bltu): 2
(addiw): 2
(Unknown Instruction): 2
(lui): 2
(ret): 2
(mv): 2
(bnez): 1
(csrrw): 1

Total Number of Instructions: 54
```

```sh
$ cat test.txt | ospike stdin -impl string
(sd): 29
(addi): 7
(ld): 4
(bltu): 2
(addiw): 2
(Unknown Instruction): 2
(lui): 2
(ret): 2
(mv): 2
(bnez): 1
(csrrw): 1

Total Number of Instructions: 54
```

# Instructions with their registers
```sh
$ cat test.txt | ospike stdin -compare instr_reg 
(sd a0 8(a7) none): 2
(ld ra 40(sp) none): 2
(Unknown Instruction none none none): 2
(addi a7 s10  8): 2
(lui s2 0x1 none): 2
(addi s10 s10  -24): 2
(addi sp sp  48): 2
(sd s2 none -8(a7)): 2
(addiw s2 s2  -2048): 2
(sd s7 0(a7) none): 2
(mv a0 a7 none): 2
(ld s7 24(sp) none): 2
(ret none none none): 2
(bltu s10 s11  pc ): 2
(sd a1 88(sp) none): 1
(sd a2 96(sp) none): 1
(csrrw sp sscratch  sp): 1
(sd gp 24(sp) none): 1
(sd a7 136(sp) none): 1
(sd a6 128(sp) none): 1
(sd t0 40(sp) none): 1
(sd a3 104(sp) none): 1
(sd tp 32(sp) none): 1
(sd ra 8(sp) none): 1
(sd s7 184(sp) none): 1
(sd t2 56(sp) none): 1
(sd s3 152(sp) none): 1
(sd a4 112(sp) none): 1
(sd s5 168(sp) none): 1
(addi sp sp  -320): 1
(sd a0 80(sp) none): 1
(sd t1 48(sp) none): 1
(sd s6 176(sp) none): 1
(sd s1 72(sp) none): 1
(bnez sp pc  none): 1
(sd s8 192(sp) none): 1
(sd s0 64(sp) none): 1
(sd a5 120(sp) none): 1
(sd s4 160(sp) none): 1
(sd s2 144(sp) none): 1

Total Number of Instructions: 54
```

```sh
$ cat test.txt | ospike stdin -impl string -compare instr_reg 
(sd a0 8(a7) none): 2
(ld ra 40(sp) none): 2
(addi a7 s10 8): 2
(Unknown Instruction none none none): 2
(addi sp sp 48): 2
(lui s2 0x1 none): 2
(sd s2 -8(a7) none): 2
(addiw s2 s2 -2048): 2
(sd s7 0(a7) none): 2
(bltu s10 s11 pc + 44): 2
(addi s10 s10 -24): 2
(mv a0 a7 none): 2
(ld s7 24(sp) none): 2
(ret none none none): 2
(sd a1 88(sp) none): 1
(sd a2 96(sp) none): 1
(sd gp 24(sp) none): 1
(sd a7 136(sp) none): 1
(sd a6 128(sp) none): 1
(sd t0 40(sp) none): 1
(sd a3 104(sp) none): 1
(sd tp 32(sp) none): 1
(sd ra 8(sp) none): 1
(sd s7 184(sp) none): 1
(sd t2 56(sp) none): 1
(sd s3 152(sp) none): 1
(sd a4 112(sp) none): 1
(sd s5 168(sp) none): 1
(sd a0 80(sp) none): 1
(sd t1 48(sp) none): 1
(sd s6 176(sp) none): 1
(sd s1 72(sp) none): 1
(addi sp sp -320): 1
(sd s8 192(sp) none): 1
(sd s0 64(sp) none): 1
(sd a5 120(sp) none): 1
(sd s4 160(sp) none): 1
(csrrw sp sscratch sp): 1
(sd s2 144(sp) none): 1
(bnez sp pc + 8 none): 1

Total Number of Instructions: 54
```


# Instructions with their registers, opcode and address
```sh
$ cat test.txt | ospike stdin -compare full 
(0x000000000150ac sd s7 0(a7) none): 2
(0x000000000150b4 mv a0 a7 none): 2
(0x000000000150a4 sd s2 none -8(a7)): 2
(0x000000000150b8 ld ra 40(sp) none): 2
(0x0000000001509c lui s2 0x1 none): 2
(0x000000000150a0 addiw s2 s2  -2048): 2
(0x00000000015094 addi a7 s10  8): 2
(0x000000000150c0 ret none none none): 2
(0x00000000015090 addi s10 s10  -24): 2
(0x000000000150b0 sd a0 8(a7) none): 2
(0x0000000000002a Unknown Instruction none none none): 2
(0x000000000150a8 ld s7 24(sp) none): 2
(0x000000000150bc addi sp sp  48): 2
(0x00000000015098 bltu s10 s11  pc ): 2
(0x00000080002120 csrrw sp sscratch  sp): 1
(0x00000080002174 sd s3 152(sp) none): 1
(0x00000080002160 sd a4 112(sp) none): 1
(0x0000008000212c addi sp sp  -320): 1
(0x00000080002124 bnez sp pc  none): 1
(0x0000008000214c sd s1 72(sp) none): 1
(0x00000080002178 sd s4 160(sp) none): 1
(0x00000080002150 sd a0 80(sp) none): 1
(0x00000080002180 sd s6 176(sp) none): 1
(0x00000080002130 sd ra 8(sp) none): 1
(0x0000008000216c sd a7 136(sp) none): 1
(0x00000080002188 sd s8 192(sp) none): 1
(0x00000080002170 sd s2 144(sp) none): 1
(0x00000080002164 sd a5 120(sp) none): 1
(0x00000080002184 sd s7 184(sp) none): 1
(0x0000008000217c sd s5 168(sp) none): 1
(0x00000080002154 sd a1 88(sp) none): 1
(0x00000080002144 sd t2 56(sp) none): 1
(0x00000080002134 sd gp 24(sp) none): 1
(0x0000008000213c sd t0 40(sp) none): 1
(0x00000080002138 sd tp 32(sp) none): 1
(0x00000080002140 sd t1 48(sp) none): 1
(0x00000080002168 sd a6 128(sp) none): 1
(0x00000080002158 sd a2 96(sp) none): 1
(0x0000008000215c sd a3 104(sp) none): 1
(0x00000080002148 sd s0 64(sp) none): 1

Total Number of Instructions: 54
```

```sh
$ cat test.txt | ospike stdin -impl string -compare full 
(0x000000000150ac sd s7 0(a7) none): 2
(0x00000000015098 bltu s10 s11 pc + 44): 2
(0x000000000150b4 mv a0 a7 none): 2
(0x000000000150b8 ld ra 40(sp) none): 2
(0x00000000015090 addi s10 s10 -24): 2
(0x0000000001509c lui s2 0x1 none): 2
(0x00000000015094 addi a7 s10 8): 2
(0x000000000150bc addi sp sp 48): 2
(0x000000000150c0 ret none none none): 2
(0x000000000150a0 addiw s2 s2 -2048): 2
(0x000000000150b0 sd a0 8(a7) none): 2
(0x0000000000002a Unknown Instruction none none none): 2
(0x000000000150a8 ld s7 24(sp) none): 2
(0x000000000150a4 sd s2 -8(a7) none): 2
(0x00000080002174 sd s3 152(sp) none): 1
(0x00000080002160 sd a4 112(sp) none): 1
(0x00000080002120 csrrw sp sscratch sp): 1
(0x0000008000214c sd s1 72(sp) none): 1
(0x00000080002178 sd s4 160(sp) none): 1
(0x00000080002150 sd a0 80(sp) none): 1
(0x00000080002180 sd s6 176(sp) none): 1
(0x00000080002130 sd ra 8(sp) none): 1
(0x0000008000216c sd a7 136(sp) none): 1
(0x00000080002188 sd s8 192(sp) none): 1
(0x00000080002170 sd s2 144(sp) none): 1
(0x00000080002164 sd a5 120(sp) none): 1
(0x00000080002184 sd s7 184(sp) none): 1
(0x0000008000217c sd s5 168(sp) none): 1
(0x00000080002154 sd a1 88(sp) none): 1
(0x00000080002124 bnez sp pc + 8 none): 1
(0x00000080002144 sd t2 56(sp) none): 1
(0x00000080002134 sd gp 24(sp) none): 1
(0x0000008000213c sd t0 40(sp) none): 1
(0x00000080002138 sd tp 32(sp) none): 1
(0x00000080002140 sd t1 48(sp) none): 1
(0x0000008000212c addi sp sp -320): 1
(0x00000080002168 sd a6 128(sp) none): 1
(0x00000080002158 sd a2 96(sp) none): 1
(0x0000008000215c sd a3 104(sp) none): 1
(0x00000080002148 sd s0 64(sp) none): 1

Total Number of Instructions: 54
```

# Grouping instructions 
```sh
$ cat test.txt | ospike stdin -group 2
(sd)(sd): 24
(ld)(addi): 2
(addi)(addi): 2
(mv)(ld): 2
(bltu)(lui): 2
(ld)(sd): 2
(addiw)(sd): 2
(sd)(mv): 2
(addi)(bltu): 2
(lui)(addiw): 2
(ret)(addi): 2
(addi)(ret): 2
(csrrw)(bnez): 1
(Unknown Instruction)(Unknown Instruction): 1
(sd)(ld): 1
(sd)(Unknown Instruction): 1
(addi)(sd): 1
(Unknown Instruction)(csrrw): 1
(bnez)(addi): 1

Total Number of Instructions: 54
```

```sh
$ cat test.txt | ospike stdin -impl string -group 2
(sd)(sd): 24
(ld)(addi): 2
(addi)(addi): 2
(mv)(ld): 2
(bltu)(lui): 2
(ld)(sd): 2
(addiw)(sd): 2
(sd)(mv): 2
(addi)(bltu): 2
(lui)(addiw): 2
(ret)(addi): 2
(addi)(ret): 2
(csrrw)(bnez): 1
(Unknown Instruction)(Unknown Instruction): 1
(sd)(ld): 1
(sd)(Unknown Instruction): 1
(addi)(sd): 1
(Unknown Instruction)(csrrw): 1
(bnez)(addi): 1

Total Number of Instructions: 54
```
