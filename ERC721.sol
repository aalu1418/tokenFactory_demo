pragma solidity 0.5.16;

/// @title ERC-721 Non-Fungible Token Standard
/// @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
///  Note: the ERC-165 identifier for this interface is 0x80ac58cd
interface ERC721 /* is ERC165 */ {
  /// @dev This emits when ownership of any NFT changes by any mechanism.
  ///  This event emits when NFTs are created (`from` == 0) and destroyed
  ///  (`to` == 0). Exception: during contract creation, any number of NFTs
  ///  may be created and assigned without emitting Transfer. At the time of
  ///  any transfer, the approved address for that NFT (if any) is reset to none.
  event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);

  /// @dev This emits when the approved address for an NFT is changed or
  ///  reaffirmed. The zero address indicates there is no approved address.
  ///  When a Transfer event emits, this also indicates that the approved
  ///  address for that NFT (if any) is reset to none.
  event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);

  /// @dev This emits when an operator is enabled or disabled for an owner.
  ///  The operator can manage all NFTs of the owner.
  event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

  /// @notice Count all NFTs assigned to an owner
  /// @dev NFTs assigned to the zero address are considered invalid, and this
  ///  function throws for queries about the zero address.
  /// @param _owner An address for whom to query the balance
  /// @return The number of NFTs owned by `_owner`, possibly zero
  function balanceOf(address _owner) external view returns (uint256);

  /// @notice Find the owner of an NFT
  /// @dev NFTs assigned to zero address are considered invalid, and queries
  ///  about them do throw.
  /// @param _tokenId The identifier for an NFT
  /// @return The address of the owner of the NFT
  function ownerOf(uint256 _tokenId) external view returns (address);

  /// @notice Transfers the ownership of an NFT from one address to another address
  /// @dev Throws unless `msg.sender` is the current owner, an authorized
  ///  operator, or the approved address for this NFT. Throws if `_from` is
  ///  not the current owner. Throws if `_to` is the zero address. Throws if
  ///  `_tokenId` is not a valid NFT. When transfer is complete, this function
  ///  checks if `_to` is a smart contract (code size > 0). If so, it calls
  ///  `onERC721Received` on `_to` and throws if the return value is not
  ///  `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`.
  /// @param _from The current owner of the NFT
  /// @param _to The new owner
  /// @param _tokenId The NFT to transfer
  /// @param data Additional data with no specified format, sent in call to `_to`
  function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes calldata data) external payable;

  /// @notice Transfers the ownership of an NFT from one address to another address
  /// @dev This works identically to the other function with an extra data parameter,
  ///  except this function just sets data to ""
  /// @param _from The current owner of the NFT
  /// @param _to The new owner
  /// @param _tokenId The NFT to transfer
  function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable;

  /// @notice Transfer ownership of an NFT -- THE CALLER IS RESPONSIBLE
  ///  TO CONFIRM THAT `_to` IS CAPABLE OF RECEIVING NFTS OR ELSE
  ///  THEY MAY BE PERMANENTLY LOST
  /// @dev Throws unless `msg.sender` is the current owner, an authorized
  ///  operator, or the approved address for this NFT. Throws if `_from` is
  ///  not the current owner. Throws if `_to` is the zero address. Throws if
  ///  `_tokenId` is not a valid NFT.
  /// @param _from The current owner of the NFT
  /// @param _to The new owner
  /// @param _tokenId The NFT to transfer
  function transferFrom(address _from, address _to, uint256 _tokenId) external payable;

  /// @notice Set or reaffirm the approved address for an NFT
  /// @dev The zero address indicates there is no approved address.
  /// @dev Throws unless `msg.sender` is the current NFT owner, or an authorized
  ///  operator of the current owner.
  /// @param _approved The new approved NFT controller
  /// @param _tokenId The NFT to approve
  function approve(address _approved, uint256 _tokenId) external payable;

  /// @notice Enable or disable approval for a third party ("operator") to manage
  ///  all of `msg.sender`'s assets.
  /// @dev Emits the ApprovalForAll event. The contract MUST allow
  ///  multiple operators per owner.
  /// @param _operator Address to add to the set of authorized operators.
  /// @param _approved True if the operator is approved, false to revoke approval
  function setApprovalForAll(address _operator, bool _approved) external;

  /// @notice Get the approved address for a single NFT
  /// @dev Throws if `_tokenId` is not a valid NFT
  /// @param _tokenId The NFT to find the approved address for
  /// @return The approved address for this NFT, or the zero address if there is none
  function getApproved(uint256 _tokenId) external view returns (address);

  /// @notice Query if an address is an authorized operator for another address
  /// @param _owner The address that owns the NFTs
  /// @param _operator The address that acts on behalf of the owner
  /// @return True if `_operator` is an approved operator for `_owner`, false otherwise
  function isApprovedForAll(address _owner, address _operator) external view returns (bool);
}

interface ERC165 {
  /// @notice Query if a contract implements an interface
  /// @param interfaceID The interface identifier, as specified in ERC-165
  /// @dev Interface identification is specified in ERC-165. This function
  ///  uses less than 30,000 gas.
  /// @return `true` if the contract implements `interfaceID` and
  ///  `interfaceID` is not 0xffffffff, `false` otherwise
  function supportsInterface(bytes4 interfaceID) external view returns (bool);
}

interface ERC721TokenReceiver {
  /// @notice Handle the receipt of an NFT
  /// @dev The ERC721 smart contract calls this function on the
  /// recipient after a `transfer`. This function MAY throw to revert and reject the transfer. Return
  /// of other than the magic value MUST result in the transaction being reverted.
  /// @notice The contract address is always the message sender.
  /// @param _operator The address which called `safeTransferFrom` function
  /// @param _from The address which previously owned the token
  /// @param _tokenId The NFT identifier which is being transferred
  /// @param _data Additional data with no specified format
  /// @return `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
  /// unless throwing
  function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes calldata _data) external returns(bytes4);
}

contract ERC721Token is ERC721, ERC165 {

  //token related information storage
  uint256 public totalTokens;
  mapping (address => uint256) internal _tokenCount;
  mapping (uint256 => address) internal _tokenOwner;
  mapping (uint256 => address) internal _tokenApproved;
  mapping (address => mapping (address => bool)) internal _operatorApproved;

  //https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol
  /*
   *     bytes4(keccak256('balanceOf(address)')) == 0x70a08231
   *     bytes4(keccak256('ownerOf(uint256)')) == 0x6352211e
   *     bytes4(keccak256('approve(address,uint256)')) == 0x095ea7b3
   *     bytes4(keccak256('getApproved(uint256)')) == 0x081812fc
   *     bytes4(keccak256('setApprovalForAll(address,bool)')) == 0xa22cb465
   *     bytes4(keccak256('isApprovedForAll(address,address)')) == 0xe985e9c5
   *     bytes4(keccak256('transferFrom(address,address,uint256)')) == 0x23b872dd
   *     bytes4(keccak256('safeTransferFrom(address,address,uint256)')) == 0x42842e0e
   *     bytes4(keccak256('safeTransferFrom(address,address,uint256,bytes)')) == 0xb88d4fde
   *
   *     => 0x70a08231 ^ 0x6352211e ^ 0x095ea7b3 ^ 0x081812fc ^
   *        0xa22cb465 ^ 0xe985e9c ^ 0x23b872dd ^ 0x42842e0e ^ 0xb88d4fde == 0x80ac58cd
   */
  bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;


  function balanceOf(address _owner) external view returns (uint256) {
      require(_owner != address(0), "invalid address");
      return _tokenCount[_owner];
  }

  function ownerOf(uint256 _tokenId) external view returns (address) {
      require(_tokenOwner[_tokenId] != address(0), "non-existent Token");
      return _tokenOwner[_tokenId];
  }

  function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes calldata data) external payable {
      _safeTransfer(_from, _to, _tokenId, data);
  }

  function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable {
      _safeTransfer(_from, _to, _tokenId, "");
  }

  function transferFrom(address _from, address _to, uint256 _tokenId) external payable {
      _transfer(_from, _to, _tokenId);
  }

  function approve(address _approved, uint256 _tokenId) external payable {
      require(msg.sender == _tokenOwner[_tokenId] || _operatorApproved[_tokenOwner[_tokenId]][msg.sender], "unauthorized to approve token");
      require(_approved != _tokenOwner[_tokenId], "cannot approve current owner");

      _tokenApproved[_tokenId] = _approved;

      emit Approval(_tokenOwner[_tokenId], _approved, _tokenId);
  }

  function setApprovalForAll(address _operator, bool _approved) external {
      require(msg.sender != _operator, "owner cannot be set as operator");

      _operatorApproved[msg.sender][_operator] = _approved;

      emit ApprovalForAll(msg.sender, _operator, _approved);
  }

  function getApproved(uint256 _tokenId) external view returns (address) {
      require(_tokenOwner[_tokenId] != address(0), "non-existent token");
      return _tokenApproved[_tokenId];
  }

  function isApprovedForAll(address _owner, address _operator) external view returns (bool) {
      require(_owner != _operator, "operator cannot be the same as owner");
      return _operatorApproved[_owner][_operator];
  }

  function supportsInterface(bytes4 interfaceID) external view returns (bool) {
      //allows the ERC721 interface
      return interfaceID == _INTERFACE_ID_ERC721;
  }


  //Solidity Static Analysis: Potential Violation of Checks-Effects-Interaction pattern
  // - warning ignored because this is the method requested by the ERC721 standard
  function _safeTransfer(address _from, address _to, uint256 _tokenId, bytes memory data) internal {
      _transfer(_from, _to, _tokenId); //complete transfer

      //and then call ERC721Received on _to account
      bool check;

      if (_isContract(_to)) {
          ERC721TokenReceiver tokenReceiver = ERC721TokenReceiver(_to);
          bytes4 returned = tokenReceiver.onERC721Received(msg.sender, _from, _tokenId, data);
          check = returned == bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));
      } else {
          check = true;
      }
      require(check, "onERC721Received failure");
  }

  function _transfer(address _from, address _to, uint256 _tokenId) internal {
      //passing conditions:
      // msg.sender is the token owner
      // msg.sender is an operator for the token owner
      // msg.sender is approved to control the token
      // purchase state is true & token is owned by the contract (occurs when a purchase is happening)
      require(msg.sender == _tokenOwner[_tokenId] || _operatorApproved[_from][msg.sender] || _tokenApproved[_tokenId] == msg.sender, "not authorized to transfer");
      require(_from == _tokenOwner[_tokenId], "token not owned by from account");
      require(_to != address(0), "0 address not allowed");
      require(_tokenOwner[_tokenId] != address(0), "non-existent token");
      require(_from != _to, "cannot send to same account");

      //safe math checks
      require(_tokenCount[_from] - 1 < _tokenCount[_from], "decrement overflow");
      require(_tokenCount[_to] + 1 > _tokenCount[_to], "increment overflow");

      _tokenOwner[_tokenId] = _to; //assign owner to token
      _tokenCount[_from] -= 1; //decrease from count
      _tokenCount[_to] += 1; //increase to count
      _tokenApproved[_tokenId] = address(0); //once token is transferred clear the approval


      emit Transfer(_from, _to, _tokenId);
  }

  //Solidity Static Analysis: warning about using inline assembly
  // - warning ignored because it's the only way that I could find to check if an address is a contract
  //https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Address.sol
  function _isContract(address account) internal view returns (bool) {
      // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
      // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
      // for accounts without code, i.e. `keccak256('')`
      bytes32 codehash;
      bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
      // solhint-disable-next-line no-inline-assembly
      assembly { codehash := extcodehash(account) }
      return (codehash != accountHash && codehash != 0x0);
  }



}

contract externalContract is ERC721TokenReceiver {
    function onERC721Received(address , address , uint256 , bytes calldata) external returns(bytes4) {
        return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));
    }
}
