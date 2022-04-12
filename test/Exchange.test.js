const { ethers, waffle } = require('hardhat');
const { expect } = require('chai');
const { web3 } = require('web3');

describe("Exchange", () => {

	let exchange, Exchange, token, Token, owner, addr1, addr2, decimals, supply;

	beforeEach(async () =>{
		[owner, addr1, addr2, _] = await ethers.getSigners();
		Exchange = await ethers.getContractFactory('Exchange');
		Token = await ethers.getContractFactory('Token');
		decimals = 18;
		supply = 10000000;
		token = await Token.deploy('TEST Coin', 'TEST', decimals, supply);
		exchange = await Exchange.deploy(token.address);
		//const provider = waffle.provider;
	});

	/*describe("Deployment", async () => {
		it("Should be reverted if token address is the 0x address", async () => {
			expect(await Exchange.deploy(address(0)))
				.to.be.reverted;
		});
	});*/

	describe("addLiquidity", async () => {
		it("Adds liquidity to the exchange", async () => {
			await token.approve(exchange.address, 2);
			await exchange.addLiquidity.call(2, { value: 1 });
			expect(await exchange.address.balance)
				.to.equal(0);
			//expect(await exchange.getReserve())
				//.to.equal(2);
		});
	});
});