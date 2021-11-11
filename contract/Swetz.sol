// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import './Ownable.sol';
import './IBEP20.sol';

contract Swetz is Ownable, IBEP20 {
    uint256 private constant TOTAL_SUPPLY = 100000000000 * 10**7;
    
    event MintFinished();
    
    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;
    bool private _mintingFinished = false;
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    
    constructor () {
         _totalSupply = TOTAL_SUPPLY;
        _name = "Swetz";
        _symbol = "SWETZ";
        _decimals = 9;
        
        _setupDecimals(9);
        _mint(_msgSender(), _totalSupply);
    }

    function _mint(address account, uint256 amount) internal onlyOwner {
        require(_mintingFinished != true, "minting already finished");
        require(account != address(0), "minting to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
        
        finishMinting();
    }
    
    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function getOwner() public view returns (address) {
        return owner();
    }

    function transfer(address recipient, uint256 amount) public virtual returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "BEP20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);

        return true;
    }

    function approve(address spender, uint256 amount) public virtual returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual returns (uint256) {
        return _allowances[owner][spender];
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "BEP20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "BEP20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "BEP20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "BEP20: burn amount exceeds balance");
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal {
        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }


    modifier canMint() {
        require(!_mintingFinished, "BEP20Mintable: minting is finished");
        _;
    }

    function mintingFinished() public view returns (bool) {
        return _mintingFinished;
    }

    function mint(address account, uint256 amount) public canMint {
        _mint(account, amount);
    }

    function finishMinting() public onlyOwner {
        _mintingFinished = true;

        emit MintFinished();
    }

    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public virtual {
      uint256 currentAllowance = allowance(account, _msgSender());
      require(currentAllowance >= amount, "BEP20: burn amount exceeds allowance");
      _approve(account, _msgSender(), currentAllowance - amount);
      _burn(account, amount);
    }
}

