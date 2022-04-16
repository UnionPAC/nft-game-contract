// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import 'hardhat/console.sol';
import '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./libraries/Base64.sol";

contract MyEpicGame is ERC721 {

    // Character Attributes
    struct CharacterAttributes {
        uint256 characterIndex;
        string name;
        string imageURI;
        uint hp;
        uint maxHp;
        uint attackDamage;
    }

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    CharacterAttributes[] defaultCharacters;

    // tokenID => that NFT's attributes
    mapping(uint256 => CharacterAttributes) public nftHolderAttributes;

    // NFT holder => TokenID
    mapping(address => uint256) public nftHolders;

    // Events
    event CharacterNFTMinted(address sender, uint256 tokenId, uint256 characterIndex);
    event AttackComplete(uint newBossHp, uint newPlayerHp);

    struct FinalBoss {
        string name;
        string imageURI;
        uint hp;
        uint maxHp;
        uint attackDamage;
    }

    FinalBoss public finalBoss;

    constructor(
        string[] memory characterNames,
        string[] memory characterImageURIs,
        uint[] memory characterHp,
        uint[] memory characterAttackDmg,
        string memory bossName,
        string memory bossImageURI,
        uint bossHp,
        uint bossAttackDamage
    )
    ERC721("Inuyasha World Slayer", "IWS")
    {

        // Initialize boss
        finalBoss = FinalBoss({
            name: bossName,
            imageURI: bossImageURI,
            hp: bossHp,
            maxHp: bossHp,
            attackDamage: bossAttackDamage
        });

        console.log("Initialized the final boss, %s with %s HP | img: %s", finalBoss.name, finalBoss.hp, finalBoss.imageURI);


        // Looping through all characters, and save their values in our contract
        for(uint i = 0; i < characterNames.length; i++) {
            defaultCharacters.push(CharacterAttributes({
                characterIndex: i,
                name: characterNames[i],
                imageURI: characterImageURIs[i],
                hp: characterHp[i],
                maxHp: characterHp[i],
                attackDamage: characterAttackDmg[i]
            }));

            // What does this mean?
            CharacterAttributes memory c = defaultCharacters[i];
            console.log("Initialized %s with %s HP, img: %s", c.name, c.hp, c.imageURI);
        }
        _tokenIds.increment();
    }

    function mintCharacterNFT(uint256 _characterIndex) external {
        uint256 newItemId = _tokenIds.current();
        _safeMint(msg.sender, newItemId);

        nftHolderAttributes[newItemId] = CharacterAttributes({
            characterIndex: _characterIndex,
            name: defaultCharacters[_characterIndex].name,
            imageURI: defaultCharacters[_characterIndex].imageURI,
            hp: defaultCharacters[_characterIndex].hp,
            maxHp: defaultCharacters[_characterIndex].hp,
            attackDamage: defaultCharacters[_characterIndex].attackDamage
        });
        console.log("Minted NFT w/ tokenId %s and characterIndex %s", newItemId, _characterIndex);

        nftHolders[msg.sender] = newItemId;

        _tokenIds.increment();

        emit CharacterNFTMinted(msg.sender, newItemId, _characterIndex);

    }


    function tokenURI(uint256 _tokenId) public view override returns (string memory) {
        CharacterAttributes memory charAttributes = nftHolderAttributes[_tokenId];

        string memory strHp = Strings.toString(charAttributes.hp);
        string memory strMaxHp = Strings.toString(charAttributes.maxHp);
        string memory strAttackDamage = Strings.toString(charAttributes.attackDamage);

        string memory json = Base64.encode(abi.encodePacked(
            '{"name": "', charAttributes.name,
            ' - NFT # ', Strings.toString(_tokenId),
            '", "description": "This NFT lets people play in the game Inuyasha World Slayer!", "image": "ipfs://',
            charAttributes.imageURI,
            '", "attributes": [{ "trait_type": "Health Points", "value": ',strHp,', "max_value":',strMaxHp,'}, { "trait_type": "Attack Damage", "value": ',
            strAttackDamage,'} ]}'
        ));

        string memory output = string(abi.encodePacked("data:application/json;base64,", json));

        return output;
    }

    function attackBoss() public {
        // get the state of the player's NFT
        // create variable to hold the token ID of the player
        uint256 nftTokenIdOfPlayer = nftHolders[msg.sender];
        // use that tokenID to get the attributes of their NFT and assign it to player
        CharacterAttributes storage player = nftHolderAttributes[nftTokenIdOfPlayer];

        console.log("\nPlayer with character %s about to attack... Player has %s HP and %s Attack", player.name, player.hp, player.attackDamage);
        console.log("%s has %s HP and %s Attack", finalBoss.name, finalBoss.hp, finalBoss.attackDamage);


        // make sure the player has more than 0 HP
        require(player.hp > 0, "Player's health must be greater than 0 HP to attack!");

        // make sure the boss has more than 0 HP
        require(finalBoss.hp > 0, "Boss is already dead!");

        // allow players to attack boss
        if(finalBoss.hp < player.attackDamage) {
            finalBoss.hp = 0;
        } else {
            finalBoss.hp = finalBoss.hp - player.attackDamage;
        }
        // allow boss to attack player
        if(player.hp < finalBoss.attackDamage) {
            player.hp = 0;
        } else {
            player.hp = player.hp - finalBoss.attackDamage;
        }

        emit AttackComplete(finalBoss.hp, player.hp);

        console.log("%s attacked boss... Boss now has %s HP!", player.name, finalBoss.hp);
        console.log("%s attacked player... Player now has %s HP!", finalBoss.name, player.hp);
    }


    function checkIfUserHasNFT() public view returns (CharacterAttributes memory) {
        // get the tokenId of the user's character NFT
        uint256 userNftTokenId = nftHolders[msg.sender];

        // if the user has a tokenId in the map, return their character
        if (userNftTokenId > 0) {
            return nftHolderAttributes[userNftTokenId];
        } else {

         // else, return an empty character
            CharacterAttributes memory emptyStruct;
            return emptyStruct;
        }
    }

    function getAllDefaultCharacters() public view returns (CharacterAttributes[] memory) {
        return defaultCharacters;
    }

    function getFinalBoss() public view returns (FinalBoss memory) {
        return finalBoss;
    }

}