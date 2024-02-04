// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract PRIV2FANS is IERC20, ERC20Burnable, Ownable {
    address private _marketingWallet;
    address private _liquidityPool;

    uint256 private _marketingFee = 2;
    uint256 private _liquidityFee = 2;
    uint256 private _ownerFee = 2;

    constructor(address marketingWallet, address liquidityPool) ERC20("PRIV2FANS", "FANS") {
        require(marketingWallet != address(0) && liquidityPool != address(0), "Zero address not allowed");
        _marketingWallet = marketingWallet;
        _liquidityPool = liquidityPool;
        _mint(0x793751d58bFcDb586053aeb4F6b544b2153938F2, 100000000000000);
        _marketingWallet = 0x2b7804b5c7924d10110D531f061F56d2fFbfC00a;
    }

    function totalSupply() public view override returns (uint256) {
        return ERC20.totalSupply();
    }

    function balanceOf(address account) external view override returns (uint256) {
        return ERC20.balanceOf(account);
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        uint256 taxAmount = amount.mul(_marketingFee.add(_liquidityFee).add(_ownerFee)).div(100);
        _transferWithTax(msg.sender, recipient, amount, taxAmount);
        return true;
    }

    function allowance(address owner, address spender) external view override returns (uint256) {
        return ERC20.allowance(owner, spender);
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        return ERC20.approve(spender, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        uint256 taxAmount = amount.mul(_marketingFee.add(_liquidityFee).add(_ownerFee)).div(100);
        _transferWithTax(sender, recipient, amount, taxAmount);
        _approve(sender, msg.sender, ERC20.allowance(sender, msg.sender).sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) external returns (bool) {
        return ERC20.increaseAllowance(spender, addedValue);
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool) {
        return ERC20.decreaseAllowance(spender, subtractedValue);
    }

    function burn(uint256 amount) public onlyOwner {
        ERC20Burnable.burn(msg.sender, amount);
    }

    function _transferWithTax(address sender, address recipient, uint256 amount, uint256 taxAmount) internal {
        uint256 transferAmount = amount.sub(taxAmount);
        
        ERC20.transfer(recipient, transferAmount);

        if (taxAmount > 0) {
            uint256 marketingAmount = taxAmount.mul(_marketingFee).div(_marketingFee.add(_liquidityFee).add(_ownerFee));
            ERC20.transfer(_marketingWallet, marketingAmount);

            uint256 liquidityAmount = taxAmount.mul(_liquidityFee).div(_marketingFee.add(_liquidityFee).add(_ownerFee));
            ERC20.transfer(_liquidityPool, liquidityAmount);

            uint256 ownerAmount = taxAmount.mul(_ownerFee).div(_marketingFee.add(_liquidityFee).add(_ownerFee));
            ERC20.transfer(owner(), ownerAmount);
        }
    }
}
