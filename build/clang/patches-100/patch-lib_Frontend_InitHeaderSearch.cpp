$NetBSD: patch-lib_Frontend_InitHeaderSearch.cpp,v 1.2 2018/12/09 20:04:38 adam Exp $

Don't add /usr/local/include by default on Solaris.

diff -wpruN '--exclude=*.orig' a~/lib/Frontend/InitHeaderSearch.cpp a/lib/Frontend/InitHeaderSearch.cpp
--- a~/lib/Frontend/InitHeaderSearch.cpp	1970-01-01 00:00:00
+++ a/lib/Frontend/InitHeaderSearch.cpp	1970-01-01 00:00:00
@@ -231,6 +231,7 @@ void InitHeaderSearch::AddDefaultCInclud
     case llvm::Triple::PS4:
     case llvm::Triple::ELFIAMCU:
     case llvm::Triple::Fuchsia:
+    case llvm::Triple::Solaris:
       break;
     case llvm::Triple::Win32:
       if (triple.getEnvironment() != llvm::Triple::Cygnus)
