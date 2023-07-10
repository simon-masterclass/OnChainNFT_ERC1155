// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
//ZERO ARMY Bravo Company collection

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./Base64.sol";

contract OnchainNFT1155 is ERC1155, ERC1155Burnable, Ownable, ERC1155Supply {
    using Base64 for bytes;
    using Strings for uint256;
    //$AIM0 (fungible) token variables
    //NOTE: max supply of $AIM0 (fungible) tokens for this Bravo Company collection is 1 million
    uint256 private constant $AIM0 = 0; //token ID for $AIM0 (fungible) token
    uint256 private constant decimals = 10 ** 18; //decimals for $AIM0 & Mission Coins (fungible) token

    //Bravo Company NFT variables
    //NOTE: max supply of NFTs for this Bravo Company collection is 100
    uint256[] private bravoIDs;
    string[] public bravoCodeNames;
    mapping(address => bool) private bravoAddressTF;
    mapping(uint256 => address) private bravoIDindex;

    //Mission Coin variables
    mapping(address => uint) public missionCoinsEarned;
    bool public burnAIM0TF = false;

    constructor() ERC1155("") {
        //mint 1 million rounds of $AIM0 minus 10000 to be minted by recruits later (for gas efficiency)
        uint256 mintAIM0 = ((10 ** 6) * decimals) - (10000 * decimals);
        _mint(owner(), $AIM0, mintAIM0, "");
        bravoIDs.push($AIM0);
        bravoCodeNames.push("Unburned $AIM0 Supply");
        bravoIDindex[$AIM0] = owner();
    }

    function mint(string memory codeName) public {
        require(
            bravoAddressTF[msg.sender] == true,
            "You are not on Bravo NFT mint list"
        );
        require(bytes(codeName).length <= 20, "Code name too long");
        require(bytes(codeName).length > 0, "Code name too short");
        uint256 newID = bravoIDs.length;
        require(newID <= 100, "Max supply of 100 Bravo NFTs reached");

        //Bravo NFT variables - add new Bravo NFT to the collection
        bravoIDs.push(newID);
        bravoIDindex[newID] = msg.sender;
        bravoCodeNames.push(codeName);
        bravoAddressTF[msg.sender] = false;

        //mint new NFT for Bravo company recruit with code name
        _mint(msg.sender, newID, 1, "");

        //mint 100 rounds of $AIM0 to the new recruit as enlistment bonus
        _mint(msg.sender, $AIM0, 100 * decimals, "");
    }

    function randomNum(
        uint256 _modulus,
        uint256 _seed,
        uint256 _salt
    ) internal view returns (uint256) {
        uint256 randomNumber = uint256(
            keccak256(
                abi.encodePacked(block.timestamp, msg.sender, _salt, _seed)
            )
        );
        return randomNumber % _modulus;
    }

    function changeBravoCodeName(
        uint256 tokenId,
        string memory _newCodeName
    ) public {
        require(
            bravoIDindex[tokenId] == msg.sender,
            "You are not the owner of this Bravo NFT"
        );
        require(bytes(_newCodeName).length <= 20, "Code name too long");
        require(bytes(_newCodeName).length > 0, "Code name too short");

        bravoCodeNames[tokenId] = _newCodeName;
    }

    function buildImage(uint256 tokenId) internal view returns (string memory) {
        string memory returnBalance = "";
        if (tokenId == $AIM0) {
            returnBalance = (totalSupply($AIM0) / (10 ** 9)).toString();
        } else {
            returnBalance = (balanceOf(bravoIDindex[tokenId], $AIM0) /
                (10 ** 9)).toString();
        }
        return
            Base64.encode(
                bytes(
                    abi.encodePacked(
                        '<svg width="777" height="777" xmlns="http://www.w3.org/2000/svg">',
                        '<rect stroke="#000" height="777" width="777" y="0" x="0" fill="hsl(',
                        randomNum(361, 3, 4).toString(),
                        ',100%,34%)" />',
                        '<text dominant-baseline="middle" text-anchor="middle" font-family="Impact" font-size="169" y="34%" x="50%" stroke="#000000" fill="#ffffff">ZERO ARMY</text>',
                        '<text dominant-baseline="middle" text-anchor="middle" font-family="Courier" font-size="69" stroke-width="2" y="50%" x="50%" stroke="#a10000" fill="#ffffff">BRAVO COMPANY</text>',
                        '<text dominant-baseline="middle" text-anchor="middle" font-family="Courier new" font-size="40" stroke-width="2" y="69%" x="50%" stroke="#ffffff" fill="#ffffff">',
                        bravoCodeNames[tokenId],
                        "</text>",
                        '<text dominant-baseline="middle" text-anchor="middle" font-family="Courier new" font-size="22" y="88%" x="50%" fill="#ffffff"> $AIM0: ',
                        returnBalance,
                        " nano-rounds</text>",
                        "</svg>"
                    )
                )
            );
    }

    function uri(uint256 tokenId) public view override returns (string memory) {
        require(
            exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name":"',
                                "BravoC0 #",
                                tokenId.toString(),
                                '", "description":"',
                                "Bravo Company NFT collection. Zero Army founding team member NFTs - Only 100. Go to zeroarmy.org for details.",
                                '", "external_url":"',
                                "https://zeroarmy.org/bravo",
                                '", "image":"',
                                "data:image/svg+xml;base64,",
                                buildImage(tokenId),
                                '"}'
                            )
                        )
                    )
                )
            );
    }

    function enlistBravo(address bravoAddress) public onlyOwner {
        bravoAddressTF[bravoAddress] = true;
    }

    function toggleAIM0burning() public onlyOwner {
        burnAIM0TF = !burnAIM0TF;
    }

    function fireAIM0(uint amount) public {
        require(burnAIM0TF == true, "Burning $AIM0 is disabled");
        require(
            balanceOf(msg.sender, $AIM0) >= amount,
            "You don't have enough $AIM0"
        );

        _burn(msg.sender, $AIM0, amount);
        // Mission coins earned after burning - to be minted later when system is fully operational
        missionCoinsEarned[msg.sender] += amount;
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public override {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not token owner or approved"
        );
        require(balanceOf(from, id) > 0, "ERC1155: you don't have this token");

        if (id == $AIM0) {
            _safeTransferFrom(from, to, id, amount, data);
        } else {
            //transfer Bravo NFT along with all $AIM0 to new owner
            uint256[] memory ids = new uint256[](2);
            ids[0] = $AIM0;
            ids[1] = id;

            uint256[] memory amounts = new uint256[](2);
            amounts[0] = balanceOf(from, $AIM0);
            amounts[1] = 1;

            _safeBatchTransferFrom(from, to, ids, amounts, data);
            bravoIDindex[id] = to;
        }
    }

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public override {
        //disabled batch transfer for this contract
        bool disableBatchTransfer = true;
        require(disableBatchTransfer == false, "Batch transfer disabled");
        // require(
        //     from == _msgSender() || isApprovedForAll(from, _msgSender()),
        //     "ERC1155: caller is not token owner or approved"
        // );
        _safeBatchTransferFrom(from, to, ids, amounts, data);
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
