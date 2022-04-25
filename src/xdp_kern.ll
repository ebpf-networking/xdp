; ModuleID = 'xdp_kern.c'
source_filename = "xdp_kern.c"
target datalayout = "e-m:e-p:64:64-i64:64-i128:128-n32:64-S128"
target triple = "bpf"

%struct.bpf_map_def = type { i32, i32, i32, i32, i32 }
%struct.xdp_md = type { i32, i32, i32, i32, i32, i32 }
%struct.datarec = type { i64, i64 }
%struct.ethhdr = type { [6 x i8], [6 x i8], i16 }
%struct.iphdr = type { i8, i8, i16, i16, i16, i8, i8, i16, i32, i32 }

@xdp_stats_map = dso_local global %struct.bpf_map_def { i32 5, i32 4, i32 16, i32 256, i32 0 }, section "maps", align 4, !dbg !0
@_license = dso_local global [4 x i8] c"GPL\00", section "license", align 1, !dbg !21
@llvm.compiler.used = appending global [3 x i8*] [i8* getelementptr inbounds ([4 x i8], [4 x i8]* @_license, i32 0, i32 0), i8* bitcast (%struct.bpf_map_def* @xdp_stats_map to i8*), i8* bitcast (i32 (%struct.xdp_md*)* @xdp_stats_prog to i8*)], section "llvm.metadata"

; Function Attrs: nounwind
define dso_local i32 @xdp_stats_prog(%struct.xdp_md* nocapture readonly %0) #0 section "xdp_stats" !dbg !55 {
  %2 = alloca i32, align 4
  %3 = alloca %struct.datarec, align 8
  call void @llvm.dbg.value(metadata %struct.xdp_md* %0, metadata !70, metadata !DIExpression()), !dbg !79
  %4 = getelementptr inbounds %struct.xdp_md, %struct.xdp_md* %0, i64 0, i32 0, !dbg !80
  %5 = load i32, i32* %4, align 4, !dbg !80, !tbaa !81
  %6 = zext i32 %5 to i64, !dbg !86
  call void @llvm.dbg.value(metadata i64 %6, metadata !71, metadata !DIExpression()), !dbg !79
  %7 = getelementptr inbounds %struct.xdp_md, %struct.xdp_md* %0, i64 0, i32 1, !dbg !87
  %8 = load i32, i32* %7, align 4, !dbg !87, !tbaa !88
  %9 = zext i32 %8 to i64, !dbg !89
  call void @llvm.dbg.value(metadata i64 %9, metadata !72, metadata !DIExpression()), !dbg !79
  call void @llvm.dbg.value(metadata i32 2, metadata !77, metadata !DIExpression()), !dbg !79
  call void @llvm.dbg.value(metadata i8** undef, metadata !90, metadata !DIExpression()), !dbg !110
  call void @llvm.dbg.value(metadata i64 %9, metadata !96, metadata !DIExpression()), !dbg !110
  %10 = inttoptr i64 %6 to %struct.ethhdr*, !dbg !112
  call void @llvm.dbg.value(metadata %struct.ethhdr* %10, metadata !97, metadata !DIExpression()), !dbg !110
  %11 = getelementptr inbounds %struct.ethhdr, %struct.ethhdr* %10, i64 1, !dbg !113
  %12 = inttoptr i64 %9 to %struct.ethhdr*, !dbg !115
  %13 = icmp ugt %struct.ethhdr* %11, %12, !dbg !116
  br i1 %13, label %54, label %14, !dbg !117

14:                                               ; preds = %1
  %15 = getelementptr inbounds %struct.ethhdr, %struct.ethhdr* %10, i64 0, i32 2, !dbg !118
  %16 = load i16, i16* %15, align 1, !dbg !118, !tbaa !119
  call void @llvm.dbg.value(metadata i16 %16, metadata !109, metadata !DIExpression()), !dbg !110
  call void @llvm.dbg.value(metadata i16 %16, metadata !73, metadata !DIExpression(DW_OP_LLVM_convert, 16, DW_ATE_unsigned, DW_OP_LLVM_convert, 32, DW_ATE_unsigned, DW_OP_stack_value)), !dbg !79
  %17 = icmp eq i16 %16, 8, !dbg !122
  br i1 %17, label %18, label %54, !dbg !124

18:                                               ; preds = %14
  call void @llvm.dbg.value(metadata i8** undef, metadata !125, metadata !DIExpression()), !dbg !152
  call void @llvm.dbg.value(metadata i64 %9, metadata !131, metadata !DIExpression()), !dbg !152
  call void @llvm.dbg.value(metadata i32* undef, metadata !132, metadata !DIExpression()), !dbg !152
  call void @llvm.dbg.value(metadata %struct.ethhdr* %11, metadata !133, metadata !DIExpression()), !dbg !152
  %19 = getelementptr inbounds %struct.ethhdr, %struct.ethhdr* %10, i64 2, i32 1, !dbg !154
  %20 = bitcast [6 x i8]* %19 to %struct.iphdr*, !dbg !154
  %21 = inttoptr i64 %9 to %struct.iphdr*, !dbg !156
  %22 = icmp ugt %struct.iphdr* %20, %21, !dbg !157
  br i1 %22, label %27, label %23, !dbg !158

23:                                               ; preds = %18
  call void @llvm.dbg.value(metadata %struct.ethhdr* %11, metadata !133, metadata !DIExpression()), !dbg !152
  %24 = getelementptr inbounds %struct.ethhdr, %struct.ethhdr* %10, i64 1, i32 2, !dbg !159
  %25 = bitcast i16* %24 to i32*, !dbg !159
  %26 = load i32, i32* %25, align 4, !dbg !159, !tbaa !160
  br label %27, !dbg !162

27:                                               ; preds = %18, %23
  %28 = phi i32 [ undef, %18 ], [ %26, %23 ]
  call void @llvm.dbg.value(metadata i32 undef, metadata !73, metadata !DIExpression(DW_OP_LLVM_convert, 32, DW_ATE_unsigned, DW_OP_LLVM_convert, 16, DW_ATE_unsigned, DW_OP_stack_value)), !dbg !79
  call void @llvm.dbg.value(metadata i32 %28, metadata !76, metadata !DIExpression()), !dbg !79
  %29 = bitcast i32* %2 to i8*, !dbg !163
  call void @llvm.lifetime.start.p0i8(i64 4, i8* nonnull %29), !dbg !163
  call void @llvm.dbg.value(metadata %struct.xdp_md* %0, metadata !168, metadata !DIExpression()) #4, !dbg !163
  call void @llvm.dbg.value(metadata i32 %28, metadata !169, metadata !DIExpression()) #4, !dbg !163
  store i32 %28, i32* %2, align 4, !tbaa !180
  call void @llvm.dbg.value(metadata i32* %2, metadata !169, metadata !DIExpression(DW_OP_deref)) #4, !dbg !163
  %30 = call i8* inttoptr (i64 1 to i8* (i8*, i8*)*)(i8* bitcast (%struct.bpf_map_def* @xdp_stats_map to i8*), i8* nonnull %29) #4, !dbg !181
  call void @llvm.dbg.value(metadata i8* %30, metadata !170, metadata !DIExpression()) #4, !dbg !163
  %31 = icmp eq i8* %30, null, !dbg !182
  br i1 %31, label %32, label %41, !dbg !183

32:                                               ; preds = %27
  %33 = bitcast %struct.datarec* %3 to i8*, !dbg !184
  call void @llvm.lifetime.start.p0i8(i64 16, i8* nonnull %33) #4, !dbg !184
  call void @llvm.dbg.declare(metadata %struct.datarec* %3, metadata !176, metadata !DIExpression()) #4, !dbg !185
  %34 = getelementptr inbounds %struct.datarec, %struct.datarec* %3, i64 0, i32 0, !dbg !186
  store i64 1, i64* %34, align 8, !dbg !187, !tbaa !188
  %35 = load i32, i32* %7, align 4, !dbg !191, !tbaa !88
  %36 = load i32, i32* %4, align 4, !dbg !192, !tbaa !81
  %37 = sub i32 %35, %36, !dbg !193
  %38 = zext i32 %37 to i64, !dbg !194
  %39 = getelementptr inbounds %struct.datarec, %struct.datarec* %3, i64 0, i32 1, !dbg !195
  store i64 %38, i64* %39, align 8, !dbg !196, !tbaa !197
  call void @llvm.dbg.value(metadata i32* %2, metadata !169, metadata !DIExpression(DW_OP_deref)) #4, !dbg !163
  %40 = call i64 inttoptr (i64 2 to i64 (i8*, i8*, i8*, i64)*)(i8* bitcast (%struct.bpf_map_def* @xdp_stats_map to i8*), i8* nonnull %29, i8* nonnull %33, i64 0) #4, !dbg !198
  call void @llvm.lifetime.end.p0i8(i64 16, i8* nonnull %33) #4, !dbg !199
  br label %53

41:                                               ; preds = %27
  call void @llvm.dbg.value(metadata i8* %30, metadata !170, metadata !DIExpression()) #4, !dbg !163
  %42 = bitcast i8* %30 to i64*, !dbg !200
  %43 = load i64, i64* %42, align 8, !dbg !201, !tbaa !188
  %44 = add i64 %43, 1, !dbg !201
  store i64 %44, i64* %42, align 8, !dbg !201, !tbaa !188
  %45 = load i32, i32* %7, align 4, !dbg !202, !tbaa !88
  %46 = load i32, i32* %4, align 4, !dbg !203, !tbaa !81
  %47 = sub i32 %45, %46, !dbg !204
  %48 = zext i32 %47 to i64, !dbg !205
  %49 = getelementptr inbounds i8, i8* %30, i64 8, !dbg !206
  %50 = bitcast i8* %49 to i64*, !dbg !206
  %51 = load i64, i64* %50, align 8, !dbg !207, !tbaa !197
  %52 = add i64 %51, %48, !dbg !207
  store i64 %52, i64* %50, align 8, !dbg !207, !tbaa !197
  br label %53, !dbg !208

53:                                               ; preds = %32, %41
  call void @llvm.lifetime.end.p0i8(i64 4, i8* nonnull %29), !dbg !209
  br label %54, !dbg !210

54:                                               ; preds = %1, %14, %53
  call void @llvm.dbg.label(metadata !78), !dbg !211
  ret i32 2, !dbg !212
}

; Function Attrs: mustprogress nofree nosync nounwind readnone speculatable willreturn
declare void @llvm.dbg.declare(metadata, metadata, metadata) #1

; Function Attrs: argmemonly mustprogress nofree nosync nounwind willreturn
declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture) #2

; Function Attrs: mustprogress nofree nosync nounwind readnone speculatable willreturn
declare void @llvm.dbg.label(metadata) #1

; Function Attrs: argmemonly mustprogress nofree nosync nounwind willreturn
declare void @llvm.lifetime.end.p0i8(i64 immarg, i8* nocapture) #2

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare void @llvm.dbg.value(metadata, metadata, metadata) #3

attributes #0 = { nounwind "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" }
attributes #1 = { mustprogress nofree nosync nounwind readnone speculatable willreturn }
attributes #2 = { argmemonly mustprogress nofree nosync nounwind willreturn }
attributes #3 = { nofree nosync nounwind readnone speculatable willreturn }
attributes #4 = { nounwind }

!llvm.dbg.cu = !{!2}
!llvm.module.flags = !{!50, !51, !52, !53}
!llvm.ident = !{!54}

!0 = !DIGlobalVariableExpression(var: !1, expr: !DIExpression())
!1 = distinct !DIGlobalVariable(name: "xdp_stats_map", scope: !2, file: !3, line: 14, type: !42, isLocal: false, isDefinition: true)
!2 = distinct !DICompileUnit(language: DW_LANG_C99, file: !3, producer: "clang version 13.0.0 (Fedora 13.0.0-3.fc35)", isOptimized: true, runtimeVersion: 0, emissionKind: FullDebug, enums: !4, retainedTypes: !14, globals: !20, splitDebugInlining: false, nameTableKind: None)
!3 = !DIFile(filename: "xdp_kern.c", directory: "/root/ebpf/src")
!4 = !{!5}
!5 = !DICompositeType(tag: DW_TAG_enumeration_type, name: "xdp_action", file: !6, line: 5497, baseType: !7, size: 32, elements: !8)
!6 = !DIFile(filename: "/usr/include/linux/bpf.h", directory: "")
!7 = !DIBasicType(name: "unsigned int", size: 32, encoding: DW_ATE_unsigned)
!8 = !{!9, !10, !11, !12, !13}
!9 = !DIEnumerator(name: "XDP_ABORTED", value: 0)
!10 = !DIEnumerator(name: "XDP_DROP", value: 1)
!11 = !DIEnumerator(name: "XDP_PASS", value: 2)
!12 = !DIEnumerator(name: "XDP_TX", value: 3)
!13 = !DIEnumerator(name: "XDP_REDIRECT", value: 4)
!14 = !{!15, !16, !17}
!15 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: null, size: 64)
!16 = !DIBasicType(name: "long int", size: 64, encoding: DW_ATE_signed)
!17 = !DIDerivedType(tag: DW_TAG_typedef, name: "__u16", file: !18, line: 24, baseType: !19)
!18 = !DIFile(filename: "/usr/include/asm-generic/int-ll64.h", directory: "")
!19 = !DIBasicType(name: "unsigned short", size: 16, encoding: DW_ATE_unsigned)
!20 = !{!0, !21, !27, !35}
!21 = !DIGlobalVariableExpression(var: !22, expr: !DIExpression())
!22 = distinct !DIGlobalVariable(name: "_license", scope: !2, file: !3, line: 87, type: !23, isLocal: false, isDefinition: true)
!23 = !DICompositeType(tag: DW_TAG_array_type, baseType: !24, size: 32, elements: !25)
!24 = !DIBasicType(name: "char", size: 8, encoding: DW_ATE_signed_char)
!25 = !{!26}
!26 = !DISubrange(count: 4)
!27 = !DIGlobalVariableExpression(var: !28, expr: !DIExpression())
!28 = distinct !DIGlobalVariable(name: "bpf_map_lookup_elem", scope: !2, file: !29, line: 49, type: !30, isLocal: true, isDefinition: true)
!29 = !DIFile(filename: "/usr/include/bpf/bpf_helper_defs.h", directory: "")
!30 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !31, size: 64)
!31 = !DISubroutineType(types: !32)
!32 = !{!15, !15, !33}
!33 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !34, size: 64)
!34 = !DIDerivedType(tag: DW_TAG_const_type, baseType: null)
!35 = !DIGlobalVariableExpression(var: !36, expr: !DIExpression())
!36 = distinct !DIGlobalVariable(name: "bpf_map_update_elem", scope: !2, file: !29, line: 71, type: !37, isLocal: true, isDefinition: true)
!37 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !38, size: 64)
!38 = !DISubroutineType(types: !39)
!39 = !{!16, !15, !33, !33, !40}
!40 = !DIDerivedType(tag: DW_TAG_typedef, name: "__u64", file: !18, line: 31, baseType: !41)
!41 = !DIBasicType(name: "long long unsigned int", size: 64, encoding: DW_ATE_unsigned)
!42 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "bpf_map_def", file: !43, line: 138, size: 160, elements: !44)
!43 = !DIFile(filename: "/usr/include/bpf/bpf_helpers.h", directory: "")
!44 = !{!45, !46, !47, !48, !49}
!45 = !DIDerivedType(tag: DW_TAG_member, name: "type", scope: !42, file: !43, line: 139, baseType: !7, size: 32)
!46 = !DIDerivedType(tag: DW_TAG_member, name: "key_size", scope: !42, file: !43, line: 140, baseType: !7, size: 32, offset: 32)
!47 = !DIDerivedType(tag: DW_TAG_member, name: "value_size", scope: !42, file: !43, line: 141, baseType: !7, size: 32, offset: 64)
!48 = !DIDerivedType(tag: DW_TAG_member, name: "max_entries", scope: !42, file: !43, line: 142, baseType: !7, size: 32, offset: 96)
!49 = !DIDerivedType(tag: DW_TAG_member, name: "map_flags", scope: !42, file: !43, line: 143, baseType: !7, size: 32, offset: 128)
!50 = !{i32 7, !"Dwarf Version", i32 4}
!51 = !{i32 2, !"Debug Info Version", i32 3}
!52 = !{i32 1, !"wchar_size", i32 4}
!53 = !{i32 7, !"frame-pointer", i32 2}
!54 = !{!"clang version 13.0.0 (Fedora 13.0.0-3.fc35)"}
!55 = distinct !DISubprogram(name: "xdp_stats_prog", scope: !3, file: !3, line: 65, type: !56, scopeLine: 66, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !2, retainedNodes: !69)
!56 = !DISubroutineType(types: !57)
!57 = !{!58, !59}
!58 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!59 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !60, size: 64)
!60 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "xdp_md", file: !6, line: 5508, size: 192, elements: !61)
!61 = !{!62, !64, !65, !66, !67, !68}
!62 = !DIDerivedType(tag: DW_TAG_member, name: "data", scope: !60, file: !6, line: 5509, baseType: !63, size: 32)
!63 = !DIDerivedType(tag: DW_TAG_typedef, name: "__u32", file: !18, line: 27, baseType: !7)
!64 = !DIDerivedType(tag: DW_TAG_member, name: "data_end", scope: !60, file: !6, line: 5510, baseType: !63, size: 32, offset: 32)
!65 = !DIDerivedType(tag: DW_TAG_member, name: "data_meta", scope: !60, file: !6, line: 5511, baseType: !63, size: 32, offset: 64)
!66 = !DIDerivedType(tag: DW_TAG_member, name: "ingress_ifindex", scope: !60, file: !6, line: 5513, baseType: !63, size: 32, offset: 96)
!67 = !DIDerivedType(tag: DW_TAG_member, name: "rx_queue_index", scope: !60, file: !6, line: 5514, baseType: !63, size: 32, offset: 128)
!68 = !DIDerivedType(tag: DW_TAG_member, name: "egress_ifindex", scope: !60, file: !6, line: 5516, baseType: !63, size: 32, offset: 160)
!69 = !{!70, !71, !72, !73, !76, !77, !78}
!70 = !DILocalVariable(name: "ctx", arg: 1, scope: !55, file: !3, line: 65, type: !59)
!71 = !DILocalVariable(name: "data", scope: !55, file: !3, line: 67, type: !15)
!72 = !DILocalVariable(name: "data_end", scope: !55, file: !3, line: 68, type: !15)
!73 = !DILocalVariable(name: "header_type", scope: !55, file: !3, line: 69, type: !74)
!74 = !DIDerivedType(tag: DW_TAG_typedef, name: "__be16", file: !75, line: 25, baseType: !17)
!75 = !DIFile(filename: "/usr/include/linux/types.h", directory: "")
!76 = !DILocalVariable(name: "saddr", scope: !55, file: !3, line: 70, type: !63)
!77 = !DILocalVariable(name: "action", scope: !55, file: !3, line: 72, type: !63)
!78 = !DILabel(scope: !55, name: "out", file: !3, line: 83)
!79 = !DILocation(line: 0, scope: !55)
!80 = !DILocation(line: 67, column: 34, scope: !55)
!81 = !{!82, !83, i64 0}
!82 = !{!"xdp_md", !83, i64 0, !83, i64 4, !83, i64 8, !83, i64 12, !83, i64 16, !83, i64 20}
!83 = !{!"int", !84, i64 0}
!84 = !{!"omnipotent char", !85, i64 0}
!85 = !{!"Simple C/C++ TBAA"}
!86 = !DILocation(line: 67, column: 23, scope: !55)
!87 = !DILocation(line: 68, column: 38, scope: !55)
!88 = !{!82, !83, i64 4}
!89 = !DILocation(line: 68, column: 27, scope: !55)
!90 = !DILocalVariable(name: "data", arg: 1, scope: !91, file: !3, line: 21, type: !94)
!91 = distinct !DISubprogram(name: "parse_ethhdr", scope: !3, file: !3, line: 21, type: !92, scopeLine: 22, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition | DISPFlagOptimized, unit: !2, retainedNodes: !95)
!92 = !DISubroutineType(types: !93)
!93 = !{!58, !94, !15}
!94 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !15, size: 64)
!95 = !{!90, !96, !97, !109}
!96 = !DILocalVariable(name: "data_end", arg: 2, scope: !91, file: !3, line: 22, type: !15)
!97 = !DILocalVariable(name: "eth", scope: !91, file: !3, line: 23, type: !98)
!98 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !99, size: 64)
!99 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "ethhdr", file: !100, line: 169, size: 112, elements: !101)
!100 = !DIFile(filename: "/usr/include/linux/if_ether.h", directory: "")
!101 = !{!102, !107, !108}
!102 = !DIDerivedType(tag: DW_TAG_member, name: "h_dest", scope: !99, file: !100, line: 170, baseType: !103, size: 48)
!103 = !DICompositeType(tag: DW_TAG_array_type, baseType: !104, size: 48, elements: !105)
!104 = !DIBasicType(name: "unsigned char", size: 8, encoding: DW_ATE_unsigned_char)
!105 = !{!106}
!106 = !DISubrange(count: 6)
!107 = !DIDerivedType(tag: DW_TAG_member, name: "h_source", scope: !99, file: !100, line: 171, baseType: !103, size: 48, offset: 48)
!108 = !DIDerivedType(tag: DW_TAG_member, name: "h_proto", scope: !99, file: !100, line: 172, baseType: !74, size: 16, offset: 96)
!109 = !DILocalVariable(name: "header_type", scope: !91, file: !3, line: 24, type: !74)
!110 = !DILocation(line: 0, scope: !91, inlinedAt: !111)
!111 = distinct !DILocation(line: 74, column: 16, scope: !55)
!112 = !DILocation(line: 23, column: 23, scope: !91, inlinedAt: !111)
!113 = !DILocation(line: 26, column: 10, scope: !114, inlinedAt: !111)
!114 = distinct !DILexicalBlock(scope: !91, file: !3, line: 26, column: 6)
!115 = !DILocation(line: 26, column: 16, scope: !114, inlinedAt: !111)
!116 = !DILocation(line: 26, column: 14, scope: !114, inlinedAt: !111)
!117 = !DILocation(line: 26, column: 6, scope: !91, inlinedAt: !111)
!118 = !DILocation(line: 29, column: 21, scope: !91, inlinedAt: !111)
!119 = !{!120, !121, i64 12}
!120 = !{!"ethhdr", !84, i64 0, !84, i64 6, !121, i64 12}
!121 = !{!"short", !84, i64 0}
!122 = !DILocation(line: 75, column: 18, scope: !123)
!123 = distinct !DILexicalBlock(scope: !55, file: !3, line: 75, column: 6)
!124 = !DILocation(line: 75, column: 6, scope: !55)
!125 = !DILocalVariable(name: "data", arg: 1, scope: !126, file: !3, line: 34, type: !94)
!126 = distinct !DISubprogram(name: "parse_iphdr", scope: !3, file: !3, line: 34, type: !127, scopeLine: 36, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition | DISPFlagOptimized, unit: !2, retainedNodes: !130)
!127 = !DISubroutineType(types: !128)
!128 = !{!58, !94, !15, !129}
!129 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !63, size: 64)
!130 = !{!125, !131, !132, !133}
!131 = !DILocalVariable(name: "data_end", arg: 2, scope: !126, file: !3, line: 35, type: !15)
!132 = !DILocalVariable(name: "saddr", arg: 3, scope: !126, file: !3, line: 36, type: !129)
!133 = !DILocalVariable(name: "ip", scope: !126, file: !3, line: 37, type: !134)
!134 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !135, size: 64)
!135 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "iphdr", file: !136, line: 86, size: 160, elements: !137)
!136 = !DIFile(filename: "/usr/include/linux/ip.h", directory: "")
!137 = !{!138, !140, !141, !142, !143, !144, !145, !146, !147, !149, !151}
!138 = !DIDerivedType(tag: DW_TAG_member, name: "ihl", scope: !135, file: !136, line: 88, baseType: !139, size: 4, flags: DIFlagBitField, extraData: i64 0)
!139 = !DIDerivedType(tag: DW_TAG_typedef, name: "__u8", file: !18, line: 21, baseType: !104)
!140 = !DIDerivedType(tag: DW_TAG_member, name: "version", scope: !135, file: !136, line: 89, baseType: !139, size: 4, offset: 4, flags: DIFlagBitField, extraData: i64 0)
!141 = !DIDerivedType(tag: DW_TAG_member, name: "tos", scope: !135, file: !136, line: 96, baseType: !139, size: 8, offset: 8)
!142 = !DIDerivedType(tag: DW_TAG_member, name: "tot_len", scope: !135, file: !136, line: 97, baseType: !74, size: 16, offset: 16)
!143 = !DIDerivedType(tag: DW_TAG_member, name: "id", scope: !135, file: !136, line: 98, baseType: !74, size: 16, offset: 32)
!144 = !DIDerivedType(tag: DW_TAG_member, name: "frag_off", scope: !135, file: !136, line: 99, baseType: !74, size: 16, offset: 48)
!145 = !DIDerivedType(tag: DW_TAG_member, name: "ttl", scope: !135, file: !136, line: 100, baseType: !139, size: 8, offset: 64)
!146 = !DIDerivedType(tag: DW_TAG_member, name: "protocol", scope: !135, file: !136, line: 101, baseType: !139, size: 8, offset: 72)
!147 = !DIDerivedType(tag: DW_TAG_member, name: "check", scope: !135, file: !136, line: 102, baseType: !148, size: 16, offset: 80)
!148 = !DIDerivedType(tag: DW_TAG_typedef, name: "__sum16", file: !75, line: 31, baseType: !17)
!149 = !DIDerivedType(tag: DW_TAG_member, name: "saddr", scope: !135, file: !136, line: 103, baseType: !150, size: 32, offset: 96)
!150 = !DIDerivedType(tag: DW_TAG_typedef, name: "__be32", file: !75, line: 27, baseType: !63)
!151 = !DIDerivedType(tag: DW_TAG_member, name: "daddr", scope: !135, file: !136, line: 104, baseType: !150, size: 32, offset: 128)
!152 = !DILocation(line: 0, scope: !126, inlinedAt: !153)
!153 = distinct !DILocation(line: 78, column: 16, scope: !55)
!154 = !DILocation(line: 38, column: 9, scope: !155, inlinedAt: !153)
!155 = distinct !DILexicalBlock(scope: !126, file: !3, line: 38, column: 6)
!156 = !DILocation(line: 38, column: 15, scope: !155, inlinedAt: !153)
!157 = !DILocation(line: 38, column: 13, scope: !155, inlinedAt: !153)
!158 = !DILocation(line: 38, column: 6, scope: !126, inlinedAt: !153)
!159 = !DILocation(line: 41, column: 15, scope: !126, inlinedAt: !153)
!160 = !{!161, !83, i64 12}
!161 = !{!"iphdr", !84, i64 0, !84, i64 0, !84, i64 1, !121, i64 2, !121, i64 4, !121, i64 6, !84, i64 8, !84, i64 9, !121, i64 10, !83, i64 12, !83, i64 16}
!162 = !DILocation(line: 43, column: 2, scope: !126, inlinedAt: !153)
!163 = !DILocation(line: 0, scope: !164, inlinedAt: !179)
!164 = distinct !DISubprogram(name: "xdp_stats_record", scope: !3, file: !3, line: 46, type: !165, scopeLine: 47, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition | DISPFlagOptimized, unit: !2, retainedNodes: !167)
!165 = !DISubroutineType(types: !166)
!166 = !{null, !59, !63}
!167 = !{!168, !169, !170, !176}
!168 = !DILocalVariable(name: "ctx", arg: 1, scope: !164, file: !3, line: 46, type: !59)
!169 = !DILocalVariable(name: "saddr", arg: 2, scope: !164, file: !3, line: 47, type: !63)
!170 = !DILocalVariable(name: "datarec", scope: !164, file: !3, line: 48, type: !171)
!171 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !172, size: 64)
!172 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "datarec", file: !3, line: 9, size: 128, elements: !173)
!173 = !{!174, !175}
!174 = !DIDerivedType(tag: DW_TAG_member, name: "packets", scope: !172, file: !3, line: 10, baseType: !40, size: 64)
!175 = !DIDerivedType(tag: DW_TAG_member, name: "bytes", scope: !172, file: !3, line: 11, baseType: !40, size: 64, offset: 64)
!176 = !DILocalVariable(name: "d", scope: !177, file: !3, line: 50, type: !172)
!177 = distinct !DILexicalBlock(scope: !178, file: !3, line: 49, column: 16)
!178 = distinct !DILexicalBlock(scope: !164, file: !3, line: 49, column: 6)
!179 = distinct !DILocation(line: 82, column: 2, scope: !55)
!180 = !{!83, !83, i64 0}
!181 = !DILocation(line: 48, column: 28, scope: !164, inlinedAt: !179)
!182 = !DILocation(line: 49, column: 7, scope: !178, inlinedAt: !179)
!183 = !DILocation(line: 49, column: 6, scope: !164, inlinedAt: !179)
!184 = !DILocation(line: 50, column: 3, scope: !177, inlinedAt: !179)
!185 = !DILocation(line: 50, column: 18, scope: !177, inlinedAt: !179)
!186 = !DILocation(line: 51, column: 5, scope: !177, inlinedAt: !179)
!187 = !DILocation(line: 51, column: 13, scope: !177, inlinedAt: !179)
!188 = !{!189, !190, i64 0}
!189 = !{!"datarec", !190, i64 0, !190, i64 8}
!190 = !{!"long long", !84, i64 0}
!191 = !DILocation(line: 52, column: 19, scope: !177, inlinedAt: !179)
!192 = !DILocation(line: 52, column: 35, scope: !177, inlinedAt: !179)
!193 = !DILocation(line: 52, column: 28, scope: !177, inlinedAt: !179)
!194 = !DILocation(line: 52, column: 13, scope: !177, inlinedAt: !179)
!195 = !DILocation(line: 52, column: 5, scope: !177, inlinedAt: !179)
!196 = !DILocation(line: 52, column: 11, scope: !177, inlinedAt: !179)
!197 = !{!189, !190, i64 8}
!198 = !DILocation(line: 53, column: 3, scope: !177, inlinedAt: !179)
!199 = !DILocation(line: 56, column: 2, scope: !178, inlinedAt: !179)
!200 = !DILocation(line: 58, column: 11, scope: !164, inlinedAt: !179)
!201 = !DILocation(line: 58, column: 18, scope: !164, inlinedAt: !179)
!202 = !DILocation(line: 59, column: 26, scope: !164, inlinedAt: !179)
!203 = !DILocation(line: 59, column: 42, scope: !164, inlinedAt: !179)
!204 = !DILocation(line: 59, column: 35, scope: !164, inlinedAt: !179)
!205 = !DILocation(line: 59, column: 20, scope: !164, inlinedAt: !179)
!206 = !DILocation(line: 59, column: 11, scope: !164, inlinedAt: !179)
!207 = !DILocation(line: 59, column: 17, scope: !164, inlinedAt: !179)
!208 = !DILocation(line: 61, column: 2, scope: !164, inlinedAt: !179)
!209 = !DILocation(line: 62, column: 1, scope: !164, inlinedAt: !179)
!210 = !DILocation(line: 82, column: 2, scope: !55)
!211 = !DILocation(line: 83, column: 1, scope: !55)
!212 = !DILocation(line: 84, column: 2, scope: !55)
