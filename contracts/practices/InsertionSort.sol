
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title x
 * @dev   x
 */
contract InsertionSort {
    function insertionSortWrong(uint[] memory a) external pure returns (uint[] memory) {
        for (uint i = 0; i < a.length; i++) {
            uint temp = a[i];
            uint j = i - 1;
            while ((j>=0 && temp < a[j])) {
                a[j+1] = a[j];
                j--;
            }
            a[j+1] = temp;
        }
        return a;
    }
//    Solidity中最常用的变量类型是uint，也就是正整数，取到负值的话，
//会报underflow错误。而在插入算法中，变量j有可能会取到-1，引起报错。

//正确的插入排序如下
    function insertionSort(uint[] memory a) external pure returns (uint[] memory) {
        for (uint i = 0; i < a.length; i++) {
            uint temp = a[i];
            uint j = i;

            while ((j>=1 && temp < a[j - 1])) {
                a[j] = a[j-1];
                j--;
            }
            a[j] = temp;
        }
        return a;
    }


}
