const main = async () => {
  const gameContractFactory = await ethers.getContractFactory("MyEpicGame");
  const gameContract = await gameContractFactory.deploy(
    ["Sango", "Shippo", "Inuyasha"],
    [
      "bafybeicsqteyfhsezm7rv37daqsh6rjn6vrsdgfzgwmwjyufrh6qjr3fze",
      "bafybeidg5il4nyhipxbifhezwx3vbd3z6dkpfd3jzxxo473s7m6t2jhymm",
      "",
    ],
    ["300", "100", "500"],
    [75, 50, 150],
    "Sesshōmaru",
    "https://cdn.anime-planet.com/characters/primary/sesshomaru-1.jpg?t=1625773611",
    "2000",
    "30"
  );
  await gameContract.deployed();
  console.log("Contract deployed to:", gameContract.address);
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
