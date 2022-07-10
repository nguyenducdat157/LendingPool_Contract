//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract MathUtils {
    using SafeMath for uint256;

    uint256 private constant EXP_SCALE = 1e18;
    uint256 private constant HALF_EXP_SCALE = EXP_SCALE / 2;

    function getExp(uint256 num, uint256 denom)
        internal
        pure
        returns (uint256)
    {
        (bool successMul, uint256 scaledNumber) = num.tryMul(EXP_SCALE);
        if (!successMul) return 0;
        (bool successDiv, uint256 rational) = scaledNumber.tryDiv(denom);
        if (!successDiv) return 0;
        return rational; // result  =  (num * 10^18) / denom
    }

    function mulExp(uint256 a, uint256 b) internal pure returns (uint256) {
        (bool successMul, uint256 doubleScaledProduct) = a.tryMul(b);
        if (!successMul) return 0;
        // (
        //     bool successAdd,
        //     uint256 doubleScaledProductWithHalfScale // doubleScaledProductWithHalfScale = (a * b) + 0.5 * 10 ^ 18
        // ) = HALF_EXP_SCALE.tryAdd(doubleScaledProduct);
        // if (!successAdd) return 0;
        (bool successDiv, uint256 product) = doubleScaledProduct.tryDiv(
            EXP_SCALE
        );
        assert(successDiv == true);
        return product; // result  = (a * b) / 10 ^ 18 + 0.5
    }

    function percentage(uint256 _num, uint256 _percentage)
        internal
        pure
        returns (uint256)
    {
        uint256 rational = getExp(_num, 5); // rational = _num * 10 ^ 18 / 5
        return mulExp(rational, _percentage); // result  = ( rational * _percentage) / 10 ^ 18 + 0.5 = (_num * _percentage) / 5 + 0.5
    }
}
