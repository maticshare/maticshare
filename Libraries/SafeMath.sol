// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

library SafeMath {

  function add(uint number, uint amount) internal pure returns (uint) {
    return number + amount;
  }

  function sub(uint number, uint amount) internal pure returns (uint) {
    return number < amount ? 0 : number - amount;
  }

  function mull(uint number, uint amount) internal pure returns (uint) {
    return number * amount;
  }

  function div(uint number, uint amount) internal pure returns (uint) {
    return amount == 0 ? 0 : number / amount;
  }

  function pow(uint number, uint amount) internal pure returns (uint) {
    return number ** amount;
  }

  function inc(uint number) internal pure returns (uint) {
    return add(number, 1);
  }

  function dec(uint number) internal pure returns (uint) {
    return sub(number, 1);
  }

  function between(uint number, uint min, uint max) internal pure returns (uint) {
    return (number % max) + min;
  }

  function isBetween(uint number, uint min, uint max) internal pure returns (bool) {
    return number >= min && number <= max;
  }

  function percent(uint number, uint8 _percent) internal pure returns (uint) {
    return number * _percent / 100;
  }

}

library SafeMath8 {

  function add(uint8 number, uint8 amount) internal pure returns (uint8) {
    return number + amount;
  }

  function sub(uint8 number, uint8 amount) internal pure returns (uint8) {
    return number < amount ? 0 : number - amount;
  }

  function mull(uint8 number, uint8 amount) internal pure returns (uint8) {
    return number * amount;
  }

  function div(uint8 number, uint8 amount) internal pure returns (uint8) {
    return amount == 0 ? 0 : number / amount;
  }

  function pow(uint8 number, uint8 amount) internal pure returns (uint8) {
    return number ** amount;
  }

  function inc(uint8 number) internal pure returns (uint8) {
    return add(number, 1);
  }

  function dec(uint8 number) internal pure returns (uint8) {
    return sub(number, 1);
  }

  function between(uint8 number, uint8 min, uint8 max) internal pure returns (uint8) {
    return (number % max) + min;
  }

  function isBetween(uint8 number, uint8 min, uint8 max) internal pure returns (bool) {
    return number >= min && number <= max;
  }

  function percent(uint8 number, uint8 _percent) internal pure returns (uint8) {
    return number * _percent / 100;
  }

}