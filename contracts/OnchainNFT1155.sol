// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";

contract OnchainNFT1155 is ERC1155, ERC1155Burnable, Ownable, ERC1155Supply {
    address public $AIM0wner;
    uint256 public constant $AIM0 = 0;
    uint256 public constant $AIM0bonus = 100;
    uint256 public constant max$AIM0supply = 10 ** 6; //max supply of $AIM0 for this Bravo Company collection is 1 million
    uint256 public minted$AIMO = 0;
    uint256 public constant maxBRAVOsupply = 100;

    uint256[] public bravoIDs;
    address[] public bravoAddresses;
    string[] public bravoCodeNames;

    mapping(address => bool) private bravoMintedTF;

    constructor() ERC1155("") {
        $AIM0wner = msg.sender;
        //mint Max supply of $AIM0 minus 10000 to be minted by recruits later (for gas efficiency)
        minted$AIMO = max$AIM0supply - 10000;
        _mint($AIM0wner, $AIM0, minted$AIMO, "");
        bravoIDs.push($AIM0);
        bravoCodeNames.push("$AIM0");
    }

    function mint(string memory codeName) public {
        require(
            bravoMintedTF[msg.sender] == false,
            "You have already minted your Bravo NFT"
        );
        bool isEnlisted = false;
        for (uint i = 0; i < bravoAddresses.length; i++) {
            if (bravoAddresses[i] == msg.sender) {
                isEnlisted = true;
                break;
            }
        }
        require(isEnlisted == true, "You are not enlisted in Bravo Company");
        uint256 newID = bravoIDs.length;
        require(newID <= maxBRAVOsupply, "Max supply of Bravo NFTs reached");
        require(
            minted$AIMO < max$AIM0supply,
            "Max supply of Bravo $AIM0 reached"
        );

        //mint new NFT for Bravo company recruit with code name
        _mint(msg.sender, newID, 1, "");
        bravoIDs.push(newID);
        bravoCodeNames.push(codeName);
        bravoMintedTF[msg.sender] == true;

        //mint 100 rounds of $AIM0 to the new recruit as enlistment bonus
        _mint(msg.sender, $AIM0, $AIM0bonus, "");
        minted$AIMO += $AIM0bonus;
    }

    function uri(uint256 tokenId) public view override returns (string memory) {
        return
            (tokenId == $AIM0)
                ? "https://onchainnft.com/aim0"
                : string(
                    abi.encodePacked(
                        "https://onchainnft.com/",
                        bravoCodeNames[tokenId]
                    )
                );
    }

    function enlistBravo(address bravoAddress) public onlyOwner {
        bravoAddresses.push(bravoAddress);
    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal override(ERC1155, ERC1155Supply) {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }
}
