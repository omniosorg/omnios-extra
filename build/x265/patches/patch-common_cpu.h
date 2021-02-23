$NetBSD: patch-common_cpu.h,v 1.1 2018/12/11 17:55:56 jklos Exp $

Retire detect512, use enable512 as a global

diff -wpruN '--exclude=*.orig' a~/common/cpu.h a/source/common/cpu.h
--- a~/common/cpu.h	1970-01-01 00:00:00
+++ a/common/cpu.h	1970-01-01 00:00:00
@@ -50,7 +50,7 @@ extern "C" void PFX(safe_intel_cpu_indic
 
 namespace X265_NS {
 uint32_t cpu_detect(bool);
-bool detect512();
+extern bool enable512;
 
 struct cpu_name_t
 {
