; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-- -mcpu=core2 -pre-RA-sched=source -enable-misched \
; RUN:          -misched-topdown -verify-machineinstrs \
; RUN:     | FileCheck %s -check-prefix=TOPDOWN
; RUN: llc < %s -mtriple=x86_64-- -mcpu=core2 -pre-RA-sched=source -enable-misched \
; RUN:          -misched=ilpmin -verify-machineinstrs \
; RUN:     | FileCheck %s -check-prefix=ILPMIN
; RUN: llc < %s -mtriple=x86_64-- -mcpu=core2 -pre-RA-sched=source -enable-misched \
; RUN:          -misched=ilpmax -verify-machineinstrs \
; RUN:     | FileCheck %s -check-prefix=ILPMAX
;
; Verify that the MI scheduler minimizes register pressure for a
; uniform set of bottom-up subtrees (unrolled matrix multiply).
;
; For current top-down heuristics, ensure that some folded imulls have
; been reordered with the stores. This tests the scheduler's cheap
; alias analysis ability (that doesn't require any AliasAnalysis pass).
;
; For -misched=ilpmin, verify that each expression subtree is
; scheduled independently, and that the imull/adds are interleaved.
;
; For -misched=ilpmax, verify that each expression subtree is
; scheduled independently, and that the imull/adds are clustered.
;
define void @mmult([4 x i32]* noalias nocapture %m1, [4 x i32]* noalias nocapture %m2,
; TOPDOWN-LABEL: mmult:
; TOPDOWN:       # %bb.0: # %entry
; TOPDOWN-NEXT:    pushq %rbp
; TOPDOWN-NEXT:    .cfi_def_cfa_offset 16
; TOPDOWN-NEXT:    pushq %r14
; TOPDOWN-NEXT:    .cfi_def_cfa_offset 24
; TOPDOWN-NEXT:    pushq %rbx
; TOPDOWN-NEXT:    .cfi_def_cfa_offset 32
; TOPDOWN-NEXT:    .cfi_offset %rbx, -32
; TOPDOWN-NEXT:    .cfi_offset %r14, -24
; TOPDOWN-NEXT:    .cfi_offset %rbp, -16
; TOPDOWN-NEXT:    xorl %eax, %eax
; TOPDOWN-NEXT:    .p2align 4, 0x90
; TOPDOWN-NEXT:  .LBB0_1: # %for.body
; TOPDOWN-NEXT:    # =>This Inner Loop Header: Depth=1
; TOPDOWN-NEXT:    movl (%rdi,%rax), %r10d
; TOPDOWN-NEXT:    movl 4(%rdi,%rax), %r14d
; TOPDOWN-NEXT:    movl 8(%rdi,%rax), %r9d
; TOPDOWN-NEXT:    movl 12(%rdi,%rax), %r8d
; TOPDOWN-NEXT:    movl (%rsi), %ecx
; TOPDOWN-NEXT:    imull %r10d, %ecx
; TOPDOWN-NEXT:    movl 16(%rsi), %ebx
; TOPDOWN-NEXT:    imull %r14d, %ebx
; TOPDOWN-NEXT:    addl %ecx, %ebx
; TOPDOWN-NEXT:    movl 32(%rsi), %ecx
; TOPDOWN-NEXT:    imull %r9d, %ecx
; TOPDOWN-NEXT:    addl %ebx, %ecx
; TOPDOWN-NEXT:    movl 48(%rsi), %r11d
; TOPDOWN-NEXT:    imull %r8d, %r11d
; TOPDOWN-NEXT:    addl %ecx, %r11d
; TOPDOWN-NEXT:    movl 4(%rsi), %ecx
; TOPDOWN-NEXT:    imull %r10d, %ecx
; TOPDOWN-NEXT:    movl 20(%rsi), %ebx
; TOPDOWN-NEXT:    imull %r14d, %ebx
; TOPDOWN-NEXT:    addl %ecx, %ebx
; TOPDOWN-NEXT:    movl 36(%rsi), %ecx
; TOPDOWN-NEXT:    imull %r9d, %ecx
; TOPDOWN-NEXT:    addl %ebx, %ecx
; TOPDOWN-NEXT:    movl 52(%rsi), %ebx
; TOPDOWN-NEXT:    imull %r8d, %ebx
; TOPDOWN-NEXT:    addl %ecx, %ebx
; TOPDOWN-NEXT:    movl 8(%rsi), %ecx
; TOPDOWN-NEXT:    imull %r10d, %ecx
; TOPDOWN-NEXT:    movl 24(%rsi), %ebp
; TOPDOWN-NEXT:    imull %r14d, %ebp
; TOPDOWN-NEXT:    addl %ecx, %ebp
; TOPDOWN-NEXT:    movl 40(%rsi), %ecx
; TOPDOWN-NEXT:    imull %r9d, %ecx
; TOPDOWN-NEXT:    addl %ebp, %ecx
; TOPDOWN-NEXT:    movl 56(%rsi), %ebp
; TOPDOWN-NEXT:    imull %r8d, %ebp
; TOPDOWN-NEXT:    addl %ecx, %ebp
; TOPDOWN-NEXT:    imull 12(%rsi), %r10d
; TOPDOWN-NEXT:    movl %r11d, (%rdx,%rax)
; TOPDOWN-NEXT:    imull 28(%rsi), %r14d
; TOPDOWN-NEXT:    addl %r10d, %r14d
; TOPDOWN-NEXT:    movl %ebx, 4(%rdx,%rax)
; TOPDOWN-NEXT:    imull 44(%rsi), %r9d
; TOPDOWN-NEXT:    addl %r14d, %r9d
; TOPDOWN-NEXT:    movl %ebp, 8(%rdx,%rax)
; TOPDOWN-NEXT:    imull 60(%rsi), %r8d
; TOPDOWN-NEXT:    addl %r9d, %r8d
; TOPDOWN-NEXT:    movl %r8d, 12(%rdx,%rax)
; TOPDOWN-NEXT:    addq $16, %rax
; TOPDOWN-NEXT:    cmpl $64, %eax
; TOPDOWN-NEXT:    jne .LBB0_1
; TOPDOWN-NEXT:  # %bb.2: # %for.end
; TOPDOWN-NEXT:    popq %rbx
; TOPDOWN-NEXT:    popq %r14
; TOPDOWN-NEXT:    popq %rbp
; TOPDOWN-NEXT:    retq
;
; ILPMIN-LABEL: mmult:
; ILPMIN:       # %bb.0: # %entry
; ILPMIN-NEXT:    pushq %rbp
; ILPMIN-NEXT:    .cfi_def_cfa_offset 16
; ILPMIN-NEXT:    pushq %r14
; ILPMIN-NEXT:    .cfi_def_cfa_offset 24
; ILPMIN-NEXT:    pushq %rbx
; ILPMIN-NEXT:    .cfi_def_cfa_offset 32
; ILPMIN-NEXT:    .cfi_offset %rbx, -32
; ILPMIN-NEXT:    .cfi_offset %r14, -24
; ILPMIN-NEXT:    .cfi_offset %rbp, -16
; ILPMIN-NEXT:    xorl %r14d, %r14d
; ILPMIN-NEXT:    .p2align 4, 0x90
; ILPMIN-NEXT:  .LBB0_1: # %for.body
; ILPMIN-NEXT:    # =>This Inner Loop Header: Depth=1
; ILPMIN-NEXT:    movl (%rdi,%r14), %r8d
; ILPMIN-NEXT:    movl 8(%rdi,%r14), %r9d
; ILPMIN-NEXT:    movl 4(%rdi,%r14), %r11d
; ILPMIN-NEXT:    movl 12(%rdi,%r14), %r10d
; ILPMIN-NEXT:    movl (%rsi), %ecx
; ILPMIN-NEXT:    movl 16(%rsi), %ebx
; ILPMIN-NEXT:    movl 32(%rsi), %ebp
; ILPMIN-NEXT:    imull %r8d, %ecx
; ILPMIN-NEXT:    imull %r11d, %ebx
; ILPMIN-NEXT:    addl %ecx, %ebx
; ILPMIN-NEXT:    imull %r9d, %ebp
; ILPMIN-NEXT:    addl %ebx, %ebp
; ILPMIN-NEXT:    movl 48(%rsi), %ecx
; ILPMIN-NEXT:    imull %r10d, %ecx
; ILPMIN-NEXT:    addl %ebp, %ecx
; ILPMIN-NEXT:    movl %ecx, (%rdx,%r14)
; ILPMIN-NEXT:    movl 52(%rsi), %ecx
; ILPMIN-NEXT:    movl 4(%rsi), %ebx
; ILPMIN-NEXT:    movl 20(%rsi), %ebp
; ILPMIN-NEXT:    movl 36(%rsi), %eax
; ILPMIN-NEXT:    imull %r8d, %ebx
; ILPMIN-NEXT:    imull %r11d, %ebp
; ILPMIN-NEXT:    addl %ebx, %ebp
; ILPMIN-NEXT:    imull %r9d, %eax
; ILPMIN-NEXT:    addl %ebp, %eax
; ILPMIN-NEXT:    imull %r10d, %ecx
; ILPMIN-NEXT:    addl %eax, %ecx
; ILPMIN-NEXT:    movl %ecx, 4(%rdx,%r14)
; ILPMIN-NEXT:    movl 56(%rsi), %eax
; ILPMIN-NEXT:    movl 8(%rsi), %ecx
; ILPMIN-NEXT:    movl 24(%rsi), %ebx
; ILPMIN-NEXT:    movl 40(%rsi), %ebp
; ILPMIN-NEXT:    imull %r8d, %ecx
; ILPMIN-NEXT:    imull %r11d, %ebx
; ILPMIN-NEXT:    addl %ecx, %ebx
; ILPMIN-NEXT:    imull %r9d, %ebp
; ILPMIN-NEXT:    addl %ebx, %ebp
; ILPMIN-NEXT:    imull %r10d, %eax
; ILPMIN-NEXT:    addl %ebp, %eax
; ILPMIN-NEXT:    movl %eax, 8(%rdx,%r14)
; ILPMIN-NEXT:    imull 12(%rsi), %r8d
; ILPMIN-NEXT:    imull 28(%rsi), %r11d
; ILPMIN-NEXT:    addl %r8d, %r11d
; ILPMIN-NEXT:    imull 44(%rsi), %r9d
; ILPMIN-NEXT:    addl %r11d, %r9d
; ILPMIN-NEXT:    imull 60(%rsi), %r10d
; ILPMIN-NEXT:    addl %r9d, %r10d
; ILPMIN-NEXT:    movl %r10d, 12(%rdx,%r14)
; ILPMIN-NEXT:    addq $16, %r14
; ILPMIN-NEXT:    cmpl $64, %r14d
; ILPMIN-NEXT:    jne .LBB0_1
; ILPMIN-NEXT:  # %bb.2: # %for.end
; ILPMIN-NEXT:    popq %rbx
; ILPMIN-NEXT:    popq %r14
; ILPMIN-NEXT:    popq %rbp
; ILPMIN-NEXT:    retq
;
; ILPMAX-LABEL: mmult:
; ILPMAX:       # %bb.0: # %entry
; ILPMAX-NEXT:    pushq %rbp
; ILPMAX-NEXT:    .cfi_def_cfa_offset 16
; ILPMAX-NEXT:    pushq %r15
; ILPMAX-NEXT:    .cfi_def_cfa_offset 24
; ILPMAX-NEXT:    pushq %r14
; ILPMAX-NEXT:    .cfi_def_cfa_offset 32
; ILPMAX-NEXT:    pushq %rbx
; ILPMAX-NEXT:    .cfi_def_cfa_offset 40
; ILPMAX-NEXT:    .cfi_offset %rbx, -40
; ILPMAX-NEXT:    .cfi_offset %r14, -32
; ILPMAX-NEXT:    .cfi_offset %r15, -24
; ILPMAX-NEXT:    .cfi_offset %rbp, -16
; ILPMAX-NEXT:    xorl %r15d, %r15d
; ILPMAX-NEXT:    .p2align 4, 0x90
; ILPMAX-NEXT:  .LBB0_1: # %for.body
; ILPMAX-NEXT:    # =>This Inner Loop Header: Depth=1
; ILPMAX-NEXT:    movl (%rdi,%r15), %r8d
; ILPMAX-NEXT:    movl 8(%rdi,%r15), %r9d
; ILPMAX-NEXT:    movl 4(%rdi,%r15), %r14d
; ILPMAX-NEXT:    movl 12(%rdi,%r15), %r10d
; ILPMAX-NEXT:    movl 16(%rsi), %ebx
; ILPMAX-NEXT:    imull %r14d, %ebx
; ILPMAX-NEXT:    movl (%rsi), %ebp
; ILPMAX-NEXT:    imull %r8d, %ebp
; ILPMAX-NEXT:    movl 32(%rsi), %ecx
; ILPMAX-NEXT:    imull %r9d, %ecx
; ILPMAX-NEXT:    movl 48(%rsi), %r11d
; ILPMAX-NEXT:    imull %r10d, %r11d
; ILPMAX-NEXT:    addl %ebp, %ebx
; ILPMAX-NEXT:    addl %ebx, %ecx
; ILPMAX-NEXT:    addl %ecx, %r11d
; ILPMAX-NEXT:    movl %r11d, (%rdx,%r15)
; ILPMAX-NEXT:    movl 52(%rsi), %ecx
; ILPMAX-NEXT:    imull %r10d, %ecx
; ILPMAX-NEXT:    movl 4(%rsi), %ebp
; ILPMAX-NEXT:    imull %r8d, %ebp
; ILPMAX-NEXT:    movl 20(%rsi), %ebx
; ILPMAX-NEXT:    imull %r14d, %ebx
; ILPMAX-NEXT:    movl 36(%rsi), %eax
; ILPMAX-NEXT:    imull %r9d, %eax
; ILPMAX-NEXT:    addl %ebp, %ebx
; ILPMAX-NEXT:    addl %ebx, %eax
; ILPMAX-NEXT:    addl %eax, %ecx
; ILPMAX-NEXT:    movl %ecx, 4(%rdx,%r15)
; ILPMAX-NEXT:    movl 56(%rsi), %eax
; ILPMAX-NEXT:    imull %r10d, %eax
; ILPMAX-NEXT:    movl 8(%rsi), %ecx
; ILPMAX-NEXT:    imull %r8d, %ecx
; ILPMAX-NEXT:    movl 24(%rsi), %ebp
; ILPMAX-NEXT:    imull %r14d, %ebp
; ILPMAX-NEXT:    movl 40(%rsi), %ebx
; ILPMAX-NEXT:    imull %r9d, %ebx
; ILPMAX-NEXT:    addl %ecx, %ebp
; ILPMAX-NEXT:    addl %ebp, %ebx
; ILPMAX-NEXT:    addl %ebx, %eax
; ILPMAX-NEXT:    movl %eax, 8(%rdx,%r15)
; ILPMAX-NEXT:    imull 60(%rsi), %r10d
; ILPMAX-NEXT:    imull 12(%rsi), %r8d
; ILPMAX-NEXT:    imull 28(%rsi), %r14d
; ILPMAX-NEXT:    imull 44(%rsi), %r9d
; ILPMAX-NEXT:    addl %r8d, %r14d
; ILPMAX-NEXT:    addl %r14d, %r9d
; ILPMAX-NEXT:    addl %r9d, %r10d
; ILPMAX-NEXT:    movl %r10d, 12(%rdx,%r15)
; ILPMAX-NEXT:    addq $16, %r15
; ILPMAX-NEXT:    cmpl $64, %r15d
; ILPMAX-NEXT:    jne .LBB0_1
; ILPMAX-NEXT:  # %bb.2: # %for.end
; ILPMAX-NEXT:    popq %rbx
; ILPMAX-NEXT:    popq %r14
; ILPMAX-NEXT:    popq %r15
; ILPMAX-NEXT:    popq %rbp
; ILPMAX-NEXT:    retq
[4 x i32]* noalias nocapture %m3) nounwind uwtable ssp {
entry:
  br label %for.body

for.body:                              ; preds = %for.body, %entry
  %indvars.iv = phi i64 [ 0, %entry ], [ %indvars.iv.next, %for.body ]
  %arrayidx8 = getelementptr inbounds [4 x i32], [4 x i32]* %m1, i64 %indvars.iv, i64 0
  %tmp = load i32, i32* %arrayidx8, align 4
  %arrayidx12 = getelementptr inbounds [4 x i32], [4 x i32]* %m2, i64 0, i64 0
  %tmp1 = load i32, i32* %arrayidx12, align 4
  %arrayidx8.1 = getelementptr inbounds [4 x i32], [4 x i32]* %m1, i64 %indvars.iv, i64 1
  %tmp2 = load i32, i32* %arrayidx8.1, align 4
  %arrayidx12.1 = getelementptr inbounds [4 x i32], [4 x i32]* %m2, i64 1, i64 0
  %tmp3 = load i32, i32* %arrayidx12.1, align 4
  %arrayidx8.2 = getelementptr inbounds [4 x i32], [4 x i32]* %m1, i64 %indvars.iv, i64 2
  %tmp4 = load i32, i32* %arrayidx8.2, align 4
  %arrayidx12.2 = getelementptr inbounds [4 x i32], [4 x i32]* %m2, i64 2, i64 0
  %tmp5 = load i32, i32* %arrayidx12.2, align 4
  %arrayidx8.3 = getelementptr inbounds [4 x i32], [4 x i32]* %m1, i64 %indvars.iv, i64 3
  %tmp6 = load i32, i32* %arrayidx8.3, align 4
  %arrayidx12.3 = getelementptr inbounds [4 x i32], [4 x i32]* %m2, i64 3, i64 0
  %tmp8 = load i32, i32* %arrayidx8, align 4
  %arrayidx12.137 = getelementptr inbounds [4 x i32], [4 x i32]* %m2, i64 0, i64 1
  %tmp9 = load i32, i32* %arrayidx12.137, align 4
  %tmp10 = load i32, i32* %arrayidx8.1, align 4
  %arrayidx12.1.1 = getelementptr inbounds [4 x i32], [4 x i32]* %m2, i64 1, i64 1
  %tmp11 = load i32, i32* %arrayidx12.1.1, align 4
  %tmp12 = load i32, i32* %arrayidx8.2, align 4
  %arrayidx12.2.1 = getelementptr inbounds [4 x i32], [4 x i32]* %m2, i64 2, i64 1
  %tmp13 = load i32, i32* %arrayidx12.2.1, align 4
  %tmp14 = load i32, i32* %arrayidx8.3, align 4
  %arrayidx12.3.1 = getelementptr inbounds [4 x i32], [4 x i32]* %m2, i64 3, i64 1
  %tmp15 = load i32, i32* %arrayidx12.3.1, align 4
  %tmp16 = load i32, i32* %arrayidx8, align 4
  %arrayidx12.239 = getelementptr inbounds [4 x i32], [4 x i32]* %m2, i64 0, i64 2
  %tmp17 = load i32, i32* %arrayidx12.239, align 4
  %tmp18 = load i32, i32* %arrayidx8.1, align 4
  %arrayidx12.1.2 = getelementptr inbounds [4 x i32], [4 x i32]* %m2, i64 1, i64 2
  %tmp19 = load i32, i32* %arrayidx12.1.2, align 4
  %tmp20 = load i32, i32* %arrayidx8.2, align 4
  %arrayidx12.2.2 = getelementptr inbounds [4 x i32], [4 x i32]* %m2, i64 2, i64 2
  %tmp21 = load i32, i32* %arrayidx12.2.2, align 4
  %tmp22 = load i32, i32* %arrayidx8.3, align 4
  %arrayidx12.3.2 = getelementptr inbounds [4 x i32], [4 x i32]* %m2, i64 3, i64 2
  %tmp23 = load i32, i32* %arrayidx12.3.2, align 4
  %tmp24 = load i32, i32* %arrayidx8, align 4
  %arrayidx12.341 = getelementptr inbounds [4 x i32], [4 x i32]* %m2, i64 0, i64 3
  %tmp25 = load i32, i32* %arrayidx12.341, align 4
  %tmp26 = load i32, i32* %arrayidx8.1, align 4
  %arrayidx12.1.3 = getelementptr inbounds [4 x i32], [4 x i32]* %m2, i64 1, i64 3
  %tmp27 = load i32, i32* %arrayidx12.1.3, align 4
  %tmp28 = load i32, i32* %arrayidx8.2, align 4
  %arrayidx12.2.3 = getelementptr inbounds [4 x i32], [4 x i32]* %m2, i64 2, i64 3
  %tmp29 = load i32, i32* %arrayidx12.2.3, align 4
  %tmp30 = load i32, i32* %arrayidx8.3, align 4
  %arrayidx12.3.3 = getelementptr inbounds [4 x i32], [4 x i32]* %m2, i64 3, i64 3
  %tmp31 = load i32, i32* %arrayidx12.3.3, align 4
  %tmp7 = load i32, i32* %arrayidx12.3, align 4
  %mul = mul nsw i32 %tmp1, %tmp
  %mul.1 = mul nsw i32 %tmp3, %tmp2
  %mul.2 = mul nsw i32 %tmp5, %tmp4
  %mul.3 = mul nsw i32 %tmp7, %tmp6
  %mul.138 = mul nsw i32 %tmp9, %tmp8
  %mul.1.1 = mul nsw i32 %tmp11, %tmp10
  %mul.2.1 = mul nsw i32 %tmp13, %tmp12
  %mul.3.1 = mul nsw i32 %tmp15, %tmp14
  %mul.240 = mul nsw i32 %tmp17, %tmp16
  %mul.1.2 = mul nsw i32 %tmp19, %tmp18
  %mul.2.2 = mul nsw i32 %tmp21, %tmp20
  %mul.3.2 = mul nsw i32 %tmp23, %tmp22
  %mul.342 = mul nsw i32 %tmp25, %tmp24
  %mul.1.3 = mul nsw i32 %tmp27, %tmp26
  %mul.2.3 = mul nsw i32 %tmp29, %tmp28
  %mul.3.3 = mul nsw i32 %tmp31, %tmp30
  %add.1 = add nsw i32 %mul.1, %mul
  %add.2 = add nsw i32 %mul.2, %add.1
  %add.3 = add nsw i32 %mul.3, %add.2
  %add.1.1 = add nsw i32 %mul.1.1, %mul.138
  %add.2.1 = add nsw i32 %mul.2.1, %add.1.1
  %add.3.1 = add nsw i32 %mul.3.1, %add.2.1
  %add.1.2 = add nsw i32 %mul.1.2, %mul.240
  %add.2.2 = add nsw i32 %mul.2.2, %add.1.2
  %add.3.2 = add nsw i32 %mul.3.2, %add.2.2
  %add.1.3 = add nsw i32 %mul.1.3, %mul.342
  %add.2.3 = add nsw i32 %mul.2.3, %add.1.3
  %add.3.3 = add nsw i32 %mul.3.3, %add.2.3
  %arrayidx16 = getelementptr inbounds [4 x i32], [4 x i32]* %m3, i64 %indvars.iv, i64 0
  store i32 %add.3, i32* %arrayidx16, align 4
  %arrayidx16.1 = getelementptr inbounds [4 x i32], [4 x i32]* %m3, i64 %indvars.iv, i64 1
  store i32 %add.3.1, i32* %arrayidx16.1, align 4
  %arrayidx16.2 = getelementptr inbounds [4 x i32], [4 x i32]* %m3, i64 %indvars.iv, i64 2
  store i32 %add.3.2, i32* %arrayidx16.2, align 4
  %arrayidx16.3 = getelementptr inbounds [4 x i32], [4 x i32]* %m3, i64 %indvars.iv, i64 3
  store i32 %add.3.3, i32* %arrayidx16.3, align 4
  %indvars.iv.next = add i64 %indvars.iv, 1
  %lftr.wideiv = trunc i64 %indvars.iv.next to i32
  %exitcond = icmp eq i32 %lftr.wideiv, 4
  br i1 %exitcond, label %for.end, label %for.body

for.end:                                        ; preds = %for.body
  ret void
}
