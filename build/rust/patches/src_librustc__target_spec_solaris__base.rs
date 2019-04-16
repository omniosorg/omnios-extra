$NetBSD: patch-src_librustc__target_spec_solaris__base.rs,v 1.1 2019/05/31 14:11:23 jperkin Exp $

Enable frame pointers on SunOS.

diff -wpruN '--exclude=*.orig' a~/src/librustc_target/spec/solaris_base.rs a/src/librustc_target/spec/solaris_base.rs
--- a~/src/librustc_target/spec/solaris_base.rs	1970-01-01 00:00:00
+++ a/src/librustc_target/spec/solaris_base.rs	1970-01-01 00:00:00
@@ -8,6 +8,7 @@ pub fn opts() -> TargetOptions {
         has_rpath: true,
         target_family: Some("unix".to_string()),
         is_like_solaris: true,
+        eliminate_frame_pointer: false,
 
         .. Default::default()
     }
