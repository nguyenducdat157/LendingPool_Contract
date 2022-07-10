const { JsonRpcProvider } = require("@ethersproject/providers");
const { Wallet } = require("@ethersproject/wallet");
const { Contract } = require("@ethersproject/contracts");
const { formatEther, parseEther } = require("@ethersproject/units");

const provider = new JsonRpcProvider(
  "https://rinkeby.infura.io/v3/d62ca87917384cf99ceb70bd09fd4a88",
  42
);
const wallet = new Wallet(
  "f0cde9a496ff55b1c49f272b38306fafe3e895552b178744dc31e0ce49f762bb"
).connect(provider);
const contract = new Contract(
  "0xff795577d9ac8bd7d90ee22b6c1703490b6512fd"
).connect(provider);
(async () => {
  const weiBalance1 = await wallet.getBalance();

  console.log("balance before", formatEther(weiBalance1));

  //   const tx = await wallet.sendTransaction({
  //     to: '0x1BaB8030249382A887F967FcAa7FE0be7B390728',
  //     value: parseEther('0.1'),
  //   });
  //   console.log(tx.hash);

  const tx = await contract.approve(
    "0xE0fBa4Fc209b4948668006B2bE61711b7f465bAe",
    parseEther("10000000")
  );
  console.log(tx);

  await provider.waitForTransaction(tx.hash);

  const weiBalance2 = await wallet.getBalance();
  console.log("balance after", formatEther(weiBalance2));
})();
