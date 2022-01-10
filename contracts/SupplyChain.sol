// SPDX-License-Identifier: MIT
pragma solidity >=0.5.16 <0.9.0;

contract SupplyChain {
    address public owner;

    uint public skuCount;

    mapping( uint => Item ) public items;

    enum State {
        ForSale,
        Sold,
        Shipped,
        Received
    }

    struct Item {
        string name;
        uint sku;
        uint price;
        State state;
        address payable seller;
        address payable buyer;
    }

    event LogForSale(uint256 sku);
    event LogSold(uint256 sku);
    event LogShipped(uint256 sku);
    event LogReceived(uint256 sku);
    
    modifier isOwner(uint ssku) {
      require(owner == msg.sender);
      _;
  }

    modifier verifyCaller(address _address) {
        require(msg.sender == _address);
        _;
    }

    modifier paidEnough(uint256 _price) {
        require(msg.value >= _price);
        _;
    }

    modifier checkValue(uint256 _sku) {
        _;
        uint _price = items[_sku].price;
        uint amountToRefund = msg.value - _price;
        items[_sku].buyer.transfer(amountToRefund);
    }


    modifier forSale(uint256 psku){
      require(items[psku].state == State.ForSale); 
      _;     
    }
    modifier sold(uint _sku){
      require(items[_sku].state == State.Sold); 
      _;  
    }
    modifier shipped(uint _Itemsku){
      require(items[_Itemsku].state == State.Shipped); 
      _;  
    }
    modifier received(uint _sku){
      require(items[_sku].state == State.Received); 
      _;  
    }

    constructor() public {
        owner = msg.sender;
        skuCount = 0;
    }

    function addItem(string memory _name, uint256 _price)
        public
        returns (bool)
    {
        items[skuCount] = Item({
         name: _name,
         sku: skuCount,
         price: _price,
         state: State.ForSale,
         seller: payable(msg.sender),
         buyer: payable(address(0))
        });
        
        emit LogForSale(skuCount);
        skuCount = skuCount + 1;

        return true;
    }

    
    function buyItem(uint256 sku) payable public 
            forSale(sku)
            paidEnough( msg.value)  
            checkValue(sku) 
    {

      items[sku].seller.transfer(items[sku].price);
      items[sku].buyer = payable(msg.sender);
      items[sku].state = State.Sold;

      emit LogSold(sku);
    }

    
    function shipItem(uint256 sku) public 
              sold(sku)
              verifyCaller(items[sku].seller)
    {
      items[sku].state = State.Shipped;
      emit LogShipped(sku);
    }

    function receiveItem(uint256 sku) public 
              shipped(sku)
              verifyCaller(items[sku].buyer)
    {
      items[sku].state = State.Received;
      emit LogReceived(sku);(sku);
    }

     function fetchItem(uint _sku) public view 
       returns (string memory name, uint sku, uint price, uint state, address seller, address buyer)
    {
      name = items[_sku].name; 
      sku = items[_sku].sku; 
      price = items[_sku].price; 
      state = uint(items[_sku].state); 
      seller = items[_sku].seller; 
      buyer = items[_sku].buyer; 
      return (name, sku, price, state, seller, buyer); 
    } 
}
