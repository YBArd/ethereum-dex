const { ethers, waffle } = require('hardhat');
const { expect } = require('chai');
const { web3 } = require('@nomiclabs/hardhat-web3');
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
			await token.approve(exchange.address, 200);
			await exchange.addLiquidity(200, { value: 100 });
			expect(await provider.getBalance(exchange.address))
				.to.equal(100);
			expect(await exchange.getTokenReserves())
				.to.equal(200);
		});
	});

	describe("priceFunction", async () => {
		it("Calculates the correct price for an asset", async () => {
			await token.approve(exchange.address, 2000);
			await exchange.addLiquidity(2000, { value: 1000 })
			const tokenReserve = await exchange.getTokenReserves();
			const etherReserve = await provider.getBalance(exchange.address);
			expect(await exchange.getPrice(etherReserve, tokenReserve))
				.to.equal(500);
			expect(await exchange.getPrice(tokenReserve, etherReserve))
				.to.equal(2000);
		});
	});

	describe("getTokenAmount", async () => {
		it("Gets the correct token amount", async () => {
			await token.approve(exchange.address, 2000);
			await exchange.addLiquidity(2000, { value: 1000 });
			let purchasedTokens = await exchange.getTokenAmount(1);
    		expect(Web3.utils.fromWei(String(purchasedTokens)))
    			.to.equal("1.978041738678708079");
			
			purchasedTokens = await exchange.getTokenAmount(100);
			expect(Web3.utils.fromWei(String(purchasedTokens)))
				.to.equal('180.1637852593266606');

			purchasedTokens = await exchange.getTokenAmount(1000);
			expect(Web3.utils.fromWei(String(purchasedTokens)))
				.to.equal('994.974874371859296482');
		});
	});

	describe("getEthAmount", async () => {
		it("Gets the correct ether amount", async () => {	
			await token.approve(exchange.address, 2000);
			await exchange.addLiquidity(2000, { value: 1000 });
			let purchasedEther = await exchange.getEthAmount(2);
			expect(Web3.utils.fromWei(String(purchasedEther)))
				.to.equal('0.989020869339354039');

			purchasedEther = await exchange.getEthAmount(100);
			expect(Web3.utils.fromWei(String(purchasedEther)))
				.to.equal('47.16531681753215817');

			purchasedEther = await exchange.getEthAmount(2000);
			expect(Web3.utils.fromWei(String(purchasedEther)))
				.to.equal('497.487437185929648241');
		});
	});

});