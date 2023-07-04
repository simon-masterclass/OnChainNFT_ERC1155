// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";

contract OnchainNFT1155 is ERC1155, ERC1155Burnable, Ownable, ERC1155Supply {
    address public AIM0wner = address(this);
    uint256 public constant AIM0 = 0;
    uint256 public constant AIM0bonus = 100;
    uint256 public constant maxAIM0supply = 10000;
    uint256 public constant maxBRAVOsupply = 100;

    uint256[] public bravoIDs;
    string[] public bravoCodeNames;

    constructor() ERC1155("") {
        _mint(AIM0wner, AIM0, maxAIM0supply, "");
        bravoIDs.push(AIM0);
        bravoCodeNames.push("C0");
    }

    function mint(string memory codeName) public {
        require(
            bravoIDs.length <= maxBRAVOsupply,
            "Max supply of Bravo NFTs reached"
        );
        //mint new soul bound NFT for Bravo company recruit with code name
        _mint(msg.sender, bravoIDs.length, 1, "");
        bravoIDs.push(bravoIDs.length);
        bravoCodeNames.push(codeName);
        //transfer 100 rounds of AIM0 to the new recruit as enlistment bonus
        _safeTransferFrom(AIM0wner, msg.sender, AIM0, AIM0bonus, "");
    }

    function mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public onlyOwner {
        _mintBatch(to, ids, amounts, data);
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
        require(
            to == address(0) || msg.sender == AIM0wner,
            "Tokens are soul bound & cannot be transferred, only burned."
        );
    }
}
