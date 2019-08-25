(* 
    This file is a part of IsarMathLib - 
    a library of formalized mathematics for Isabelle/Isar.

    Copyright (C) 2007  Slawomir Kolodynski

    This program is free software; Redistribution and use in source and binary forms, 
    with or without modification, are permitted provided that the following conditions are met:

   1. Redistributions of source code must retain the above copyright notice, 
   this list of conditions and the following disclaimer.
   2. Redistributions in binary form must reproduce the above copyright notice, 
   this list of conditions and the following disclaimer in the documentation and/or 
   other materials provided with the distribution.
   3. The name of the author may not be used to endorse or promote products 
   derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR IMPLIED 
WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF 
MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. 
IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, 
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, 
PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; 
OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 
WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR 
OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, 
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

*)

section \<open>Folding in ZF\<close>

theory Fold_ZF imports InductiveSeq_ZF

begin

text\<open>Suppose we have a binary operation $P: X\times X \rightarrow X$ written
  multiplicatively as $P\langle x, y \rangle= x\cdot y$. 
  In informal mathematics we can take a sequence $\{ x_k \}_{k\in 0.. n}$
  of elements of $X$ and consider the product 
  $x_0\cdot x_1 \cdot .. \cdot x_n$. To do the same thing in formalized 
  mathematics we have to define precisely what is meant by that 
  "$\cdot .. \cdot$". The definitition we want to use is based on the 
  notion of sequence defined by induction discussed in 
  \<open>InductiveSeq_ZF\<close>. We don't really want to derive the terminology
  for this from the word "product" as that would tie it conceptually 
  to the multiplicative notation. This would be awkward when we want to reuse
  the same notions to talk about sums like $x_0 + x_1 + .. + x_n$. 
  
  In functional programming there is something called "fold". 
  Namely for a function $f$, initial point $a$ and list 
  $\left[ b, c, d\right]$ 
  the expression \<open>fold(f, a, [b,c,d])\<close> is defined to be 
  \<open>f(f(f(a,b),c),d)\<close> (in Haskell something like this is called 
  \<open>foldl\<close>). If we write $f$ in multiplicative notation we get
  $a\cdot b \cdot c\cdot d$, so this is exactly what we need.
  The notion of folds in functional programming 
  is actually much more general that what we need here 
  (not that I know anything about that). In this theory file we just make
  a slight generalization and talk about folding a list with a binary
  operation $f:X\times Y \rightarrow X$ with $X$ not necessarily the same as 
  $Y$.\<close>

subsection\<open>Folding in ZF\<close>

text\<open>Suppose we have a binary operation $f : X\times Y \rightarrow X$. 
  Then every $y\in Y$ defines a transformation of $X$ defined by
  $T_y(x) = f\langle x,y\rangle$. In IsarMathLib such transformation is called
  as \<open>Fix2ndVar(f,y)\<close>. Using this notion, 
  given a function $f: X\times Y\rightarrow X$ and a sequence 
  $y = \{y_k\}_{k\in N}$ of elements of $X$ 
  we can get a sequence of transformations of $X$. 
  This is defined in \<open>Seq2TransSeq\<close> below. 
  Then we use that sequence of tranformations to define the sequence
  of partial folds (called \<open>FoldSeq\<close>) by means of 
  \<open>InductiveSeqVarFN\<close> (defined in \<open>InductiveSeq_ZF\<close> theory) 
  which implements the inductive sequence determined by a starting point 
  and a sequence of transformations. Finally, we define the fold of a 
  sequence as the last element of the sequence of the partial folds.\<close>

text\<open>Definition that specifies how to convert a sequence $a$ 
  of elements of $Y$ into a sequence of transformations of $X$, given a binary operation
  $f :X\times Y \rightarrow X$.\<close>

definition
  "Seq2TrSeq(f,a) \<equiv> {\<langle>k,Fix2ndVar(f,a`(k))\<rangle>. k \<in> domain(a)}"

text\<open>Definition of a sequence of partial folds.\<close>

definition
  "FoldSeq(f,x,a) \<equiv> 
  InductiveSeqVarFN(x,fstdom(f),Seq2TrSeq(f,a),domain(a))" 

text\<open>Definition of a fold.\<close>

definition
  "Fold(f,x,a) \<equiv> Last(FoldSeq(f,x,a))"

text\<open>If $X$ is a set with a binary operation $f:X\times Y \rightarrow X$ then 
  \<open>Seq2TransSeqN(f,a)\<close> converts a sequence $a$ of elements of $Y$  
  into the sequence of corresponding transformations of $X$.\<close>

lemma seq2trans_seq_props:
  assumes A1: "n \<in> nat" and A2: "f : X\<times>Y \<rightarrow> X" and A3: "a:n\<rightarrow>Y" and
  A4: "T = Seq2TrSeq(f,a)"
  shows
  "T : n \<rightarrow> (X\<rightarrow>X)" and
  "\<forall>k\<in>n. \<forall>x\<in>X. (T`(k))`(x) = f`\<langle>x,a`(k)\<rangle>"
proof -
  from \<open>a:n\<rightarrow>Y\<close> have D: "domain(a) = n" using func1_1_L1 by simp
  with A2 A3 A4 show "T : n \<rightarrow> (X\<rightarrow>X)"
    using apply_funtype fix_2nd_var_fun ZF_fun_from_total Seq2TrSeq_def
    by simp
  with A4 D have I: "\<forall>k \<in> n. T`(k) = Fix2ndVar(f,a`(k))"
    using Seq2TrSeq_def ZF_fun_from_tot_val0 by simp
  { fix k fix x assume A5: "k\<in>n"  "x\<in>X"
    with A1 A3 have "a`(k) \<in> Y" using apply_funtype
      by auto
    with A2 A5 I have "(T`(k))`(x) = f`\<langle>x,a`(k)\<rangle>"
      using fix_var_val by simp
  } thus "\<forall>k\<in>n. \<forall>x\<in>X. (T`(k))`(x) = f`\<langle>x,a`(k)\<rangle>"
    by simp
qed

text\<open>Basic properties of the sequence of partial folds of a sequence 
  $a = \{y_k\}_{k\in \{0,..,n\} }$.\<close>

theorem fold_seq_props:
  assumes A1: "n \<in> nat" and A2: "f : X\<times>Y \<rightarrow> X" and 
  A3: "y:n\<rightarrow>Y" and A4: "x\<in>X" and A5: "Y\<noteq>0" and 
  A6: "F = FoldSeq(f,x,y)"
  shows 
  "F: succ(n) \<rightarrow> X"
  "F`(0) = x" and
  "\<forall>k\<in>n. F`(succ(k)) = f`\<langle>F`(k), y`(k)\<rangle>"
proof -
  let ?T = "Seq2TrSeq(f,y)"
  from A1 A3 have D: "domain(y) = n"
    using func1_1_L1 by simp
  from \<open>f : X\<times>Y \<rightarrow> X\<close>  \<open>Y\<noteq>0\<close> have I: "fstdom(f) = X" 
    using fstdomdef by simp
  with A1 A2 A3 A4 A6 D show 
    II: "F: succ(n) \<rightarrow> X"  and "F`(0) = x"  
    using seq2trans_seq_props FoldSeq_def fin_indseq_var_f_props
    by auto
  from A1 A2 A3 A4 A6 I D have "\<forall>k\<in>n. F`(succ(k)) = ?T`(k)`(F`(k))"
    using  seq2trans_seq_props FoldSeq_def fin_indseq_var_f_props 
    by simp
  moreover
  { fix k assume A5: "k\<in>n" hence "k \<in> succ(n)" by auto
    with A1 A2 A3 II A5 have "(?T`(k))`(F`(k)) = f`\<langle>F`(k),y`(k)\<rangle>"
      using apply_funtype seq2trans_seq_props by simp }
  ultimately show "\<forall>k\<in>n. F`(succ(k)) = f`\<langle>F`(k), y`(k)\<rangle>"
    by simp
qed

text\<open>A consistency condition: if we make the list shorter, then we get a shorter
  sequence of partial folds with the same values as in the original sequence. 
  This can be proven as a special case of \<open>fin_indseq_var_f_restrict\<close>
  but a proof using \<open>fold_seq_props\<close> and induction turns out to be 
  shorter.\<close>

lemma foldseq_restrict: assumes 
  "n \<in> nat"   "k \<in> succ(n)" and 
  "i \<in> nat"  "f : X\<times>Y \<rightarrow> X"  "a : n \<rightarrow> Y"  "b : i \<rightarrow> Y" and
  "n \<subseteq> i"   "\<forall>j \<in> n. b`(j) = a`(j)"   "x \<in> X"   "Y \<noteq> 0"
  shows "FoldSeq(f,x,b)`(k) = FoldSeq(f,x,a)`(k)"
proof -
  let ?P = "FoldSeq(f,x,a)"
  let ?Q = "FoldSeq(f,x,b)"
  from assms have
    "n \<in> nat"   "k \<in> succ(n)"
    "?Q`(0) = ?P`(0)" and
    "\<forall>j \<in> n. ?Q`(j) = ?P`(j) \<longrightarrow> ?Q`(succ(j)) = ?P`(succ(j))"
    using fold_seq_props by auto
  then show  "?Q`(k) = ?P`(k)" by (rule fin_nat_ind)
qed

text\<open>A special case of \<open>foldseq_restrict\<close> when the longer
  sequence is created from the shorter one by appending
  one element.\<close>

corollary fold_seq_append: 
  assumes "n \<in> nat"   "f : X\<times>Y \<rightarrow> X"   "a:n \<rightarrow> Y" and
  "x\<in>X"   "k \<in> succ(n)"   "y\<in>Y" 
  shows "FoldSeq(f,x,Append(a,y))`(k) = FoldSeq(f,x,a)`(k)"
proof -
  let ?b = "Append(a,y)"
  from assms have "?b : succ(n) \<rightarrow> Y"  "\<forall>j \<in> n. ?b`(j) = a`(j)"
    using append_props by auto
  with assms show ?thesis using foldseq_restrict by blast
qed

text\<open>What we really will be using is the notion of the fold
  of a sequence, which we define as the last element of
  (inductively defined) sequence of partial folds. The next theorem 
  lists some properties of the product of the fold operation.\<close>

theorem fold_props: 
  assumes A1: "n \<in> nat" and 
  A2: "f : X\<times>Y \<rightarrow> X"  "a:n \<rightarrow> Y"  "x\<in>X"  "Y\<noteq>0"
  shows
  "Fold(f,x,a) =  FoldSeq(f,x,a)`(n)" and
  "Fold(f,x,a) \<in> X"
proof -
  from assms have " FoldSeq(f,x,a) : succ(n) \<rightarrow> X"
    using  fold_seq_props by simp
  with A1 show 
    "Fold(f,x,a) =  FoldSeq(f,x,a)`(n)" and "Fold(f,x,a) \<in> X"
    using last_seq_elem apply_funtype Fold_def by auto
qed

text\<open>A corner case: what happens when we fold an empty list?\<close>

theorem fold_empty: assumes A1: "f : X\<times>Y \<rightarrow> X" and 
  A2: "a:0\<rightarrow>Y"  "x\<in>X"  "Y\<noteq>0"
  shows "Fold(f,x,a) = x"
proof -
  let ?F = "FoldSeq(f,x,a)"
  from assms have I:
    "0 \<in> nat"  "f : X\<times>Y \<rightarrow> X"  "a:0\<rightarrow>Y"  "x\<in>X"  "Y\<noteq>0"
    by auto
  then have "Fold(f,x,a) = ?F`(0)" by (rule fold_props)
  moreover 
  from I have
    "0 \<in> nat"  "f : X\<times>Y \<rightarrow> X"  "a:0\<rightarrow>Y"  "x\<in>X"  "Y\<noteq>0" and
    "?F = FoldSeq(f,x,a)" by auto
  then have "?F`(0) = x" by (rule fold_seq_props)
  ultimately show "Fold(f,x,a) = x" by simp
qed

text\<open>The next theorem tells us what happens to the fold of a sequence
  when we add one more element to it.\<close>

theorem fold_append:  
  assumes A1: "n \<in> nat" and  A2: "f : X\<times>Y \<rightarrow> X" and
  A3: "a:n\<rightarrow>Y" and A4: "x\<in>X" and A5: "y\<in>Y"
  shows 
  "FoldSeq(f,x,Append(a,y))`(n) = Fold(f,x,a)" and
  "Fold(f,x,Append(a,y)) = f`\<langle>Fold(f,x,a), y\<rangle>"
proof -
  let ?b = "Append(a,y)"
  let ?P = "FoldSeq(f,x,?b)"
  from A5 have I: "Y \<noteq> 0" by auto
  with assms show thesis1: "?P`(n) = Fold(f,x,a)"
    using fold_seq_append fold_props by simp
  from assms I have II:
    "succ(n) \<in> nat"   "f : X\<times>Y \<rightarrow> X"
    "?b : succ(n) \<rightarrow> Y"   "x\<in>X"  "Y \<noteq> 0"
    "?P = FoldSeq(f,x,?b)"
    using append_props by auto
  then have 
    "\<forall>k \<in> succ(n). ?P`(succ(k)) =  f`\<langle>?P`(k), ?b`(k)\<rangle>"
    by (rule fold_seq_props) 
  with A3 A5 thesis1 have "?P`(succ(n)) =  f`\<langle> Fold(f,x,a), y\<rangle>"
    using append_props by auto
  moreover
  from II have "?P : succ(succ(n)) \<rightarrow> X"
    by (rule fold_seq_props)
  then have "Fold(f,x,?b) = ?P`(succ(n))" 
    using last_seq_elem Fold_def by simp
  ultimately show "Fold(f,x,Append(a,y)) = f`\<langle>Fold(f,x,a), y\<rangle>"
    by simp
qed


end
