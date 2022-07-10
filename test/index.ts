/**
 *
 * TODO: TESTS USING MOCKS
 *
 */

import { expect } from "chai";
import { Signer } from "ethers";
import { ethers } from "hardhat";
// import { Math } from '../typechain/'
// import {
//   MockContract,
//   MockContractFactory,
//   smock,
// // } from "@defi-wonderland/smock";
// import { BondToken, BondToken__factory } from "../typechain/";
// import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";

// // use(smock.matchers);

// // let fakeContract: MockContractFactory<BondToken__factory>;
// // let fakeInstance: MockContract<BondToken>;

// let addr1: SignerWithAddress;
// let addr2: SignerWithAddress;

// describe("Bond Token Contract", async () => {});

// const setup = async () => {
// [addr1, addr2] = await ethers.getSigners();
//   fakeContract = await smock.mock("BondToken");
//   fakeInstance = await fakeContract.deploy();
//   await fakeInstance.deployed();
// };

describe("AaveGateway", function () {
  it("", async function () {
    const AaveGateway = await ethers.getContractFactory("AaveGateway");
    const aaveGateway = await AaveGateway.deploy();
    await aaveGateway.deployed();

    expect(await aaveGateway.maxLTV()).to.equal(4);

    // const setGreetingTx = await greeter.setGreeting("Hola, mundo!");

    // wait until the transaction is mined
    // await setGreetingTx.wait();
  });
});

describe("Math", function () {
  // it("Deployment should assign the total supply of tokens to the owner", async function () {
  //   const [owner] = await ethers.getSigners();

  //   const Math = await ethers.getContractFactory("Math");

  //   const math = await Math.deploy();

  //   const ownerBalance = await hardhatToken.balanceOf(owner.address);
  //   expect(await hardhatToken.totalSupply()).to.equal(ownerBalance);
  // });
  let owner: Signer;
  // let math: any;
  beforeEach(async function () {
    [owner] = await ethers.getSigners();

    // const Math = await ethers.getContractFactory("Math");

    // math = await Math.deploy();
  });

  describe("Deployment", function () {
    // `it` is another Mocha function. This is the one you use to define your
    // tests. It receives the test name, and a callback function.

    // If the callback function is async, Mocha will `await` it.
    it("getExp", async function () {
      const Math = await ethers.getContractFactory("MathUtils");

      const math = await Math.deploy();
      await math.deployed();

      // Expect receives a value, and wraps it in an Assertion object. These
      // objects have a lot of utility methods to assert values.

      // This test expects the owner variable stored in the contract to be equal
      // to our Signer's owner.
      const getExpResul = await math.getExp(10, 5);
      expect(getExpResul.to.equal(2 * 10 ** 18));
    });
  });
});
