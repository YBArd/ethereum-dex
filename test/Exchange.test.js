const { ethers, waffle } = require('hardhat');
const { expect } = require('chai');
const { web3 } = require('web3');
const provider = waffle.provider;

describe("Exchange", () => {

	let exchange, Exchange, token, Token, owner, addr1, addr2, decimals, supply;

	beforeEach(async () => {
		[owner, addr1, addr2, _] = await ethers.getSigners();
		Token = await ethers.getContractFactory('Token');
		decimals = 18;
		supply = 10000000;
		token = await Token.deploy('TEST Coin', 'TEST', decimals, supply);
		Exchange = await ethers.getContractFactory('Exchange');
		exchange = await Exchange.deploy(token.address);
	});

	describe("addLiquidity", async () => {
		
		it("Adds liquidity to the exchange", async () => {
			await token.approve(exchange.address, 2);
			await exchange.addLiquidity(2, { value: {_hex: '0x1', _isBigNumber: true} });
			expect(await provider.getBalance(exchange.address))
				.to.equal(1);
			expect(await exchange.getReserve())
				.to.equal(2);
		});
	});

	describe("Price", async () => {
		it("Calculates the correct price for an asset", async () => {
			await token.approve(exchange.address, 2000);
			await exchange.addLiquidity(2000, { value: 1000 })
			const tokenReserve = await exchange.getReserve();
			const etherReserve = await provider.getBalance(exchange.address);
			expect(await exchange.getPrice(etherReserve, tokenReserve))
				.to.equal(500);
			expect(await exchange.getPrice(tokenReserve, etherReserve))
				.to.equal(2000);
		});
	});
});