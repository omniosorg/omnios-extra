$NetBSD: patch-encoder_encoder.cpp,v 1.3 2018/05/25 14:42:07 jperkin Exp $

Fix error: call of overloaded 'pow(int, int)' is ambiguous

diff -wpruN '--exclude=*.orig' a~/encoder/encoder.cpp a/source/encoder/encoder.cpp
--- a~/encoder/encoder.cpp	1970-01-01 00:00:00
+++ a/encoder/encoder.cpp	1970-01-01 00:00:00
@@ -85,6 +85,7 @@ DolbyVisionProfileSpec dovi[] =
 static const char* defaultAnalysisFileName = "x265_analysis.dat";
 
 using namespace X265_NS;
+using std::pow;
 
 Encoder::Encoder()
 {
