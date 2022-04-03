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
		token = await Token.deploy('PEPE Coin', 'PEPE', decimals, supply);
	});

	describe('Deployment', () => {
		
		it("Should set token name to PEPE Coin" , async () => {
			expect(await token.name()).to.equal('PEPE Coin');
		});

		it("Should set token symbol to PEPE", async () => {
			expect(await token.symbol()).to.equal('PEPE');
		});

		it("Should set number of decimals in currency to 18", async () => {
			expect((await token.decimals()).toString()).to.equal('18');
		});

		it("Should set total supply to 10000000", async () => {
			expect((await token.totalSupply()).toString()).to.equal('10000000');
		});

		it("Should emit event when transfer is called", async () => {
			expect(token.transfer(addr2.address, 1))
				.to.emit(token, "Transfer")
				.withArgs(addr1.address, addr2.address, 1);
		});

		it("Should emit event when approve is called", async () => {
			expect(token.approve(addr1.address, 1))
			.to.emit(token, "Approval")
			.withArgs(addr1.address, 1);
		});
	});
});