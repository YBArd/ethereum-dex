const { ethers, waffle } = require('hardhat');
const { expect } = require('chai');
const { web3 } = require('@nomiclabs/hardhat-web3');
const provider = waffle.provider;

describe("Exchange", () => {

	let exchange, Exchange, token, token2, Token, owner, addr1, addr2, decimals, supply, factory, Factory;

	beforeEach(async () => {
		[owner, addr1, addr2, _] = await ethers.getSigners();
		Token = await ethers.getContractFactory('Token');
		decimals = 18;
		supply = 10000000;
		Factory = await ethers.getContractFactory('Factory');
		factory = await Factory.deploy();
		token = await Token.deploy('TEST Coin', 'TEST', decimals, supply);
		Exchange = await ethers.getContractFactory('Exchange');
		exchange = await Exchange.deploy(token.address);
		token2 = await Token.connect(addr2).deploy('TEST2 Coin', 'TEST2', decimals, supply);
		exchange2 = await Exchange.deploy(token2.address);
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
		it("Calculates the correct price for an asset and fetches exchange reserves", async () => {
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

	describe("tokenSwap", async () => {
		it("Should swap one token for another and send tokens to user address", async () => {
			await token.approve(exchange.address, 2000);
			await exchange.addLiquidity(2000, { value: 1000 });
			let purchasedEther = await exchange.getEthAmount(2);
			await token2.connect(addr2).approve(exchange2.address, 1000);
			await exchange2.connect(addr2).addLiquidity(1000, { value: 1000 }); //seeded exchange2 with TEST2 tokens and ethers
			
			expect(await token2.balanceOf(addr1.address))
				.to.equal(0);

			await exchange.tokenSwap(Web3.utils.toWei('10'), Web3.utils.toWei('4.8'), token2.address);

			expect(await token2.balanceOf(addr1.address))
				.to.equal('4.852698493489877956');
		});
	});

	/*describe("removeLiquidity", async () => {

	});*/
});