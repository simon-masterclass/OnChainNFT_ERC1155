// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
//ZERO ARMY Bravo Company collection

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./Base64.sol";

library BravoLibrary {
    using Strings for uint256;
    using Base64 for bytes;

    function calculateUnits(
        uint balance
    )
        public
        pure
        returns (string memory returnBalance, string memory unitName)
    {
        //calculate units
        if (uint256(balance / (10 ** 18)) > 0) {
            returnBalance = (balance / (10 ** 18)).toString();
            unitName = "Rounds";
        } else if (uint256(balance / (10 ** 16)) > 0) {
            returnBalance = (balance / (10 ** 16)).toString();
            unitName = "centi-rounds";
        } else if (uint256(balance / (10 ** 15)) > 0) {
            returnBalance = (balance / (10 ** 15)).toString();
            unitName = "milli-rounds";
        } else if (uint256(balance / (10 ** 12)) > 0) {
            returnBalance = (balance / (10 ** 12)).toString();
            unitName = "micro-rounds";
        } else if (uint256(balance / (10 ** 9)) > 0) {
            returnBalance = (balance / (10 ** 9)).toString();
            unitName = "nano-rounds";
        } else if (uint256(balance / (10 ** 6)) > 0) {
            returnBalance = (balance / (10 ** 6)).toString();
            unitName = "pico-rounds";
        } else if (uint256(balance / (10 ** 3)) > 0) {
            returnBalance = (balance / (10 ** 3)).toString();
            unitName = "femto-rounds";
        } else {
            returnBalance = balance.toString();
            unitName = "atto-rounds";
        }

        return (returnBalance, unitName);
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

    function renderSVG(
        string memory codeName,
        string memory returnBalance,
        string memory unitName
    ) public view returns (string memory) {
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
                        codeName,
                        "</text>",
                        '<text dominant-baseline="middle" text-anchor="middle" font-family="Courier new" font-size="22" y="88%" x="50%" fill="#ffffff"> $AIM0: ',
                        returnBalance,
                        " ",
                        unitName,
                        "</text>",
                        "</svg>"
                    )
                )
            );
    }

    function renderMetadata(
        string memory tokenId,
        string memory rank,
        string memory bravoBoost,
        string memory codeName,
        string memory returnBalance,
        string memory unitName
    ) public view returns (string memory) {
        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name":"',
                                "BravoC0 #",
                                tokenId,
                                '", "description":"',
                                "Bravo Company NFT collection - 100 Zero Army founders series NFTs.",
                                '", "external_url":"',
                                "https://zeroarmy.org/bravo",
                                '", "attributes":[{"trait_type":"Rank","value":',
                                rank,
                                "},",
                                '{"display_type": "boost_number","trait_type":"Bravo Boost","value":',
                                bravoBoost,
                                "}]",
                                '", "image":"',
                                "data:image/svg+xml;base64,",
                                renderSVG(codeName, returnBalance, unitName),
                                '"}'
                            )
                        )
                    )
                )
            );
    }
}

contract OnchainNFT1155 is ERC1155, ERC1155Burnable, Ownable, ERC1155Supply {
    using Strings for uint256;
    using BravoLibrary for uint256;

    //$AIM0 (fungible) token variables
    //NOTE: max supply of $AIM0 (fungible) tokens for this Bravo Company collection is 1 million
    //decimals = 10 ** 18 for $AIM0 & Mission Coins (fungible) token
    uint256 private constant $AIM0 = 0; //token ID for $AIM0 (fungible) token

    //Bravo Company NFT variables & attrtibutes
    //NOTE: max supply of NFTs for this Bravo Company collection is 100
    struct BravoNFT {
        address bravOwner;
        string codeName;
        uint256 missionCoinsEarned;
        uint256 rank;
        uint256 bravoBoost;
    }

    BravoNFT[] public bravoNFT$;

    //enlistment whitelist
    mapping(address => bool) private bravoAddressTF;

    //enable burning of $AIM0 tokens for mission coins
    bool public fireAIM0TF = false;

    constructor() ERC1155("") {
        //mint 1 million rounds of $AIM0 minus 10000 to be minted by recruits later (for gas efficiency)
        uint256 mintAIM0 = ((10 ** 6) * (10 ** 18)) - (10000 * (10 ** 18));
        _mint(owner(), $AIM0, mintAIM0, "");

        //first BravoNFT is the unburned $AIM0 supply
        BravoNFT memory newBravoNFT = BravoNFT({
            bravOwner: owner(),
            codeName: "Unburned $AIM0 Supply",
            missionCoinsEarned: 0,
            rank: 0,
            bravoBoost: 0
        });

        bravoNFT$.push(newBravoNFT);
    }

    function mint(string memory codeName) public {
        require(
            bravoAddressTF[msg.sender] == true,
            "You are not on Bravo NFT mint list"
        );
        require(bytes(codeName).length <= 20, "Code name too long");
        require(bytes(codeName).length > 0, "Code name too short");
        uint256 newID = bravoNFT$.length;
        require(newID <= 100, "Max supply of 100 Bravo NFTs reached");

        //Bravo NFT variables - add new Bravo NFT to the collection
        BravoNFT memory newBravoNFT = BravoNFT({
            bravOwner: msg.sender,
            codeName: codeName,
            missionCoinsEarned: 0,
            rank: 1,
            bravoBoost: 111 + BravoLibrary.randomNum(1000, newID, 34)
        });

        bravoNFT$.push(newBravoNFT);

        bravoAddressTF[msg.sender] = false;

        //mint new NFT for Bravo company recruit with code name
        _mint(msg.sender, newID, 1, "");

        //mint 100 rounds of $AIM0 to the new recruit as enlistment bonus
        _mint(msg.sender, $AIM0, 100 * (10 ** 18), "");
    }

    function changeBravoCodeName(
        uint256 tokenId,
        string memory _newCodeName
    ) public {
        require(
            bravoNFT$[tokenId].bravOwner == msg.sender,
            "You are not the owner of this Bravo NFT"
        );
        require(bytes(_newCodeName).length <= 20, "Code name too long");
        require(bytes(_newCodeName).length > 0, "Code name too short");

        bravoNFT$[tokenId].codeName = _newCodeName;
    }

    function uri(uint256 tokenId) public view override returns (string memory) {
        require(
            exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        //calculate balance
        uint balance = 0;
        if (tokenId == $AIM0) {
            balance = totalSupply($AIM0);
        } else {
            balance = balanceOf(bravoNFT$[tokenId].bravOwner, $AIM0);
        }

        (string memory returnBalance, string memory unitName) = BravoLibrary
            .calculateUnits(balance);

        return
            BravoLibrary.renderMetadata(
                tokenId.toString(),
                bravoNFT$[tokenId].rank.toString(),
                bravoNFT$[tokenId].bravoBoost.toString(),
                bravoNFT$[tokenId].codeName,
                returnBalance,
                unitName
            );
    }

    function enlistBravo(address bravoAddress) public onlyOwner {
        bravoAddressTF[bravoAddress] = true;
    }

    function payBravo(
        uint256 tokenId,
        uint256 amount,
        bytes calldata data
    ) public onlyOwner {
        //pay Bravo NFT owner $AIM0
        _safeTransferFrom(
            msg.sender,
            bravoNFT$[tokenId].bravOwner,
            $AIM0,
            amount,
            data
        );
    }

    function toggleAIM0firing() public onlyOwner {
        fireAIM0TF = !fireAIM0TF;
    }

    function fireAIM0(uint256 tokenID, uint256 amount) public {
        require(fireAIM0TF == true, "firing $AIM0 is disabled");
        require(
            balanceOf(msg.sender, $AIM0) >= amount,
            "You don't have enough $AIM0"
        );

        _burn(msg.sender, $AIM0, amount);
        // Mission coins earned after burning - to be minted later when system is fully operational
        bravoNFT$[tokenID].missionCoinsEarned += amount;
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
        require(id > 0, "ERC1155: $AIM0 is not transferable");
        require(amount == 1, "ERC1155: Only 1 Bravo NFT can be transferred");

        //transfer Bravo NFT along with all $AIM0 to new owner
        uint256[] memory ids = new uint256[](2);
        ids[0] = $AIM0;
        ids[1] = id;

        uint256[] memory amounts = new uint256[](2);
        amounts[0] = balanceOf(from, $AIM0);
        amounts[1] = 1;

        _safeBatchTransferFrom(from, to, ids, amounts, data);
        bravoNFT$[id].bravOwner = to;
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
