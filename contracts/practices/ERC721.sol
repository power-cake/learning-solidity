// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title erc721合约
 * @dev   test
 */
interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

interface IERC721 is IERC165{
    function balanceOf(address owner) external view returns (uint balance);

    function ownerOf(uint tokenId) external view returns (address owner) ;

    function safeTransferFrom(address from, address to, uint tokenId) external;

    function safeTransferFrom(address from, address to, uint tokenId, bytes calldata data) external;

    function transferFrom(address from, address to, uint tokenId) external;

    function approve(address to, uint tokenId) external;

    function getApproved(uint tokenId) external view returns (address operator);

    function setApprovalForAll(address operator, bool _approved) external;

    function isApprovedForAll(address owner, address operator) external view returns (bool);
    
}  

interface IERC721Receiver {
    
    function onERC721Received(
        address operator,
        address from,
        uint tokenId,
        bytes calldata data
    ) external returns (bytes4) ;
}

library Address {
    function isContract(address account) internal view returns (bool) {
        uint size;
        assembly {
            size := extcodesize(account)
        }

        return size > 0;
    }
}

contract ERC721 is IERC721 {
    using Address for address;

    event Transfer(address indexed from, address indexed to, uint indexed tokenId);
    event Approval(
        address indexed owner,
        address indexed operator,
        uint indexed tokenId
    );
    
    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved);

//    Mapping tokenId  to owner address
    mapping(uint => address) private _owners;

//    Mapping owner address to token count
    mapping(address => uint) private _balances;

//   Mapping from token id to approved address
    mapping(uint => address) private _tokenApprovals;

    mapping(address => mapping(address => bool)) private _operatorApprovals;

    function supportsInterface(bytes4 _interfaceId)
        external
        pure
        override
        returns (bool)
    {
        return _interfaceId == type(IERC721).interfaceId || _interfaceId == type(IERC165).interfaceId;
    }

    function balanceOf(address _owner) external view override returns (uint) {
        require(_owner != address(0), "owner = zero address");
        return _balances[_owner];
    }

    function ownerOf(uint _tokenId) public override view returns (address owner) {
        owner =  _owners[_tokenId];
        require(owner != address(0), "owner = zero address");
    }

    function isApprovedForAll(address _owner, address _operator) external view override returns (bool) {
        return _operatorApprovals[_owner][_operator];
    }

    function setApprovalForAll(address _operator, bool _approved) external override {
        _operatorApprovals[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    function getApproved(uint _tokenId) external view override returns (address) {
        require(_owners[_tokenId] != address(0), "token not exist");
        return _tokenApprovals[_tokenId];
    }



    function approve(address _to, uint _tokenId) external override {
        address owner = _owners[_tokenId];
        require(msg.sender == owner || _operatorApprovals[owner][msg.sender], "Not owner or approved for all");
        _approve(owner, _to, _tokenId);
    }

    function _isApprovedOrOwner(address _owner, address _spender, uint _tokenId) private view returns (bool) {
        return (_spender == _owner || _tokenApprovals[_tokenId] == _spender || _operatorApprovals[_owner][_spender]);
    }

    function _approve(address _owner, address _to, uint _tokenId) private {
        _tokenApprovals[_tokenId] = _to;
        emit Approval(_owner, _to, _tokenId);
    }

    function _transfer(address _owner, address _from, address _to, uint _tokenId) private {
        require(_from == _owner, "not owner");
        require(_to != address(0), "transfer to zero address");

        _approve(_owner, address(0), _tokenId);

        _balances[_from] -= 1;
        _balances[_to] += 1;
        _owners[_tokenId] = _to;

        emit Transfer(_from, _to, _tokenId);
    }

    function transferFrom(address _from, address _to, uint _tokenId) external override {
        address owner = ownerOf(_tokenId);
        require(_isApprovedOrOwner(owner, msg.sender, _tokenId), "not owner nor approved");

        _transfer(owner, _from, _to, _tokenId);
    }

    function _checkOnERC721Received(address _from, address _to, uint tokenId, bytes memory _data) private returns (bool) {
        if (_to.isContract()) {
            return IERC721Receiver(_to).onERC721Received(
                _from,
                _to,
                tokenId,
                _data
            ) == IERC721Receiver.onERC721Received.selector;
        }
        return false;
    }

    function _safeTransferFrom(address _owner, address _from, address _to, uint _tokenId, bytes memory _data) private  {
        _transfer(_owner, _from, _to, _tokenId);
        require(_checkOnERC721Received(_from, _to, _tokenId, _data ), "not ERC721Receiver");
    }
    
    
    function safeTransferFrom(
        address _from,
        address _to,
        uint _tokenId,
        bytes memory _data
    )
    public
    override
    {
        address owner = ownerOf(_tokenId);
        require(
            _isApprovedOrOwner(owner, msg.sender, _tokenId),
            "not owner nor appzroved"
        );

        _safeTransferFrom(owner, _from, _to, _tokenId, _data);
    }

    function safeTransferFrom(address _from, address _to, uint _tokenId) external override {
        safeTransferFrom(_from, _to, _tokenId, "");
    }

    function mint(address _to, uint _tokenId) external {
        require(_to != address(0), "mint to zero address");
        require(_owners[_tokenId] == address(0), "token alread minted");

        _balances[_to] += 1;
        _owners[_tokenId] = _to;

        emit Transfer(address(0), _to, _tokenId);
    }

    function burn(uint _tokenId) external {
        address owner = _owners[_tokenId];
        _approve(owner, address(0), _tokenId);

        _balances[owner] -= 1;

        delete _owners[_tokenId];
        emit Transfer(owner, address(0), _tokenId);
    }
    
}