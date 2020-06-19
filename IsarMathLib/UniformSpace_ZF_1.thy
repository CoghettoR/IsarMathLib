(* 
    This file is a part of IsarMathLib - 
    a library of formalized mathematics written for Isabelle/Isar.

    Copyright (C) 2020 Daniel de la Concepcion

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
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. *)

theory UniformSpace_ZF_1 imports UniformSpace_ZF Topology_ZF_2
begin

text\<open> This theory defines the maps to study in uniform spaces and proves their basic properties. \<close>

subsection\<open> Product of functions \<close>

text\<open> Given 2 functions $f:A\to B$ and $g:C\to D$ , we can consider a function $h:A\times C \to B\times D$
such that $h(x,y)=(f(x),g(y))$ \<close>

definition
  ProdFunction where
  "ProdFunction(f,g) \<equiv> {\<langle>z,\<langle>f`(fst(z)),g`(snd(z))\<rangle>\<rangle>. z\<in>domain(f)\<times>domain(g)}"

lemma prodFunction:
  assumes "f:A->B" "g:C->D"
  shows "ProdFunction(f,g):(A\<times>C)->(B\<times>D)"
proof-
  have func:"function(ProdFunction(f,g))" unfolding function_def apply safe
  proof-
    fix x y z assume "\<langle>x,y\<rangle>:ProdFunction(f,g)" "\<langle>x,z\<rangle>:ProdFunction(f,g)"
    with ProdFunction_def show "y=z" by auto 
  qed
  moreover have "ProdFunction(f,g) \<subseteq> (A\<times>C)\<times>(B\<times>D)" 
  proof
    fix t assume "t:ProdFunction(f,g)"
    then obtain z where z:"z:domain(f)\<times>domain(g)" "t=\<langle>z,\<langle>f`(fst(z)),g`(snd(z))\<rangle>\<rangle>" unfolding ProdFunction_def by blast
    from z(1) assms have z3:"z:A\<times>C" using domain_of_fun by auto
    then have "fst(z):A" "snd(z):C" by auto
    then have "f`(fst(z)):B" "g`(snd(z)):D" using apply_funtype assms by auto
    then have "\<langle>f`(fst(z)),g`(snd(z))\<rangle>:B\<times>D" by auto
    with z(2) z3 show "t:(A\<times>C)\<times>(B\<times>D)" by auto
  qed
  moreover have "A\<times>C \<subseteq> domain(ProdFunction(f,g))"
  proof-
    have "domain(ProdFunction(f,g)) = domain(f)\<times>domain(g)" unfolding ProdFunction_def by auto 
    moreover from assms have "domain(f) = A" "domain(g) =C" using domain_of_fun by auto
    ultimately show "A\<times>C \<subseteq> domain(ProdFunction(f,g))" by auto 
  qed
  ultimately show ?thesis using Pi_iff by auto
qed

lemma prodFunctionApp:
  assumes "f:A->B" "g:C->D" "x:A" "y:C"
  shows "ProdFunction(f,g)`\<langle>x,y\<rangle> = \<langle>f`x,g`y\<rangle>" using apply_equality[OF _ prodFunction[OF assms(1,2)], of "\<langle>x,y\<rangle>" "\<langle>f`x,g`y\<rangle>"] 
    unfolding ProdFunction_def apply auto
proof-
  assume R:"x \<in> domain(f) \<and> y \<in> domain(g) \<Longrightarrow>
     {\<langle>z, f ` fst(z), g ` snd(z)\<rangle> . z \<in> domain(f) \<times> domain(g)} ` \<langle>x, y\<rangle> =
     \<langle>f ` x, g ` y\<rangle>"
  have "x:domain(f)" using assms(1,3) unfolding domain_def Pi_def by auto moreover
  have "y:domain(g)" using assms(2,4) unfolding domain_def Pi_def by auto moreover
  note R ultimately
  show "{\<langle>z, f ` fst(z), g ` snd(z)\<rangle> . z \<in> domain(f) \<times> domain(g)} ` \<langle>x, y\<rangle> =
     \<langle>f ` x, g ` y\<rangle>" by auto
qed

subsection\<open> Uniformly continuous functions \<close>

text\<open> A map between 2 uniformities is uniformly continuous if it preserves
the entourages: \<close>

definition
  IsUniformlyCont ("_ {is uniformly continuous between} _ {and} _" 90) where
  "f:X->Y ==> \<Phi> {is a uniformity on}X  ==> \<Gamma> {is a uniformity on}Y  ==> 
  f {is uniformly continuous between} \<Phi> {and} \<Gamma> \<equiv> \<forall>V\<in>\<Gamma>. (ProdFunction(f,f)-``V)\<in>\<Phi>"

text\<open> Any uniformly continuous function is continuous when considering the topologies on the uniformities. \<close>

lemma uniformly_cont_is_cont:
  assumes "f:X->Y" "\<Phi> {is a uniformity on}X " "\<Gamma> {is a uniformity on}Y" "f {is uniformly continuous between} \<Phi> {and} \<Gamma>"
  shows "IsContinuous(UniformTopology(\<Phi>,X),UniformTopology(\<Gamma>,Y),f)" unfolding IsContinuous_def
proof(safe)
  fix U assume op:"U:UniformTopology(\<Gamma>,Y)"
  show "f-``U : UniformTopology(\<Phi>,X)" unfolding UniformTopology_def
  proof(safe)
    fix x xa assume as:"\<langle>x,xa\<rangle>:f" "xa:U"
    with assms(1) show x:"x:X" unfolding Pi_def by auto
    from as(2) op have U:"U: {\<langle>t,{V``{t}.V\<in>\<Gamma>}\<rangle>.t\<in>Y}`xa" unfolding UniformTopology_def by auto
    from as(1) assms(1) have xa:"xa:Y" unfolding Pi_def by auto
    have "{\<langle>t,{V``{t}.V\<in>\<Gamma>}\<rangle>.t\<in>Y} :Pi(Y,%t. {{V``{t}.V\<in>\<Gamma>}})" unfolding Pi_def function_def by (safe,auto)
    with U xa have "U:{V``{xa}.V\<in>\<Gamma>}" using apply_equality by auto
    then obtain V where V:"U = V``{xa}" "V:\<Gamma>" by auto
    from V(2) have ent:"(ProdFunction(f,f)-``V)\<in>\<Phi>" using assms(4) unfolding IsUniformlyCont_def[OF assms(1-3)] by auto
    have "!!t. t: (ProdFunction(f,f)-``V)``{x} <-> \<langle>x,t\<rangle>: ProdFunction(f,f)-``V" using image_def by auto
    with x have "!!t. t: (ProdFunction(f,f)-``V)``{x} <-> (t:X \<and> ProdFunction(f,f)`\<langle>x,t\<rangle>: V)" using 
      func1_1_L15[OF prodFunction[OF assms(1) assms(1)]] by auto
    with x have R:"!!t. t: (ProdFunction(f,f)-``V)``{x} <-> (t:X \<and> \<langle>f`x,f`t\<rangle>: V)" using prodFunctionApp[OF assms(1) assms(1)] by auto
    with as(1) have R:"!!t. t: (ProdFunction(f,f)-``V)``{x} <-> (t:X \<and> \<langle>xa,f`t\<rangle>: V)" using apply_equality assms(1) by auto
    with V(1) have R:"!!t. t: (ProdFunction(f,f)-``V)``{x} <-> (t:X \<and> f`t: U)" by auto
    then have R:"!!t. t: (ProdFunction(f,f)-``V)``{x} <-> t: f-``U" using func1_1_L15[OF assms(1), of U] by auto
    then have "f-``U = (ProdFunction(f,f)-``V)``{x}" by blast
    with ent have "f -`` U \<in> {V `` {x} . V \<in> \<Phi>}" by auto moreover
    have "{\<langle>t,{V``{t}.V\<in>\<Phi>}\<rangle>.t\<in>X} :Pi(X,%t. {{V``{t}.V\<in>\<Phi>}})" unfolding Pi_def function_def by (safe,auto)
    ultimately show "f -`` U \<in> {\<langle>t, {V `` {t} . V \<in> \<Phi>}\<rangle> . t \<in> X} ` x" using x apply_equality[of x "{V `` {x} . V \<in> \<Phi>}"] by auto
  qed
qed

end