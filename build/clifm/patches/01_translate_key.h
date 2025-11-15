diff --git a/src/translate_key.h b/src/translate_key.h
index b1cccf84..1cb59c5c 100644
--- a/src/translate_key.h
+++ b/src/translate_key.h
@@ -40,11 +40,15 @@
 #define CSI_INTRODUCER 0x5b /* [ */
 #define SS3_INTRODUCER 0x4f /* O */
 
-__BEGIN_DECLS
+#ifdef __cplusplus
+extern "C" {
+#endif
 
 char *translate_key(char *str, const int term_type);
 int is_end_seq_char(unsigned char c);
 
-__END_DECLS
+#ifdef __cplusplus
+}
+#endif
 
 #endif /* TRANSLATE_KEY_H */
