$NetBSD: patch-encoder_analysis.cpp,v 1.1 2019/09/18 10:04:51 jperkin Exp $

Ensure std::log() is used.

diff -wpruN '--exclude=*.orig' a~/encoder/analysis.cpp a/source/encoder/analysis.cpp
--- a~/encoder/analysis.cpp	1970-01-01 00:00:00
+++ a/encoder/analysis.cpp	1970-01-01 00:00:00
@@ -2692,8 +2692,8 @@ void Analysis::classifyCU(const CUData&
             {
                 offset = (depth * X265_REFINE_INTER_LEVELS) + i;
                 /* Calculate distance values */
-                diffRefine[i] = abs((int64_t)(trainData.cuVariance - m_frame->m_classifyVariance[offset]));
-                diffRefineRd[i] = abs((int64_t)(cuCost - m_frame->m_classifyRd[offset]));
+                diffRefine[i] = std::abs((int64_t)(trainData.cuVariance - m_frame->m_classifyVariance[offset]));
+                diffRefineRd[i] = std::abs((int64_t)(cuCost - m_frame->m_classifyRd[offset]));
 
                 /* Calculate prior probability - ranges between 0 and 1 */
                 if (trainingCount)
@@ -3548,7 +3548,7 @@ bool Analysis::complexityCheckCU(const M
         mean = mean / (cuSize * cuSize);
         for (uint32_t y = 0; y < cuSize; y++) {
             for (uint32_t x = 0; x < cuSize; x++) {
-                homo += abs(int(bestMode.fencYuv->m_buf[0][y * cuSize + x] - mean));
+                homo += std::abs(int(bestMode.fencYuv->m_buf[0][y * cuSize + x] - mean));
             }
         }
         homo = homo / (cuSize * cuSize);
@@ -3739,7 +3739,7 @@ void Analysis::normFactor(const pixel* s
 
     // 2. Calculate ac component
     uint64_t z_k = 0;
-    int block = (int)(((log(blockSize) / log(2)) - 2) + 0.5);
+    int block = (int)(((std::log(blockSize) / std::log(2)) - 2) + 0.5);
     primitives.cu[block].normFact(src, blockSize, shift, &z_k);
 
     // Remove the DC part
