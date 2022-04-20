const BlockBattle = artifacts.require("BlockBattle");

contract('MetaCoin', (accounts) => {
  it('should ', async () => {
    const BlockBattleInstance = await BlockBattle.deployed();
    const balance = await BlockBattleInstance.getBalance.call(accounts[0]);

    assert.equal(balance.valueOf(), 10000, "error");
  });
  // it('should call a function that depends on a linked library', async () => {
  //   const metaCoinInstance = await BlockBattle.deployed();
  //   const metaCoinBalance = (await metaCoinInstance.getBalance.call(accounts[0])).toNumber();
  //   const metaCoinEthBalance = (await metaCoinInstance.getBalanceInEth.call(accounts[0])).toNumber();
  //
  //   assert.equal(metaCoinEthBalance, 2 * metaCoinBalance, 'Library function returned unexpected function, linkage may be broken');
  // });
  // it('should send coin correctly', async () => {
  //   const metaCoinInstance = await BlockBattle.deployed();
  //
  //   // Setup 2 accounts.
  //   const accountOne = accounts[0];
  //   const accountTwo = accounts[1];
  //
  //   // Get initial balances of first and second account.
  //   const accountOneStartingBalance = (await metaCoinInstance.getBalance.call(accountOne)).toNumber();
  //   const accountTwoStartingBalance = (await metaCoinInstance.getBalance.call(accountTwo)).toNumber();
  //
  //   // Make transaction from first account to second.
  //   const amount = 10;
  //   await metaCoinInstance.sendCoin(accountTwo, amount, { from: accountOne });
  //
  //   // Get balances of first and second account after the transactions.
  //   const accountOneEndingBalance = (await metaCoinInstance.getBalance.call(accountOne)).toNumber();
  //   const accountTwoEndingBalance = (await metaCoinInstance.getBalance.call(accountTwo)).toNumber();
  //
  //
  //   assert.equal(accountOneEndingBalance, accountOneStartingBalance - amount, "Amount wasn't correctly taken from the sender");
  //   assert.equal(accountTwoEndingBalance, accountTwoStartingBalance + amount, "Amount wasn't correctly sent to the receiver");
  // });
});
