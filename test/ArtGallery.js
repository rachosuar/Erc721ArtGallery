const { BlockForkEvent } = require("@ethersproject/abstract-provider");
const { messagePrefix } = require("@ethersproject/hash");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");
const { getDefaultProvider } = require("ethers");
const { ethers } = require("hardhat");

const signers = {};
let artGalleryFactory;
let artGalleryInstance;
let artGalleryAddr;

let tokenFactory;
let tokenInstance;
let tokenAddr;

describe("Art Gallery Test", function () {
  it("Should deploy the smart contract", async function () {
    const [deployer, firstUser, secondUser] = await ethers.getSigners();
    signers.deployer = deployer;
    signers.firstUser = firstUser;
    signers.secondUser = secondUser;
  });
});
describe("Deployment", function () {
  it(`Should deploy the smart contract with name and symbol`, async function () {
    artGalleryFactory = await ethers.getContractFactory(
      "ArtGallery",
      signers.deployer
    );
    artGalleryInstance = await artGalleryFactory.deploy();
    await artGalleryInstance.deployed();
    artGalleryAddr = artGalleryInstance.address;
    tokenAddr = await artGalleryInstance.nft721instance();
    tokenFactory = await ethers.getContractFactory("erc721", signers.deployer);
    tokenInstance = tokenFactory.attach(tokenAddr);
    const deployedName = await tokenInstance.name();
    const deployedSymbol = await tokenInstance.symbol();
    expect(deployedName).to.equal("Ewol Art Gallery");
    expect(deployedSymbol).to.equal("EART");
  });
});
describe("Create Colecction", function () {
  it(`Should allow to add an artwork`, async function () {
    let tokenUri =
      "https://bafybeicp7bwqf2awghts5fseqrlol7xrpt3ne66whsm2uzric6lysjdjam.ipfs.nftstorage.link/data/";
    await artGalleryInstance.publishArtworkForGallery(tokenUri, 1, 100);
    let createColecction = await artGalleryInstance.publishArtworkForGallery(
      tokenUri,
      1,
      100
    );
    createColecction.wait();
    const balanceGallery = await tokenInstance.balanceOf(artGalleryAddr);
    expect(balanceGallery).to.equal(2);
  });
  it(`Should allow only to the owner to add an artwork`, async function () {
    let tokenUri =
      "https://bafybeicp7bwqf2awghts5fseqrlol7xrpt3ne66whsm2uzric6lysjdjam.ipfs.nftstorage.link/data/";
    let artGalleryInstanceForFirstUser = artGalleryInstance.connect(
      signers.firstUser
    );
    artGalleryInstanceForFirstUser.publishArtwork(tokenUri, 1, 100);
    expect().to.be.revertedWith("Ownable: caller is not the owner");
  });
});
describe("Put an NFT for sale", function () {
  it(`Should allow to put for sale an artwork`, async function () {
    let tokenUri =
      "https://bafybeicp7bwqf2awghts5fseqrlol7xrpt3ne66whsm2uzric6lysjdjam.ipfs.nftstorage.link/data/";

    let createColecction = await artGalleryInstance.publishArtworkForGallery(
      tokenUri,
      0,
      100
    );

    await artGalleryInstance.sellArtwork(0, 1 * 10 ** 15);
    expect(await artGalleryInstance.getTokenPrice(0)).to.equal(1 * 10 ** 15);
  });
});
describe("Buy an NFT", function () {
  it(`Should allow to buy an NFT`, async function () {
    let artGalleryInstanceForFirstUser = artGalleryInstance.connect(
      signers.firstUser
    );

    let buyToken = await artGalleryInstanceForFirstUser.buyArtwork(0, {
      value: ethers.utils.parseUnits(`${1 * 10 ** 15}`, "wei"),
    });
    buyToken.wait();

    expect(await tokenInstance.balanceOf(signers.firstUser.address)).to.equal(
      1
    );
  });
  it(`Should allow the gallery to recive royalty and seller the rest`, async function () {
    let tokenUri =
      "https://bafybeicp7bwqf2awghts5fseqrlol7xrpt3ne66whsm2uzric6lysjdjam.ipfs.nftstorage.link/data/";
    await artGalleryInstance.publishArtwork(
      tokenUri,
      5 * 10 ** 15,
      signers.firstUser.address,
      100
    );
    let artGalleryInstanceForSecondUser = artGalleryInstance.connect(
      signers.secondUser
    );
    let initialBalance = (
      await artGalleryInstance.getAddressBalance(artGalleryAddr)
    ).toNumber();

    let sellerInitialBalance = parseInt(
      (
        await artGalleryInstance.getAddressBalance(signers.firstUser.address)
      ).toBigInt()
    );

    let buyToken = await artGalleryInstanceForSecondUser.buyArtwork(3, {
      value: ethers.utils.parseUnits(`${5 * 10 ** 15}`, "wei"),
    });
    let updatedBalance = initialBalance + buyToken.value.toNumber() / 100;
    let getNewBalance = (
      await artGalleryInstance.getAddressBalance(artGalleryAddr)
    ).toNumber();
    expect(getNewBalance).to.equal(updatedBalance);
    let sellerUpdatedBalance =
      sellerInitialBalance +
      buyToken.value.toNumber() -
      buyToken.value.toNumber() / 100;

    let getNewBalanceSeller = parseInt(
      (
        await artGalleryInstance.getAddressBalance(signers.firstUser.address)
      ).toBigInt()
    );

    expect(getNewBalanceSeller).to.equal(sellerUpdatedBalance);
  });
});
describe("Withdraw Ethers", function () {
  it("Should allow the owner to withdraw ethers", async function () {
    let ownerBalance = await artGalleryInstance.getAddressBalance(
      signers.deployer.address
    );

    let contractBalance = await artGalleryInstance.getAddressBalance(
      artGalleryAddr
    );

    let withdrawal = await artGalleryInstance.withdraw(
      signers.deployer.address
    );
    let recipt = await withdrawal.wait();

    let gasFee = recipt.gasUsed.mul(recipt.effectiveGasPrice);
    let amountToWithdraw = ownerBalance.add(contractBalance).sub(gasFee);

    let ownerNewBalance = await artGalleryInstance.getAddressBalance(
      signers.deployer.address
    );

    expect(ownerNewBalance).to.equal(amountToWithdraw);
  });
  // it("Should be made by the owner", async function () {
  //   let fistUserInstance = artGalleryInstance.connect(signers.firstUser);
  //   fistUserInstance.setTokenPrice(2, 100);
  //   expect().to.be.revertedWith("Ownable: caller is not the owner");
  // });
});
