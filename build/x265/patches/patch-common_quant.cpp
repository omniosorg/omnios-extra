$NetBSD: patch-common_quant.cpp,v 1.2 2019/01/25 09:01:13 adam Exp $

Use enable512 as a global, not through detect512

diff -wpruN '--exclude=*.orig' a~/common/quant.cpp a/source/common/quant.cpp
--- a~/common/quant.cpp	1970-01-01 00:00:00
+++ a/common/quant.cpp	1970-01-01 00:00:00
@@ -708,7 +708,6 @@ uint32_t Quant::rdoQuant(const CUData& c
             uint32_t scanPosBase = (cgScanPos << MLS_CG_SIZE);
             uint32_t blkPos      = codeParams.scan[scanPosBase];
 #if X265_ARCH_X86
-            bool enable512 = detect512();
             if (enable512)
                 primitives.cu[log2TrSize - 2].psyRdoQuant(m_resiDctCoeff, m_fencDctCoeff, costUncoded, &totalUncodedCost, &totalRdCost, &psyScale, blkPos);
             else
@@ -795,7 +794,6 @@ uint32_t Quant::rdoQuant(const CUData& c
             if (usePsyMask)
             {
 #if X265_ARCH_X86
-                bool enable512 = detect512();
                 if (enable512)
                     primitives.cu[log2TrSize - 2].psyRdoQuant(m_resiDctCoeff, m_fencDctCoeff, costUncoded, &totalUncodedCost, &totalRdCost, &psyScale, blkPos);
                 else
