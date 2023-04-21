pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * Deployed on Goreli testnet
 * ERC20 - 0xc32F33C2e737f81bdC3aea0a9B1532e584D6daf9
 * MarketplaceToken - 0x80b38373e30CeA5602908d32ebE4f5C662d1993A, 0x320D2ac0fA4f303cdB6342CC2bD5416e89212774
 * Marketplace - 0x550c7875aDD515505796f0C58Cf187FB63C07776

 * Account - 0x68028E1D7523d18683c508f0a3eB8B0d847E8Ea1
*/


contract Marketplace {
    struct Item {
        uint256 id;
        address payable seller;
        uint256 price;
        bool sold;
        bool canceled;
        string title;
        string description;
    }

    mapping(uint256 => Item) public items;
    uint256 public itemCount;
    ERC20 public tokenContract;

    event ItemCreated(uint256 id, address payable seller, uint256 price);

    event ItemSold(uint256 id, address payable buyer, uint256 price);

    constructor(address _tokenContract) {
        tokenContract = ERC20(_tokenContract);
    }

    function createItem(string memory _title, string memory _description, uint256 _price) public {
        require(_price > 0, "Price must be greater than 0.");
        itemCount++;
        items[itemCount] = Item(itemCount, payable(msg.sender), _price, false, false, _title, _description);
        emit ItemCreated(itemCount, payable(msg.sender), _price);
    }


    // before transfering ownership check is item is already sold or not and if account have enough balance
    function buyItem(uint256 _id) public {
        Item memory item = items[_id];
        require(item.sold == false, "Item is already sold.");
        require(
            tokenContract.balanceOf(msg.sender) >= item.price,
            "Insufficient balance."
        );
        tokenContract.transferFrom(msg.sender, item.seller, item.price);
        item.sold = true;
        items[_id] = item;
        emit ItemSold(_id, payable(msg.sender), item.price);
    }

    function getItem(uint256 _id) public view returns (uint256, address, uint256, bool, bool, string memory, string memory) {
        Item memory item = items[_id];
        return (item.id, item.seller, item.price, item.sold, item.canceled, item.title, item.description);
    }

    //  fetch the list of all items
    function getAllItems() public view returns (Item[] memory) {
        Item[] memory allItems = new Item[](itemCount);
        for (uint256 i = 1; i <= itemCount; i++) {
            allItems[i - 1] = items[i];
        }
        return allItems;
    }

    //  only owner/creator of the item can trigger this
    //  trigger ItemSold with 0 price
    function cancelSale(uint256 _id) public {
        Item memory item = items[_id];
        require(msg.sender == item.seller, "Only seller can cancel the sale.");
        require(item.sold == false, "Item is already sold.");
        item.sold = true;
        item.canceled = true;
        items[_id] = item;
        emit ItemSold(_id, payable(address(0)), 0);
    }
}

contract MarketplaceToken is ERC20, Ownable {
    constructor() ERC20("Marketplace Token", "MPT") {}

    function mint(address _to, uint256 _amount) public onlyOwner {
        _mint(_to, _amount);
    }

    function burn(address _from, uint256 _amount) public onlyOwner {
        _burn(_from, _amount);
    }
}
