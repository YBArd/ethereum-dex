const { expect } = require('chai');
const { Contract } = require('ethers');
const { ethers } = require('hardhat');
const { events } = require('events');


describe("Token", () => {

	let owner;
	let token;
	let Token;
	let decimals;
	let supply;
	let addr1, addr2;

	beforeEach(async () => {
		[owner, addr1, addr2] = await ethers.getSigners();
		Token = await ethers.getContractFactory('Token');
		decimals = 18;
		supply = 10000000;
		token = await Token.deploy('TEST Coin', 'TEST', decimals, supply);
	});

	describe('Deployment', () => {
		
		it("Should set token name to TEST Coin" , async () => {
			expect(await token.name()).to.equal('TEST Coin');
		});

		it("Should set token symbol to TEST", async () => {
			expect(await token.symbol()).to.equal('TEST');
		});

		it("Should set number of decimals in currency to 18", async () => {
			expect((await token.decimals()).toString()).to.equal('18');
		});

		it("Should set total supply to 10000000", async () => {
			expect((await token.totalSupply()).toString()).to.equal('10000000');
		});
	});

	describe('Transfer', () => {

		it("Should revert if value exceeds sender balance", async () => {
			await expect(token.transfer(addr2.address, addr1.balance + 1))
				.to.be.reverted;
		});

		it("Should emit event when transfer is called", async () => {
			expect(token.transfer(addr2.address, 1))
				.to.emit(token, "Transfer")
				.withArgs(addr1.address, addr2.address, 1);
		});
	});

	describe('Approval', () => {

		it("Should revert if spender is the 0 address", async () => {
			await expect(token.approve(0, 1))
				.to.be.reverted;
		});

		it("Should update approved allowance to correct amount", async () => {
			await token.approve(addr1.address, 1, { from: owner.address });
			expect(await token.allowance(owner.address, addr1.address))
				.to.be.equal(1);
		});

		it("Should emit event when approve is called", async () => {
			expect(token.approve(addr1.address, 1))
			.to.emit(token, "Approval")
			.withArgs(addr1.address, 1);
		});
	});

	describe('transferFrom', () => {

		beforeEach(async () => {
			await expect(token.approve(addr1.address, 1, { from: owner.address }));
		});

		it("Should revert if sender's balance is less than value", async () => {
			await expect(token.transferFrom(addr1.address, addr2.address, addr1.balance + 1))
				.to.be.reverted;
		});

		it("Should revert if value of transaction exceeds approved spending amount", async () => {
			await expect(token.transferFrom(addr1.address, addr2.address, 2))
				.to.be.reverted;
		});
	});
});