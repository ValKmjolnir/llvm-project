//===-- Unittests for stdc_trailing_ones_us -------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "src/__support/CPP/limits.h"
#include "src/stdbit/stdc_trailing_ones_us.h"
#include "test/UnitTest/Test.h"

TEST(LlvmLibcStdcTrailingOnesUsTest, ALL) {
  EXPECT_EQ(LIBC_NAMESPACE::stdc_trailing_ones_us(USHRT_MAX),
            static_cast<unsigned>(USHRT_WIDTH));
}

TEST(LlvmLibcStdcTrailingOnesUsTest, ZeroHot) {
  for (unsigned i = 0U; i != USHRT_WIDTH; ++i)
    EXPECT_EQ(LIBC_NAMESPACE::stdc_trailing_ones_us(
                  static_cast<unsigned short>(~(1U << i))),
              i);
}
