const main = async () => {
    const nftContractFactory = await hre.ethers.getContractFactory('MySurfNFT'); // Compile the contract 
    const nftContract = await nftContractFactory.deploy();
    await nftContract.deployed();
    console.log("Contract deployed to:", nftContract.address);
  
  // Call the makeAnSurfNFT function
  let txn = await nftContract.makeAnSurfNFT()
  // Wait for it to be mined by Hardhat miners hehe
  await txn.wait()

  // Mint another NFT 
  txn = await nftContract.makeAnSurfNFT()
  // wait for it to be mined...
  await txn.wait()

};


  const runMain = async () => {
    try {
      await main();
      process.exit(0);
    } catch (error) {
      console.log(error);
      process.exit(1);
    }
  };
  
  runMain();