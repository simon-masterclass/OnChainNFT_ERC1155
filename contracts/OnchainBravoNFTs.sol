// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
//...............................................................................................................
//..ZZZZZZZZZ...EEEEEEEEE...RRRRR..........OOOOOO..............AAA.......RRRRR........MMM.....MMM...YY......YY...
//.ZZZZZZZZZZZ.EEEEEEEEEEE.RRRRRRRRRR.....OOOOOOOOO...........AAAAA.....RRRRRRRRRR...MMMMM...MMMMM.YYYYY...YYYY..
//.ZZZZZZZZZZZ.EEEEEEEEEEE.RRRRRRRRRRR...OOOOOOOOOO...........AAAAA.....RRRRRRRRRRR..MMMMM...MMMMM.YYYYY..YYYYY..
//.ZZZZZZZZZZZ.EEEEEEEEEEE.RRRRRRRRRRR..OOOOOOOOOOOO.........AAAAAAA....RRRRRRRRRRR..MMMMMM..MMMMM..YYYY..YYYY...
//......ZZZZZZ.EEEE........RRRR...RRRRR.OOOO....OOOO.........AAAAAAA....RRRR...RRRRR.MMMMMM.MMMMMM..YYYYYYYYYY...
//.....ZZZZZZ..EEEEEEEEEE..RRRR...RRRRR.OOOO....OOOOO........AAAAAAA....RRRR...RRRRR.MMMMMM.MMMMMM...YYYYYYYY....
//.....ZZZZZ...EEEEEEEEEE..RRRRRRRRRRR.OOOO......OOOO.......AAAAAAAAA...RRRRRRRRRRR..MMMMMM.MMMMMM...YYYYYYYY....
//....ZZZZZ....EEEEEEEEEE..RRRRRRRRRRR.OOOO......OOOO.......AAAA.AAAA...RRRRRRRRRRR..MMMMMM.MMMMMM....YYYYYY.....
//...ZZZZZ.....EEEEEEEEEE..RRRRRRRRRRR.OOOO......OOOO.......AAAAAAAAAA..RRRRRRRRRRR..MMMMMMMMMMMMM.....YYYYY.....
//..ZZZZZ......EEEE........RRRR..RRRRR..OOOO....OOOOO......AAAAAAAAAAA..RRRR..RRRRR..MMM.MMMMMMMMM.....YYYY......
//.ZZZZZZ......EEEE........RRRR...RRRR..OOOO....OOOO.......AAAAAAAAAAA..RRRR...RRRR..MMM.MMMMM.MMM.....YYYY......
//.ZZZZZZZZZZZ.EEEEEEEEEEE.RRRR...RRRR..OOOOOOOOOOOO.......AAAAAAAAAAAA.RRRR...RRRR..MMM.MMMMM.MMM.....YYYY......
//.ZZZZZZZZZZZ.EEEEEEEEEEE.RRRR...RRRR...OOOOOOOOOO....... AAAA....AAAA.RRRR...RRRR..MMM.MMMMM.MMM.....YYYY......
//.ZZZZZZZZZZZ.EEEEEEEEEEE.RRRR...RRRRR...OOOOOOOOO....... AAA.....AAAA.RRRR...RRRRR.MMM.MMMMM.MMM.....YYYY......
//.........................................OOOOOO................................................................
//...............................................................................................................
/// @author Simon G.Ionashku - find me on github: simon-masterclass
// This Bravo Company NFT collection is designed to incentives the first 100 volunteers/employees
// to enlist and claim their NFTs with $AIM0 rewards built in.
// This ERC-1155 contract is designed to contain both fungible and non-fungible tokens in a novel way
// Each NFT contains fungible tokens $AIM0 and these fungible $AIM0 tokens are soulbound to the NFT
// Every time a Bravo Company Commander Zero (AKA: C0) burns thier $AIM0 by using the
// fire$AIM0 function they earn Mission Coins (to be minted seperately using the records in this contract)
// in addition, every time a Bravo Company C0 burns 100 rounds of $AIM0 (ideally within the MetaSERVE), their NFT ranks up.
// The attributes that these NFTs contain will be useful with the Zero Army's MetaSERVE

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./Base64.sol";

library BravoLibrary {
    using Strings for uint256;
    using Base64 for bytes;

    //struct for cramming all the variables together to avoid stack too deep error
    struct Stack2deep {
        uint256 tokenId;
        uint256 color1;
        string comp2Color1;
        string rank;
        string bravoBoost;
        string codeName;
        string returnBalance;
        string unitName;
    }

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
            unitName = "ROUNDS";
        } else if (uint256(balance / (10 ** 16)) > 0) {
            returnBalance = (balance / (10 ** 16)).toString();
            unitName = "CENTI-ROUNDS";
        } else if (uint256(balance / (10 ** 12)) > 0) {
            returnBalance = (balance / (10 ** 12)).toString();
            unitName = "MICRO-ROUNDS";
        } else if (uint256(balance / (10 ** 9)) > 0) {
            returnBalance = (balance / (10 ** 9)).toString();
            unitName = "NANO-ROUNDS";
        } else if (uint256(balance / (10 ** 6)) > 0) {
            returnBalance = (balance / (10 ** 6)).toString();
            unitName = "PICO-ROUNDS";
        } else if (uint256(balance / (10 ** 3)) > 0) {
            returnBalance = (balance / (10 ** 3)).toString();
            unitName = "FEMTO-ROUNDS";
        } else {
            returnBalance = balance.toString();
            unitName = "ATTO-ROUNDS";
        }

        return (returnBalance, unitName);
    }

    function randomNum(
        uint256 _modulus,
        uint256 _seed,
        uint256 _salt
    ) public view returns (uint256) {
        uint256 randomNumber = uint256(
            keccak256(
                abi.encodePacked(block.timestamp, msg.sender, _salt, _seed)
            )
        );
        return randomNumber % _modulus;
    }

    function calcComplimentColor(
        uint256 compNum
    ) internal pure returns (uint256) {
        uint256 comp = compNum + 180;
        if (comp > 360) {
            comp = comp - 360;
        }
        return comp;
    }

    function renderHelper1(
        uint256 color1,
        string memory comp2Color1
    ) public view returns (bytes memory) {
        return
            abi.encodePacked(
                '<rect transform="rotate(-45 388.5 42)" stroke-width="22" fill="#000" x="0" y="-346.5" width="777" height="777" />',
                '<circle stroke="hsl(',
                comp2Color1,
                ', 77%, 34%)" stroke-dasharray="5,',
                (color1 % 34).toString(),
                ",",
                randomNum(69, 2, 7).toString(),
                '" stroke-width="24" cx="388.5" cy="488" r="134" fill="#000000" opacity="69%" />',
                '<text fill="#000000" stroke="hsl(',
                comp2Color1,
                ', 69%, 50%)" x="50%" y="222" stroke-width="2" font-size="69" font-family="futura" text-anchor="middle" dominant-baseline="middle">BRAVO COMPANY</text>'
            );
    }

    function renderHelper2(
        uint256 tokenId,
        string memory color1,
        string memory comp2Color1
    ) public pure returns (bytes memory) {
        if (tokenId == 0) {
            return "";
        } else {
            return
                abi.encodePacked(
                    '<circle stroke="hsl(',
                    comp2Color1,
                    ', 69%, 55%)" stroke-dasharray="2,2" stroke-width="7" cx="100" cy="495" r="69" fill="hsl(',
                    color1,
                    ', 69%, 55%)" opacity="69%" />',
                    '<text text-anchor="start" font-family="futura" font-size="18" y="490" x="74">RANK</text>',
                    '<circle stroke="hsl(',
                    comp2Color1,
                    ', 69%, 55%)" stroke-dasharray="2,2" stroke-width="7" cx="677" cy="495" r="69" fill="hsl(',
                    color1,
                    ', 69%, 55%)" opacity="69%" />',
                    '<text text-anchor="end" font-family="futura" font-size="18" y="490" x="709">BOOST</text>'
                );
        }
    }

    function renderHelper3(
        Stack2deep memory stack2deep
    ) public pure returns (bytes memory) {
        string memory tokenId = stack2deep.tokenId.toString();

        if (stack2deep.tokenId == 0) {
            stack2deep.bravoBoost = stack2deep.rank = "";
            tokenId = "O";
        }

        return
            abi.encodePacked(
                '<text font-family="futura" font-size="111" text-anchor="middle" dominant-baseline="middle" y="500" x="50%" stroke-width="4" stroke="#ffffff" fill="#000000">',
                tokenId,
                "</text>",
                '<text font-weight="bold" text-anchor="middle" font-family="futura" font-size="22" y="517" x="100" fill="hsl(',
                stack2deep.comp2Color1,
                ', 69%, 69%)">',
                stack2deep.rank,
                "</text>",
                '<text font-weight="bold" text-anchor="middle" font-family="futura" font-size="22" y="517" x="678" fill="hsl(',
                stack2deep.comp2Color1,
                ', 69%, 69%)">',
                stack2deep.bravoBoost
            );
    }

    function renderHelper4(
        Stack2deep memory stack2deep
    ) public pure returns (bytes memory) {
        return
            abi.encodePacked(
                "</text>",
                '<text fill="hsl(',
                stack2deep.color1.toString(),
                ', 69%, 69%)" x="50%" y="288" font-size="42" font-family="futura" text-anchor="middle" dominant-baseline="middle">',
                stack2deep.codeName,
                "</text>",
                '<rect stroke="#000000" stroke-dasharray="2,2,',
                (stack2deep.color1 % 21).toString(),
                ',7" stroke-width="17" x="34" y="662" width="711" height="100" opacity="88%" fill="#000000" rx="50" ry="50" />',
                '<text stroke-width="2" stroke="#ffffff" fill="#000000" x="50%" y="713" font-size="49" font-family="courier" text-anchor="middle" dominant-baseline="middle">$AIM0: ',
                stack2deep.returnBalance,
                " ",
                stack2deep.unitName,
                "</text>"
            );
    }

    function renderSVG(
        Stack2deep memory stack2deep
    ) public view returns (string memory) {
        return
            Base64.encode(
                bytes(
                    abi.encodePacked(
                        '<svg width="777" height="777" xmlns="http://www.w3.org/2000/svg">',
                        '<circle stroke="hsl(',
                        stack2deep.comp2Color1,
                        ', 69%, 55%)" stroke-dasharray="5,2,2,2,2,2" stroke-width="48" cx="388.5" cy="488" r="134" fill="#000000" />',
                        renderHelper1(
                            stack2deep.color1,
                            stack2deep.comp2Color1
                        ),
                        '<text fill="#ffffff" x="50%" y="117" font-size="122" font-family="futura" text-anchor="middle" dominant-baseline="middle">ZERO ARMY</text>',
                        renderHelper2(
                            stack2deep.tokenId,
                            stack2deep.color1.toString(),
                            stack2deep.comp2Color1
                        ),
                        renderHelper3(stack2deep),
                        renderHelper4(stack2deep),
                        "</svg>"
                    )
                )
            );
    }

    function renderMetadata(
        uint256 tokenId,
        string memory rank,
        string memory bravoBoost,
        string memory codeName,
        string memory returnBalance,
        string memory unitName
    ) public view returns (string memory) {
        uint256 color1 = randomNum(361, 3, 4);
        string memory comp2Color1 = calcComplimentColor(color1).toString();

        Stack2deep memory stack2deep = Stack2deep(
            tokenId,
            color1,
            comp2Color1,
            rank,
            bravoBoost,
            codeName,
            returnBalance,
            unitName
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
                                renderSVG(stack2deep),
                                '"}'
                            )
                        )
                    )
                )
            );
    }
}

contract OnchainBravoNFTs is ERC1155, ERC1155Burnable, Ownable, ERC1155Supply {
    using Strings for uint256;
    using BravoLibrary for uint256;

    //$AIM0 (fungible) token variables
    //NOTE: max supply of $AIM0 (fungible) tokens for this Bravo Company collection is 1 million
    //decimals = 10 ** 18 for $AIM0 & Mission Coins (fungible) tokens
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
    bool public fire$AIM0TF = false;

    constructor() ERC1155("") {
        //mint 1 million rounds of $AIM0 minus 10000 to be minted by recruits later (for gas efficiency)
        uint256 mintAIM0 = ((10 ** 6) * (10 ** 18)) - (10000 * (10 ** 18));
        _mint(owner(), $AIM0, mintAIM0, "");

        //first BravoNFT is the unburned $AIM0 supply
        BravoNFT memory newBravoNFT = BravoNFT({
            bravOwner: owner(),
            codeName: "$AIM0: UNBURNED SUPPLY",
            missionCoinsEarned: 0,
            rank: 0,
            bravoBoost: 0
        });

        bravoNFT$.push(newBravoNFT);
    }

    function mint(string memory codeName) public payable {
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
            rank: 0,
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
    ) public payable {
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
                tokenId,
                bravoNFT$[tokenId].rank.toString(),
                bravoNFT$[tokenId].bravoBoost.toString(),
                bravoNFT$[tokenId].codeName,
                returnBalance,
                unitName
            );
    }

    function enlistBravo(address bravoAddress) public payable onlyOwner {
        bravoAddressTF[bravoAddress] = true;
    }

    function payBravo(
        uint256 tokenId,
        uint256 amount,
        bytes calldata data
    ) public payable onlyOwner {
        //pay Bravo NFT owner $AIM0
        _safeTransferFrom(
            msg.sender,
            bravoNFT$[tokenId].bravOwner,
            $AIM0,
            amount,
            data
        );
    }

    function toggle$AIM0firing() public payable onlyOwner {
        fire$AIM0TF = !fire$AIM0TF;
    }

    function fire$AIM0(uint256 tokenId, uint256 amount) public payable {
        require(fire$AIM0TF == true, "firing $AIM0 is disabled");
        require(
            balanceOf(msg.sender, $AIM0) >= amount,
            "You don't have enough $AIM0"
        );
        require(
            bravoNFT$[tokenId].bravOwner == msg.sender,
            "You are not the owner of this Bravo NFT"
        );

        _burn(msg.sender, $AIM0, amount);
        // Mission coins earned after burning - to be minted later when system is fully operational
        bravoNFT$[tokenId].missionCoinsEarned += amount;
        //rank up after burning 100 $AIM0
        bravoNFT$[tokenId].rank = uint256(
            bravoNFT$[tokenId].missionCoinsEarned / (100 * (10 ** 18))
        );
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

    function withdraw() public payable onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
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
