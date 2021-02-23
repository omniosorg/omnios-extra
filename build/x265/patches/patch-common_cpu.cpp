$NetBSD: patch-common_cpu.cpp,v 1.2 2019/01/25 09:01:13 adam Exp $

Retire detect512, make enable512 a global.

diff -wpruN '--exclude=*.orig' a~/common/cpu.cpp a/source/common/cpu.cpp
--- a~/common/cpu.cpp	1970-01-01 00:00:00
+++ a/common/cpu.cpp	1970-01-01 00:00:00
@@ -60,7 +60,7 @@ static void sigill_handler(int sig)
 #endif // if X265_ARCH_ARM
 
 namespace X265_NS {
-static bool enable512 = false;
+bool enable512 = false;
 const cpu_name_t cpu_names[] =
 {
 #if X265_ARCH_X86
@@ -125,10 +125,6 @@ uint64_t PFX(cpu_xgetbv)(int xcr);
 #pragma warning(disable: 4309) // truncation of constant value
 #endif
 
-bool detect512()
-{
-    return(enable512);
-}
 
 uint32_t cpu_detect(bool benableavx512 )
 {
