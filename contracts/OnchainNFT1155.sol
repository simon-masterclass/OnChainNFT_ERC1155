// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

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
    address public $AIM0wner;
    uint256 public constant $AIM0 = 0;
    uint256 public constant $AIM0bonus = 100;
    uint256 public constant max$AIM0supply = 10 ** 6; //max supply of $AIM0 for this Bravo Company collection is 1 million
    uint256 public minted$AIM0 = 0;

    //Bravo Company NFT variables
    uint256 public constant maxBRAVOsupply = 100;
    uint256[] public bravoIDs;
    address[] public bravoAddresses;
    string[] public bravoCodeNames;

    mapping(address => bool) private bravoMintedTF;
    mapping(uint256 => address) private bravoIDindex;
    mapping(address => uint) public missionCoinsEarned;

    constructor() ERC1155("") {
        $AIM0wner = msg.sender;
        //mint Max supply of $AIM0 minus 10000 to be minted by recruits later (for gas efficiency)
        minted$AIM0 = max$AIM0supply - 10000;
        _mint($AIM0wner, $AIM0, minted$AIM0, "");
        bravoIDs.push($AIM0);
        bravoCodeNames.push("$AIM0");
        bravoIDindex[$AIM0] = $AIM0wner;
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
            minted$AIM0 < max$AIM0supply,
            "Max supply of Bravo $AIM0 reached"
        );

        //mint new NFT for Bravo company recruit with code name
        _mint(msg.sender, newID, 1, "");
        bravoIDs.push(newID);
        bravoCodeNames.push(codeName);
        bravoMintedTF[msg.sender] = true;
        bravoIDindex[newID] = msg.sender;

        //mint 100 rounds of $AIM0 to the new recruit as enlistment bonus
        _mint(msg.sender, $AIM0, $AIM0bonus, "");
        minted$AIM0 += $AIM0bonus;
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

    function setBravoCodeName(
        uint256 tokenId,
        string memory _newCodeName
    ) public {
        require(
            bravoIDindex[tokenId] == msg.sender,
            "You are not the owner of this Bravo NFT"
        );
        require(bytes(_newCodeName).length <= 20, "Code name too long");
        require(bytes(_newCodeName).length > 0, "Code name too short");
        require(tokenId > $AIM0, "You cannot change the code name of $AIM0");

        bravoCodeNames[tokenId] = _newCodeName;
    }

    function buildImage(uint256 tokenId) internal view returns (string memory) {
        return
            Base64.encode(
                bytes(
                    abi.encodePacked(
                        '<svg width="555" height="555" xmlns="http://www.w3.org/2000/svg">',
                        '<rect stroke="#000" height="555" width="555" y="0" x="0" fill="hsl(',
                        randomNum(361, 3, 4).toString(),
                        ',100%,34%)" />',
                        '<text dominant-baseline="middle" text-anchor="middle" font-family="Impact" font-size="111" y="34%" x="50%" stroke="#000000" fill="#ffffff">ZERO ARMY</text>',
                        '<text dominant-baseline="middle" text-anchor="middle" font-family="Courier" font-size="55" stroke-width="2" y="50%" x="50%" stroke="#a10000" fill="#ffffff">BRAVO COMPANY</text>',
                        '<text dominant-baseline="middle" text-anchor="middle" font-family="Courier new" font-size="40" stroke-width="2" y="69%" x="50%" stroke="#ffffff" fill="#ffffff">',
                        bravoCodeNames[tokenId],
                        "</text>",
                        '<text dominant-baseline="middle" text-anchor="middle" font-family="Courier new" font-size="22" y="88%" x="50%" fill="#ffffff"> $AIM0: ',
                        balanceOf(bravoIDindex[tokenId], 0).toString(),
                        " Rounds</text>",
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
                                "Bravo Company",
                                '", "description":"',
                                "Zero Army founding team members. Go to zeroarmy.org for details.",
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
        bravoAddresses.push(bravoAddress);
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
