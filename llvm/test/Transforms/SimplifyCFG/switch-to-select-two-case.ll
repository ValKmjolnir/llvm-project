; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -passes=simplifycfg -simplifycfg-require-and-preserve-domtree=1 -S | FileCheck %s

; int foo1_with_default(int a) {
;   switch(a) {
;     case 10:
;       return 10;
;     case 20:
;       return 2;
;   }
;   return 4;
; }

define i32 @foo1_with_default(i32 %a) {
; CHECK-LABEL: @foo1_with_default(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[SWITCH_SELECTCMP:%.*]] = icmp eq i32 [[A:%.*]], 20
; CHECK-NEXT:    [[SWITCH_SELECT:%.*]] = select i1 [[SWITCH_SELECTCMP]], i32 2, i32 4
; CHECK-NEXT:    [[SWITCH_SELECTCMP1:%.*]] = icmp eq i32 [[A]], 10
; CHECK-NEXT:    [[SWITCH_SELECT2:%.*]] = select i1 [[SWITCH_SELECTCMP1]], i32 10, i32 [[SWITCH_SELECT]]
; CHECK-NEXT:    ret i32 [[SWITCH_SELECT2]]
;
entry:
  switch i32 %a, label %sw.epilog [
  i32 10, label %sw.bb
  i32 20, label %sw.bb1
  ]

sw.bb:
  br label %return

sw.bb1:
  br label %return

sw.epilog:
  br label %return

return:
  %retval.0 = phi i32 [ 4, %sw.epilog ], [ 2, %sw.bb1 ], [ 10, %sw.bb ]
  ret i32 %retval.0
}

; Same as above, but both cases have the same value.
define i32 @same_value(i32 %a) {
; CHECK-LABEL: @same_value(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[SWITCH_SELECTCMP_CASE1:%.*]] = icmp eq i32 [[A:%.*]], 10
; CHECK-NEXT:    [[SWITCH_SELECTCMP_CASE2:%.*]] = icmp eq i32 [[A]], 20
; CHECK-NEXT:    [[SWITCH_SELECTCMP:%.*]] = or i1 [[SWITCH_SELECTCMP_CASE1]], [[SWITCH_SELECTCMP_CASE2]]
; CHECK-NEXT:    [[TMP0:%.*]] = select i1 [[SWITCH_SELECTCMP]], i32 10, i32 4
; CHECK-NEXT:    ret i32 [[TMP0]]
;
entry:
  switch i32 %a, label %sw.epilog [
  i32 10, label %sw.bb
  i32 20, label %sw.bb
  ]

sw.bb:
  br label %return

sw.epilog:
  br label %return

return:
  %retval.0 = phi i32 [ 4, %sw.epilog ], [ 10, %sw.bb ]
  ret i32 %retval.0
}

define i1 @switch_to_select_same2_case_results_different_default(i8 %0) {
; CHECK-LABEL: @switch_to_select_same2_case_results_different_default(
; CHECK-NEXT:    [[SWITCH_AND:%.*]] = and i8 [[TMP0:%.*]], -5
; CHECK-NEXT:    [[SWITCH_SELECTCMP:%.*]] = icmp eq i8 [[SWITCH_AND]], 0
; CHECK-NEXT:    [[TMP2:%.*]] = select i1 [[SWITCH_SELECTCMP]], i1 true, i1 false
; CHECK-NEXT:    ret i1 [[TMP2]]
;
  switch i8 %0, label %2 [
  i8 4, label %3
  i8 0, label %3
  ]

2:
  br label %3

3:
  %4 = phi i1 [ false, %2 ], [ true, %1 ], [ true, %1 ]
  ret i1 %4
}

define i1 @switch_to_select_same2_case_results_different_default_and_positive_offset_for_case(i8 %0) {
; CHECK-LABEL: @switch_to_select_same2_case_results_different_default_and_positive_offset_for_case(
; CHECK-NEXT:    [[TMP2:%.*]] = sub i8 [[TMP0:%.*]], 43
; CHECK-NEXT:    [[SWITCH_AND:%.*]] = and i8 [[TMP2]], -3
; CHECK-NEXT:    [[SWITCH_SELECTCMP:%.*]] = icmp eq i8 [[SWITCH_AND]], 0
; CHECK-NEXT:    [[TMP3:%.*]] = select i1 [[SWITCH_SELECTCMP]], i1 true, i1 false
; CHECK-NEXT:    ret i1 [[TMP3]]
;
  switch i8 %0, label %2 [
  i8 43, label %3
  i8 45, label %3
  ]

2:
  br label %3

3:
  %4 = phi i1 [ false, %2 ], [ true, %1 ], [ true, %1 ]
  ret i1 %4
}

define i8 @switch_to_select_same2_case_results_different_default_and_negative_offset_for_case(i32 %i) {
; CHECK-LABEL: @switch_to_select_same2_case_results_different_default_and_negative_offset_for_case(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[TMP0:%.*]] = sub i32 [[I:%.*]], -5
; CHECK-NEXT:    [[SWITCH_AND:%.*]] = and i32 [[TMP0]], -3
; CHECK-NEXT:    [[SWITCH_SELECTCMP:%.*]] = icmp eq i32 [[SWITCH_AND]], 0
; CHECK-NEXT:    [[TMP1:%.*]] = select i1 [[SWITCH_SELECTCMP]], i8 3, i8 42
; CHECK-NEXT:    ret i8 [[TMP1]]
;
entry:
  switch i32 %i, label %default [
  i32 -3, label %end
  i32 -5, label %end
  ]

default:
  br label %end

end:
  %t0 = phi i8 [ 42, %default ], [ 3, %entry ], [ 3, %entry ]
  ret i8 %t0
}

define i1 @switch_to_select_same4_case_results_different_default(i32 %i) {
; CHECK-LABEL: @switch_to_select_same4_case_results_different_default(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[SWITCH_AND:%.*]] = and i32 [[I:%.*]], -7
; CHECK-NEXT:    [[SWITCH_SELECTCMP:%.*]] = icmp eq i32 [[SWITCH_AND]], 0
; CHECK-NEXT:    [[TMP0:%.*]] = select i1 [[SWITCH_SELECTCMP]], i1 true, i1 false
; CHECK-NEXT:    ret i1 [[TMP0]]
;
entry:
  switch i32 %i, label %lor.rhs [
  i32 0, label %lor.end
  i32 2, label %lor.end
  i32 4, label %lor.end
  i32 6, label %lor.end
  ]

lor.rhs:
  br label %lor.end

lor.end:
  %0 = phi i1 [ true, %entry ], [ false, %lor.rhs ], [ true, %entry ], [ true, %entry ], [ true, %entry ]
  ret i1 %0
}

define i1 @switch_to_select_same4_case_results_different_default_alt_bitmask(i32 %i) {
; CHECK-LABEL: @switch_to_select_same4_case_results_different_default_alt_bitmask(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[SWITCH_AND:%.*]] = and i32 [[I:%.*]], -11
; CHECK-NEXT:    [[SWITCH_SELECTCMP:%.*]] = icmp eq i32 [[SWITCH_AND]], 0
; CHECK-NEXT:    [[TMP0:%.*]] = select i1 [[SWITCH_SELECTCMP]], i1 true, i1 false
; CHECK-NEXT:    ret i1 [[TMP0]]
;
entry:
  switch i32 %i, label %lor.rhs [
  i32 0, label %lor.end
  i32 2, label %lor.end
  i32 8, label %lor.end
  i32 10, label %lor.end
  ]

lor.rhs:
  br label %lor.end

lor.end:
  %0 = phi i1 [ true, %entry ], [ false, %lor.rhs ], [ true, %entry ], [ true, %entry ], [ true, %entry ]
  ret i1 %0
}

define i1 @switch_to_select_same4_case_results_different_default_positive_offset(i32 %i) {
; CHECK-LABEL: @switch_to_select_same4_case_results_different_default_positive_offset(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[TMP0:%.*]] = sub i32 [[I:%.*]], 2
; CHECK-NEXT:    [[SWITCH_AND:%.*]] = and i32 [[TMP0]], -11
; CHECK-NEXT:    [[SWITCH_SELECTCMP:%.*]] = icmp eq i32 [[SWITCH_AND]], 0
; CHECK-NEXT:    [[TMP1:%.*]] = select i1 [[SWITCH_SELECTCMP]], i1 true, i1 false
; CHECK-NEXT:    ret i1 [[TMP1]]
;
entry:
  switch i32 %i, label %lor.rhs [
  i32 2, label %lor.end
  i32 4, label %lor.end
  i32 10, label %lor.end
  i32 12, label %lor.end
  ]

lor.rhs:
  br label %lor.end

lor.end:
  %0 = phi i1 [ true, %entry ], [ false, %lor.rhs ], [ true, %entry ], [ true, %entry ], [ true, %entry ]
  ret i1 %0
}

define i1 @switch_to_select_invalid_mask(i32 %i) {
; CHECK-LABEL: @switch_to_select_invalid_mask(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    switch i32 [[I:%.*]], label [[LOR_RHS:%.*]] [
; CHECK-NEXT:      i32 1, label [[LOR_END:%.*]]
; CHECK-NEXT:      i32 4, label [[LOR_END]]
; CHECK-NEXT:      i32 10, label [[LOR_END]]
; CHECK-NEXT:      i32 12, label [[LOR_END]]
; CHECK-NEXT:    ]
; CHECK:       lor.rhs:
; CHECK-NEXT:    br label [[LOR_END]]
; CHECK:       lor.end:
; CHECK-NEXT:    [[TMP0:%.*]] = phi i1 [ true, [[ENTRY:%.*]] ], [ false, [[LOR_RHS]] ], [ true, [[ENTRY]] ], [ true, [[ENTRY]] ], [ true, [[ENTRY]] ]
; CHECK-NEXT:    ret i1 [[TMP0]]
;
entry:
  switch i32 %i, label %lor.rhs [
  i32 1, label %lor.end
  i32 4, label %lor.end
  i32 10, label %lor.end
  i32 12, label %lor.end
  ]

lor.rhs:
  br label %lor.end

lor.end:
  %0 = phi i1 [ true, %entry ], [ false, %lor.rhs ], [ true, %entry ], [ true, %entry ], [ true, %entry ]
  ret i1 %0
}

define i1 @switch_to_select_nonpow2_cases(i32 %i) {
; CHECK-LABEL: @switch_to_select_nonpow2_cases(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    switch i32 [[I:%.*]], label [[LOR_RHS:%.*]] [
; CHECK-NEXT:      i32 0, label [[LOR_END:%.*]]
; CHECK-NEXT:      i32 2, label [[LOR_END]]
; CHECK-NEXT:      i32 4, label [[LOR_END]]
; CHECK-NEXT:    ]
; CHECK:       lor.rhs:
; CHECK-NEXT:    br label [[LOR_END]]
; CHECK:       lor.end:
; CHECK-NEXT:    [[TMP0:%.*]] = phi i1 [ true, [[ENTRY:%.*]] ], [ false, [[LOR_RHS]] ], [ true, [[ENTRY]] ], [ true, [[ENTRY]] ]
; CHECK-NEXT:    ret i1 [[TMP0]]
;
entry:
  switch i32 %i, label %lor.rhs [
  i32 0, label %lor.end
  i32 2, label %lor.end
  i32 4, label %lor.end
  ]

lor.rhs:
  br label %lor.end

lor.end:
  %0 = phi i1 [ true, %entry ], [ false, %lor.rhs ], [ true, %entry ], [ true, %entry ]
  ret i1 %0
}

; TODO: we can produce the optimal code when there is no default also
define i8 @switch_to_select_two_case_results_no_default(i32 %i) {
; CHECK-LABEL: @switch_to_select_two_case_results_no_default(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    switch i32 [[I:%.*]], label [[DEFAULT:%.*]] [
; CHECK-NEXT:      i32 0, label [[END:%.*]]
; CHECK-NEXT:      i32 2, label [[END]]
; CHECK-NEXT:      i32 4, label [[CASE3:%.*]]
; CHECK-NEXT:      i32 6, label [[CASE3]]
; CHECK-NEXT:    ]
; CHECK:       case3:
; CHECK-NEXT:    br label [[END]]
; CHECK:       default:
; CHECK-NEXT:    unreachable
; CHECK:       end:
; CHECK-NEXT:    [[T0:%.*]] = phi i8 [ 44, [[CASE3]] ], [ 42, [[ENTRY:%.*]] ], [ 42, [[ENTRY]] ]
; CHECK-NEXT:    ret i8 [[T0]]
;
entry:
  switch i32 %i, label %default [
  i32 0, label %case1
  i32 2, label %case2
  i32 4, label %case3
  i32 6, label %case4
  ]

case1:
  br label %end

case2:
  br label %end

case3:
  br label %end

case4:
  br label %end

default:
  unreachable

end:
  %t0 = phi i8 [ 42, %case1 ], [ 42, %case2 ], [ 44, %case3 ], [ 44, %case4 ]
  ret i8 %t0
}

define i1 @no_range(i8 %f) {
; CHECK-LABEL: @no_range(
; CHECK-NEXT:  bb3:
; CHECK-NEXT:    [[TMP0:%.*]] = and i8 [[F:%.*]], 60
; CHECK-NEXT:    [[TMP1:%.*]] = icmp eq i8 [[TMP0]], 60
; CHECK-NEXT:    [[TMP2:%.*]] = select i1 [[TMP1]], i1 true, i1 false
; CHECK-NEXT:    ret i1 [[TMP2]]
;
  switch i8 %f, label %bb1 [
  i8 60, label %bb2
  i8 61, label %bb2
  i8 62, label %bb2
  i8 63, label %bb2
  i8 124, label %bb2
  i8 188, label %bb2
  i8 252, label %bb2
  i8 189, label %bb2
  i8 190, label %bb2
  i8 191, label %bb2
  i8 125, label %bb2
  i8 126, label %bb2
  i8 127, label %bb2
  i8 253, label %bb2
  i8 254, label %bb2
  i8 255, label %bb2
  ]
bb1:
  br label %bb3
bb2:
  br label %bb3
bb3:
  %phi = phi i1 [ false, %bb1 ], [ true, %bb2 ]
  ret i1 %phi
}

define i1 @negative_no_range(i8 %f) {
; CHECK-LABEL: @negative_no_range(
; CHECK-NEXT:    switch i8 [[F:%.*]], label [[BB3:%.*]] [
; CHECK-NEXT:      i8 52, label [[BB2:%.*]]
; CHECK-NEXT:      i8 61, label [[BB2]]
; CHECK-NEXT:      i8 62, label [[BB2]]
; CHECK-NEXT:      i8 63, label [[BB2]]
; CHECK-NEXT:      i8 124, label [[BB2]]
; CHECK-NEXT:      i8 -68, label [[BB2]]
; CHECK-NEXT:      i8 -4, label [[BB2]]
; CHECK-NEXT:      i8 -67, label [[BB2]]
; CHECK-NEXT:      i8 -66, label [[BB2]]
; CHECK-NEXT:      i8 -65, label [[BB2]]
; CHECK-NEXT:      i8 125, label [[BB2]]
; CHECK-NEXT:      i8 126, label [[BB2]]
; CHECK-NEXT:      i8 127, label [[BB2]]
; CHECK-NEXT:      i8 -3, label [[BB2]]
; CHECK-NEXT:      i8 -2, label [[BB2]]
; CHECK-NEXT:      i8 -1, label [[BB2]]
; CHECK-NEXT:    ]
; CHECK:       bb2:
; CHECK-NEXT:    br label [[BB3]]
; CHECK:       bb3:
; CHECK-NEXT:    [[_0_SROA_0_0:%.*]] = phi i1 [ true, [[BB2]] ], [ false, [[TMP0:%.*]] ]
; CHECK-NEXT:    ret i1 [[_0_SROA_0_0]]
;
  switch i8 %f, label %bb1 [
  i8 52, label %bb2
  i8 61, label %bb2
  i8 62, label %bb2
  i8 63, label %bb2
  i8 124, label %bb2
  i8 188, label %bb2
  i8 252, label %bb2
  i8 189, label %bb2
  i8 190, label %bb2
  i8 191, label %bb2
  i8 125, label %bb2
  i8 126, label %bb2
  i8 127, label %bb2
  i8 253, label %bb2
  i8 254, label %bb2
  i8 255, label %bb2
  ]
bb1:
  br label %bb3
bb2:
  br label %bb3
bb3:
  %phi = phi i1 [ false, %bb1 ], [ true, %bb2 ]
  ret i1 %phi
}

; Using ranges.

define i1 @range0to4odd(i8 range(i8 0, 4) %f) {
; CHECK-LABEL: @range0to4odd(
; CHECK-NEXT:  bb3:
; CHECK-NEXT:    [[TMP0:%.*]] = and i8 [[F:%.*]], 1
; CHECK-NEXT:    [[TMP1:%.*]] = icmp eq i8 [[TMP0]], 1
; CHECK-NEXT:    [[TMP2:%.*]] = select i1 [[TMP1]], i1 true, i1 false
; CHECK-NEXT:    ret i1 [[TMP2]]
;
  switch i8 %f, label %bb1 [
  i8 1, label %bb2
  i8 3, label %bb2
  ]
bb1:
  br label %bb3
bb2:
  br label %bb3
bb3:
  %phi = phi i1 [ false, %bb1 ], [ true, %bb2 ]
  ret i1 %phi
}

define i1 @range1to4odd(i8 range(i8 1, 4) %f) {
; CHECK-LABEL: @range1to4odd(
; CHECK-NEXT:  bb3:
; CHECK-NEXT:    [[TMP0:%.*]] = and i8 [[F:%.*]], 1
; CHECK-NEXT:    [[TMP1:%.*]] = icmp eq i8 [[TMP0]], 1
; CHECK-NEXT:    [[TMP2:%.*]] = select i1 [[TMP1]], i1 true, i1 false
; CHECK-NEXT:    ret i1 [[TMP2]]
;
  switch i8 %f, label %bb1 [
  i8 1, label %bb2
  i8 3, label %bb2
  ]
bb1:
  br label %bb3
bb2:
  br label %bb3
bb3:
  %phi = phi i1 [ false, %bb1 ], [ true, %bb2 ]
  ret i1 %phi
}

define i1 @range0to8odd(i8 range(i8 0, 8) %f) {
; CHECK-LABEL: @range0to8odd(
; CHECK-NEXT:  bb3:
; CHECK-NEXT:    [[TMP0:%.*]] = and i8 [[F:%.*]], 1
; CHECK-NEXT:    [[TMP1:%.*]] = icmp eq i8 [[TMP0]], 1
; CHECK-NEXT:    [[TMP2:%.*]] = select i1 [[TMP1]], i1 true, i1 false
; CHECK-NEXT:    ret i1 [[TMP2]]
;
  switch i8 %f, label %bb1 [
  i8 1, label %bb2
  i8 3, label %bb2
  i8 5, label %bb2
  i8 7, label %bb2
  ]
bb1:
  br label %bb3
bb2:
  br label %bb3
bb3:
  %phi = phi i1 [ false, %bb1 ], [ true, %bb2 ]
  ret i1 %phi
}

define i1 @range0to8most_significant_bit(i8 range(i8 0, 8) %f) {
; CHECK-LABEL: @range0to8most_significant_bit(
; CHECK-NEXT:  bb3:
; CHECK-NEXT:    [[TMP0:%.*]] = and i8 [[F:%.*]], 4
; CHECK-NEXT:    [[TMP1:%.*]] = icmp eq i8 [[TMP0]], 4
; CHECK-NEXT:    [[TMP2:%.*]] = select i1 [[TMP1]], i1 true, i1 false
; CHECK-NEXT:    ret i1 [[TMP2]]
;
  switch i8 %f, label %bb1 [
  i8 4, label %bb2
  i8 5, label %bb2
  i8 6, label %bb2
  i8 7, label %bb2
  ]
bb1:
  br label %bb3
bb2:
  br label %bb3
bb3:
  %phi = phi i1 [ false, %bb1 ], [ true, %bb2 ]
  ret i1 %phi
}

define i1 @range0to15_middle_two_bits(i8 range(i8 0, 16) %f) {
; CHECK-LABEL: @range0to15_middle_two_bits(
; CHECK-NEXT:  bb3:
; CHECK-NEXT:    [[TMP0:%.*]] = and i8 [[F:%.*]], 6
; CHECK-NEXT:    [[TMP1:%.*]] = icmp eq i8 [[TMP0]], 6
; CHECK-NEXT:    [[TMP2:%.*]] = select i1 [[TMP1]], i1 true, i1 false
; CHECK-NEXT:    ret i1 [[TMP2]]
;
  switch i8 %f, label %bb1 [
  i8 6, label %bb2
  i8 7, label %bb2
  i8 14, label %bb2
  i8 15, label %bb2
  ]
bb1:
  br label %bb3
bb2:
  br label %bb3
bb3:
  %phi = phi i1 [ false, %bb1 ], [ true, %bb2 ]
  ret i1 %phi
}

define i1 @negative_range0to15(i8 range(i8 0, 16) %f) {
; CHECK-LABEL: @negative_range0to15(
; CHECK-NEXT:    switch i8 [[F:%.*]], label [[BB3:%.*]] [
; CHECK-NEXT:      i8 6, label [[BB2:%.*]]
; CHECK-NEXT:      i8 7, label [[BB2]]
; CHECK-NEXT:      i8 14, label [[BB2]]
; CHECK-NEXT:    ]
; CHECK:       bb2:
; CHECK-NEXT:    br label [[BB3]]
; CHECK:       bb3:
; CHECK-NEXT:    [[_0_SROA_0_0:%.*]] = phi i1 [ true, [[BB2]] ], [ false, [[TMP0:%.*]] ]
; CHECK-NEXT:    ret i1 [[_0_SROA_0_0]]
;
  switch i8 %f, label %bb1 [
  i8 6, label %bb2
  i8 7, label %bb2
  i8 14, label %bb2
  ]
bb1:
  br label %bb3
bb2:
  br label %bb3
bb3:
  %phi = phi i1 [ false, %bb1 ], [ true, %bb2 ]
  ret i1 %phi
}

define i1 @negative_range0to15_pow_2(i8 range(i8 0, 16) %f) {
; CHECK-LABEL: @negative_range0to15_pow_2(
; CHECK-NEXT:  bb3:
; CHECK-NEXT:    [[TMP0:%.*]] = sub i8 [[F:%.*]], 6
; CHECK-NEXT:    [[SWITCH_AND:%.*]] = and i8 [[TMP0]], -2
; CHECK-NEXT:    [[SWITCH_SELECTCMP:%.*]] = icmp eq i8 [[SWITCH_AND]], 0
; CHECK-NEXT:    [[TMP1:%.*]] = select i1 [[SWITCH_SELECTCMP]], i1 true, i1 false
; CHECK-NEXT:    ret i1 [[TMP1]]
;
  switch i8 %f, label %bb1 [
  i8 6, label %bb2
  i8 7, label %bb2
  ]
bb1:
  br label %bb3
bb2:
  br label %bb3
bb3:
  %phi = phi i1 [ false, %bb1 ], [ true, %bb2 ]
  ret i1 %phi
}

define i1 @negative_range0to5even(i8 range(i8 0, 5) %f) {
; CHECK-LABEL: @negative_range0to5even(
; CHECK-NEXT:  bb3:
; CHECK-NEXT:    [[TMP0:%.*]] = sub i8 [[F:%.*]], 2
; CHECK-NEXT:    [[SWITCH_AND:%.*]] = and i8 [[TMP0]], -3
; CHECK-NEXT:    [[SWITCH_SELECTCMP:%.*]] = icmp eq i8 [[SWITCH_AND]], 0
; CHECK-NEXT:    [[TMP1:%.*]] = select i1 [[SWITCH_SELECTCMP]], i1 true, i1 false
; CHECK-NEXT:    ret i1 [[TMP1]]
;
  switch i8 %f, label %bb1 [
  i8 2, label %bb2
  i8 4, label %bb2
  ]
bb1:
  br label %bb3
bb2:
  br label %bb3
bb3:
  %phi = phi i1 [ false, %bb1 ], [ true, %bb2 ]
  ret i1 %phi
}

define i1 @range0to15_corner_case(i8 range(i8 0, 16) %f) {
; CHECK-LABEL: @range0to15_corner_case(
; CHECK-NEXT:  bb3:
; CHECK-NEXT:    [[COND:%.*]] = icmp eq i8 [[F:%.*]], 15
; CHECK-NEXT:    [[DOT:%.*]] = select i1 [[COND]], i1 true, i1 false
; CHECK-NEXT:    ret i1 [[DOT]]
;
  switch i8 %f, label %bb1 [
  i8 15, label %bb2
  ]
bb1:
  br label %bb3
bb2:
  br label %bb3
bb3:
  %phi = phi i1 [ false, %bb1 ], [ true, %bb2 ]
  ret i1 %phi
}

define i1 @negative_range0to15_corner_case(i8 range(i8 0, 16) %f) {
; CHECK-LABEL: @negative_range0to15_corner_case(
; CHECK-NEXT:  bb3:
; CHECK-NEXT:    [[SWITCH_SELECTCMP_CASE1:%.*]] = icmp eq i8 [[F:%.*]], 15
; CHECK-NEXT:    [[SWITCH_SELECTCMP_CASE2:%.*]] = icmp eq i8 [[F]], 8
; CHECK-NEXT:    [[SWITCH_SELECTCMP:%.*]] = or i1 [[SWITCH_SELECTCMP_CASE1]], [[SWITCH_SELECTCMP_CASE2]]
; CHECK-NEXT:    [[TMP0:%.*]] = select i1 [[SWITCH_SELECTCMP]], i1 true, i1 false
; CHECK-NEXT:    ret i1 [[TMP0]]
;
  switch i8 %f, label %bb1 [
  i8 15, label %bb2
  i8 8,  label %bb2
  ]
bb1:
  br label %bb3
bb2:
  br label %bb3
bb3:
  %phi = phi i1 [ false, %bb1 ], [ true, %bb2 ]
  ret i1 %phi
}

; Out of range scenarios. Check if the cases, that have a value out of range
; are eliminated and the optimization is performed.

define i1 @range0to15_out_of_range_non_prime(i8 range(i8 0, 16) %f) {
; CHECK-LABEL: @range0to15_out_of_range_non_prime(
; CHECK-NEXT:  bb3:
; CHECK-NEXT:    [[TMP0:%.*]] = and i8 [[F:%.*]], 6
; CHECK-NEXT:    [[TMP1:%.*]] = icmp eq i8 [[TMP0]], 6
; CHECK-NEXT:    [[TMP2:%.*]] = select i1 [[TMP1]], i1 true, i1 false
; CHECK-NEXT:    ret i1 [[TMP2]]
;
  switch i8 %f, label %bb1 [
  i8 6, label %bb2
  i8 7, label %bb2
  i8 14, label %bb2
  i8 15, label %bb2
  i8 22, label %bb2
  ]
bb1:
  br label %bb3
bb2:
  br label %bb3
bb3:
  %phi = phi i1 [ false, %bb1 ], [ true, %bb2 ]
  ret i1 %phi
}

define i1 @range0to15_out_of_range_non_prime_more(i8 range(i8 0, 16) %f) {
; CHECK-LABEL: @range0to15_out_of_range_non_prime_more(
; CHECK-NEXT:  bb3:
; CHECK-NEXT:    [[TMP0:%.*]] = and i8 [[F:%.*]], 6
; CHECK-NEXT:    [[TMP1:%.*]] = icmp eq i8 [[TMP0]], 6
; CHECK-NEXT:    [[TMP2:%.*]] = select i1 [[TMP1]], i1 true, i1 false
; CHECK-NEXT:    ret i1 [[TMP2]]
;
  switch i8 %f, label %bb1 [
  i8 6, label %bb2
  i8 7, label %bb2
  i8 14, label %bb2
  i8 15, label %bb2
  i8 22, label %bb2
  i8 23, label %bb2
  ]
bb1:
  br label %bb3
bb2:
  br label %bb3
bb3:
  %phi = phi i1 [ false, %bb1 ], [ true, %bb2 ]
  ret i1 %phi
}

define i1 @negative_range0to15_out_of_range_non_prime(i8 range(i8 0, 16) %f) {
; CHECK-LABEL: @negative_range0to15_out_of_range_non_prime(
; CHECK-NEXT:    switch i8 [[F:%.*]], label [[BB3:%.*]] [
; CHECK-NEXT:      i8 6, label [[BB2:%.*]]
; CHECK-NEXT:      i8 14, label [[BB2]]
; CHECK-NEXT:      i8 15, label [[BB2]]
; CHECK-NEXT:    ]
; CHECK:       bb2:
; CHECK-NEXT:    br label [[BB3]]
; CHECK:       bb3:
; CHECK-NEXT:    [[TMP2:%.*]] = phi i1 [ true, [[BB2]] ], [ false, [[TMP0:%.*]] ]
; CHECK-NEXT:    ret i1 [[TMP2]]
;
  switch i8 %f, label %bb1 [
  i8 6, label %bb2
  i8 14, label %bb2
  i8 15, label %bb2
  i8 23, label %bb2
  ]
bb1:
  br label %bb3
bb2:
  br label %bb3
bb3:
  %phi = phi i1 [ false, %bb1 ], [ true, %bb2 ]
  ret i1 %phi
}

define i1 @negative_range0to15_out_of_range(i8 range(i8 0, 16) %f) {
; CHECK-LABEL: @negative_range0to15_out_of_range(
; CHECK-NEXT:    switch i8 [[F:%.*]], label [[BB3:%.*]] [
; CHECK-NEXT:      i8 6, label [[BB2:%.*]]
; CHECK-NEXT:      i8 7, label [[BB2]]
; CHECK-NEXT:      i8 14, label [[BB2]]
; CHECK-NEXT:    ]
; CHECK:       bb2:
; CHECK-NEXT:    br label [[BB3]]
; CHECK:       bb3:
; CHECK-NEXT:    [[_0_SROA_0_0:%.*]] = phi i1 [ true, [[BB2]] ], [ false, [[TMP0:%.*]] ]
; CHECK-NEXT:    ret i1 [[_0_SROA_0_0]]
;
  switch i8 %f, label %bb1 [
  i8 6, label %bb2
  i8 7, label %bb2
  i8 14, label %bb2
  i8 150, label %bb2
  ]
bb1:
  br label %bb3
bb2:
  br label %bb3
bb3:
  %phi = phi i1 [ false, %bb1 ], [ true, %bb2 ]
  ret i1 %phi
}

define i1 @negative_range0to15_all_out_of_range(i8 range(i8 0, 16) %f) {
; CHECK-LABEL: @negative_range0to15_all_out_of_range(
; CHECK-NEXT:  bb1:
; CHECK-NEXT:    ret i1 false
;
  switch i8 %f, label %bb1 [
  i8 22, label %bb2
  i8 23, label %bb2
  i8 30, label %bb2
  i8 31, label %bb2
  ]
bb1:
  br label %bb3
bb2:
  br label %bb3
bb3:
  %phi = phi i1 [ false, %bb1 ], [ true, %bb2 ]
  ret i1 %phi
}
