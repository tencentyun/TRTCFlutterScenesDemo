
# 生成intl_messages.arb文件
# flutter pub pub run intl_translation:extract_to_arb --output-dir=i10n-arb lib/i10n/localization_intl.dart

# # 复制生成一份intl_zh_CN.arb文件
# rm i10n-arb/intl_zh_CN.arb
# rm i10n-arb/intl_en_US.arb
# cp i10n-arb/intl_messages.arb i10n-arb/intl_zh_CN.arb
# cp i10n-arb/intl_messages.arb i10n-arb/intl_en_US.arb


#  在文件intl_zh_CN.arb添加 "@@locale":"zh_CN"  ,
#  在文件intl_en_US.arb添加 "@@locale":"en_US"  ,

# 根据.arb文件 生成messages_messages.dart和messages_zh_CN.dart
flutter pub pub run intl_translation:generate_from_arb --output-dir=lib/i10n --no-use-deferred-loading lib/i10n/localization_intl.dart i10n-arb/intl_*.arb

# 把intl_en_US.arb给翻译同学翻译即可