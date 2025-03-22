#include <catch2/catch_test_macros.hpp>
#include "calculator.h"

TEST_CASE("Calculator basic operations", "[calculator]") {
    SECTION("Addition") {
        REQUIRE(calculator::Calculator::add(2.0, 3.0) == 5.0);
        REQUIRE(calculator::Calculator::add(-2.0, 3.0) == 1.0);
        REQUIRE(calculator::Calculator::add(0.0, 0.0) == 0.0);
    }

    SECTION("Subtraction") {
        REQUIRE(calculator::Calculator::subtract(5.0, 3.0) == 2.0);
        REQUIRE(calculator::Calculator::subtract(-2.0, 3.0) == -5.0);
        REQUIRE(calculator::Calculator::subtract(0.0, 0.0) == 0.0);
    }

    SECTION("Multiplication") {
        REQUIRE(calculator::Calculator::multiply(2.0, 3.0) == 6.0);
        REQUIRE(calculator::Calculator::multiply(-2.0, 3.0) == -6.0);
        REQUIRE(calculator::Calculator::multiply(0.0, 5.0) == 0.0);
    }

    SECTION("Division") {
        REQUIRE(calculator::Calculator::divide(6.0, 2.0) == 3.0);
        REQUIRE(calculator::Calculator::divide(-6.0, 2.0) == -3.0);
        REQUIRE(calculator::Calculator::divide(0.0, 5.0) == 0.0);
        
        // Test division by zero
        REQUIRE_THROWS_AS(calculator::Calculator::divide(5.0, 0.0), std::invalid_argument);
    }
}