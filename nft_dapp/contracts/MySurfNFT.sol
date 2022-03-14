// SPDX-License-Identifier: CC-BY-SA-4.0


pragma solidity ^0.8.0;

// OpenZeppelin Contracts.
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";
import { Base64 } from "./libraries/Base64.sol";

// Inherit ERC721URIStorage
contract MySurfNFT is ERC721URIStorage {
  // OpenZeppelin magic to help keep track of tokenIds which are unique identifiers
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;
  uint public constant TOTAL_SUPPLY = 50;

  // baseSVG variable here is all that tha NFTs can use
  string baseSvg = "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><style>.base { fill: white; font-family: serif; font-size: 24px; }</style><rect width='100%' height='100%' fill='black' /><text x='50%' y='50%' class='base' dominant-baseline='middle' text-anchor='middle'>";

  // Three arrays, each with their own theme of random words
  string[] firstWords = ["SURF", "LORD", "TESLAGROM", "YEWWW", "CRYPTOGOD", "KOOKS"];
  string[] secondWords = ["GAMIFICATION", "WORMHOLE", "ARELIT", "WHATITDO", "AIRS", "OB415"];
  string[] thirdWords = ["BRUH", "HOOKFISHCO", "MARINLEGEND", "GOAT", "LOWTIDE", "SNAP"];

  event NewSurfNFTMinted(address sender, uint256 tokenId);

  // pass the name of NFTs token and its symbol.
  constructor() ERC721 ("USurfNFT", "SURF") {
    console.log("This is my NFT contract. Woah!");
  }

  // I create a function to randomly pick a word from each array.
  function pickRandomFirstWord(uint256 tokenId) public view returns (string memory) {
    // I seed the random generator.
    uint256 rand = random(string(abi.encodePacked("FIRST_WORD", Strings.toString(tokenId))));
    // Squash the # between 0 and the length of the array to avoid going out of bounds.
    rand = rand % firstWords.length;
    return firstWords[rand];
  }

  function pickRandomSecondWord(uint256 tokenId) public view returns (string memory) {
    uint256 rand = random(string(abi.encodePacked("SECOND_WORD", Strings.toString(tokenId))));
    rand = rand % secondWords.length;
    return secondWords[rand];
  }

  function pickRandomThirdWord(uint256 tokenId) public view returns (string memory) {
    uint256 rand = random(string(abi.encodePacked("THIRD_WORD", Strings.toString(tokenId))));
    rand = rand % thirdWords.length;
    return thirdWords[rand];
  }

  function random(string memory input) internal pure returns (uint256) {
      return uint256(keccak256(abi.encodePacked(input)));
  }

  //getter funciton to view the amount of tokens left in Mint 

  function getTotalNFTsMintdSoFar() public view returns (uint256) {
    return _tokenIds.current();
  }

  // A function our user will hit to get their NFT.
  function makeAnSurfNFT() public {
     // Get the current tokenId, this starts at 0.
    uint256 newItemId = _tokenIds.current();
    // require function that lets only up to 50 NFTs minted
    require(newItemId <= TOTAL_SUPPLY, "Only 50 NFTs are allowed!");
   

    // Randomly grab one word from each of the three arrays
    string memory first = pickRandomFirstWord(newItemId);
    string memory second = pickRandomSecondWord(newItemId);
    string memory third = pickRandomThirdWord(newItemId);
    string memory combinedWord = string(abi.encodePacked(first, second, third));

    // Concatenate it all together, and then close the <text> and <svg> tags.
    string memory finalSvg = string(abi.encodePacked(baseSvg, first, second, third, "</text></svg>"));

    // Get all the JSON metadata in place and base64 encode it.
    // Get all the JSON metadata in place and base64 encode it.
    string memory json = Base64.encode(
        bytes(
            string(
                abi.encodePacked(
                    '{"name": "',
                    // We set the title of our NFT as the generated word.
                    combinedWord,
                    '", "description": "A highly acclaimed collection of squares.", "image": "data:image/svg+xml;base64,',
                    // We add data:image/svg+xml;base64 and then append our base64 encode our svg.
                    Base64.encode(bytes(finalSvg)),
                    '"}'
                )
            )
        )
    );

    // prepend data:application/json;base64, to endoded SVG.
    string memory finalTokenUri = string(
        abi.encodePacked("data:application/json;base64,", json)
    );

    console.log("\n--------------------");
    console.log(finalTokenUri);
    console.log("--------------------\n");

     // Actually mint the NFT to the sender using msg.sender.
    _safeMint(msg.sender, newItemId);

    // Set the NFTs data using URI link
    _setTokenURI(newItemId, finalTokenUri);

    // Increment the counter for when the next NFT is minted.
    _tokenIds.increment();

    console.log("An NFT w/ ID %s has been minted to %s", newItemId, msg.sender);

    emit NewSurfNFTMinted(msg.sender, newItemId);
  }
}

