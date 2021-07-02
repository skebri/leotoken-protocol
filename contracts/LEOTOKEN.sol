/**
 *Submitted for verification at BscScan.com on
*/

//SPDX-License-Identifier: Unlicensed

import "../libraries/SafeMath.sol";
import "../libraries/Address.sol";
import "../libraries/Utils.sol";

pragma solidity ^0.8.1;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

pragma solidity ^0.8.1;
/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
    * @dev Leaves the contract without owner. It will not be possible to call
    * `onlyOwner` functions anymore. Can only be called by the current owner.
    *
    * NOTE: Renouncing ownership will leave the contract without an owner,
    * thereby removing any functionality that is only available to the owner.
    */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function geUnlockTime() public view returns (uint256) {
        return _lockTime;
    }

    //Locks the contract for owner for the amount of time provided
    function lock(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = block.timestamp + time;
        emit OwnershipTransferred(_owner, address(0));
    }

    //Unlocks the contract for owner when _lockTime is exceeds
    function unlock() public virtual {
        require(_previousOwner == msg.sender, "You don't have permission to unlock");
        require(block.timestamp > _lockTime , "Contract is locked until 7 days");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }
}

interface IPancakePair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

interface IPancakeFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    modifier isHuman() {
        require(tx.origin == msg.sender, "sorry humans only");
        _;
    }
}

interface IBEP20 {

    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

pragma solidity ^0.8.1;
pragma experimental ABIEncoderV2;

contract LEO is Context, IBEP20, Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using Address for address;

    address public charityAddress = address(0x362dEB41A49Ac0aEC0Ff6739E9233d4887a0b39C);
    address public payableCharityAddress = payable(charityAddress);
    address public rewardAddress = address(0x017B826C129F79fB04A43BfF379c585a7648a119);
    address public whaleFeeAddress = address(0x3F1C98d3FCB837A8BBb7423a5833A75757a2D041);
    address public pancakeRouterAddress = payable(address(0x10ed43c718714eb63d5aa57b78b54704e256024e));

    address public distributeBNBAddress = address (0x06b5f7C5A6b709BAe1A4bc501ABb9EB2E8C985Aa);
    address public liquidityFeeAddress = address (0x852a3AD7d123D2f18F32b2Aca3774394324BDe1e);
    address public teamFoundAddress = address(0xe6c31aEB215d9aD4a2823dd7A707b069C15a035c);

    struct Liquidity {
        uint256 total;
    }

    struct LiquidityAddress {
        address liqAddress;
        uint256 fee;
    }

    LiquidityAddress[] private _liquidityAddress;
    mapping(address => Liquidity) private _liquidityMap;
    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private _isExcluded;
    mapping(address => bool) private _isExcludedFromMaxTx;

    address[] private _excluded;

    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal = 1000000000000000 * 10 ** 6 * 10 ** 9;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;

    string private _name = "LEOTOKEN";
    string private _symbol = "LEOTOKEN";
    uint8 private _decimals = 15;

    IPancakeRouter02 public immutable pancakeRouter;
    address public immutable pancakePair;

    bool inSwapAndLiquify = false;

    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    event ClaimBNBSuccessfully(
        address recipient,
        uint256 ethReceived,
        uint256 nextAvailableClaimDate
    );

    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    constructor () {
        _rOwned[_msgSender()] = _rTotal;

        IPancakeRouter02 _pancakeRouter = IPancakeRouter02(pancakeRouterAddress);
        // Create a pancake pair for this new token
        pancakePair = IPancakeFactory(_pancakeRouter.factory())
        .createPair(address(this), _pancakeRouter.WETH());

        // set the rest of the contract variables
        pancakeRouter = _pancakeRouter;

        //exclude owner and this contract from fee
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[charityAddress] = true;

        // exclude from max tx
        _isExcludedFromMaxTx[owner()] = true;
        _isExcludedFromMaxTx[address(this)] = true;
        _isExcludedFromMaxTx[address(0x000000000000000000000000000000000000dEaD)] = true;
        _isExcludedFromMaxTx[address(0)] = true;
        _isExcludedFromMaxTx[charityAddress] = true;

        emit Transfer(address(0), _msgSender(), _tTotal);
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

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
        return true;
    }

    function isExcludedFromReward(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }

    function deliver(uint256 tAmount) public {
        address sender = _msgSender();
        require(!_isExcluded[sender], "Excluded addresses cannot call this function");
        TransactionValues memory transactionValues = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(transactionValues.rAmount);
        _rTotal = _rTotal.sub(transactionValues.rAmount);
        _tFeeTotal = _tFeeTotal.add(transactionValues.tAmount);
    }

    function reflectionFromToken(uint256 tAmount, bool deductTransferFee) public view returns (uint256) {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        TransactionValues memory transactionValues = _getValues(tAmount);
        if (!deductTransferFee) {
            return transactionValues.rAmount;
        } else {
            return transactionValues.rTransferAmount;
        }
    }

    function tokenFromReflection(uint256 rAmount) public view returns (uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate = _getRate();
        return rAmount.div(currentRate);
    }

    function excludeFromReward(address account) public onlyOwner() {
        // require(account != 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D, 'We can not exclude Pancake router.');
        require(!_isExcluded[account], "Account is already excluded");
        if (_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeInReward(address account) external onlyOwner() {
        require(_isExcluded[account], "Account is already excluded");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tOwned[account] = 0;
                _isExcluded[account] = false;
                _excluded.pop();
                break;
            }
        }
    }

    function _transferBothExcluded(address sender, address recipient, uint256 tAmount, bool takeFee, bool takeWhaleFee) private {
        TransactionValues memory transactionValues = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(transactionValues.tAmount);
        _rOwned[sender] = _rOwned[sender].sub(transactionValues.rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(transactionValues.tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(transactionValues.rTransferAmount);
        _takeLiquidity(sender, transactionValues.tLiquidity);
        if (takeFee)
            _reflectFee(transactionValues.rFee);
        emit Transfer(sender, recipient, transactionValues.tTransferAmount);
        if (takeWhaleFee)
            _reflectWhaleFee(transactionValues.rWhaleFee);
    }

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function setTaxFeePercent(uint256 taxFee) external onlyOwner() {
        _taxFee = taxFee;
    }

    function setLiquidityFeePercent(uint256 liquidityFee) external onlyOwner() {
        _liquidityFee = liquidityFee;
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

    //to receive BNB from pancakeRouter when swapping
    receive() external payable {}

    function _reflectFee(uint256 rFee) private {
        _rTotal = _rTotal.sub(rFee);
    }

    function _reflectWhaleFee(uint256 rWhaleFee) private {
        _rTotal = _rTotal.sub(rWhaleFee);
        _whaleFeeTotal += rWhaleFee;
    }

    function getLiquidityMap() public view returns (Liquidity memory, Liquidity memory, Liquidity memory) {
        Liquidity memory liquidity1  = _liquidityMap[_liquidityAddress[0].liqAddress];
        liquidity1.total = tokenFromReflection(liquidity1.total);

        Liquidity memory liquidity2  = _liquidityMap[_liquidityAddress[1].liqAddress];
        liquidity2.total = tokenFromReflection(liquidity2.total);

        Liquidity memory liquidity3  = _liquidityMap[_liquidityAddress[2].liqAddress];
        liquidity3.total = tokenFromReflection(liquidity3.total);

        return (liquidity1, liquidity2, liquidity3);
    }

    struct TransactionValues{
        uint256 rAmount;
        uint256 tAmount;
        uint256 rTransferAmount;
        uint256 rFee;
        uint256 tTransferAmount;
        uint256 tFee;
        uint256 tLiquidity;
        uint256 tWhaleFee;
        uint256 rWhaleFee;
    }

    function _getValues(uint256 tAmount) private view returns (TransactionValues memory) {
        (uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity, uint256 tWhaleFee) = _getTValues(tAmount);

        uint256 currentRate = _getRate();
        (uint256 rFee, uint256 rWhaleFee) = _getFeeRValues(currentRate, tFee, tWhaleFee);
        return _getFeeRValues(tAmount, tTransferAmount, currentRate, tLiquidity, rFee, tFee, rWhaleFee, tWhaleFee);
    }

    function _getFeeRValues(uint256 tAmount, uint256 tTransferAmount, uint256 currentRate, uint256 tLiquidity, uint256 rFee, uint256 tFee, uint256 rWhaleFee, uint256 tWhaleFee) private pure returns (TransactionValues memory) {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        uint256 rlTAmount = tAmount.mul(currentRate).sub(rLiquidity);
        uint256 rTransferAmount = rlTAmount.sub(rFee).sub(rWhaleFee);

        return TransactionValues({
            rAmount: rAmount,
            tAmount: tAmount,
            rTransferAmount: rTransferAmount,
            rFee: rFee,
            tTransferAmount: tTransferAmount,
            tFee: tFee,
            tLiquidity: tLiquidity,
            tWhaleFee: tWhaleFee,
            rWhaleFee: rWhaleFee
        });
    }

    function _getTValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256) {
        uint256 tFee = calculateTaxFee(tAmount);
        uint256 tLiquidity = calculateLiquidityFee(tAmount);
        uint256 tWhaleFee = calculateWhaleFee(tAmount);
        uint256 tTransferAmount = tAmount.sub(tFee).sub(tLiquidity).sub(tWhaleFee);
        return (tTransferAmount, tFee, tLiquidity, tWhaleFee);
    }

    function _getFeeRValues(uint256 currentRate, uint256 tFee, uint256 tWhaleFee) private pure returns (uint256, uint256) {
        uint256 rFee = tFee.mul(currentRate);
        uint256 rWhaleFee = tWhaleFee.mul(currentRate);
        return (rFee, rWhaleFee);
    }

    function _getRate() private view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns (uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_rOwned[_excluded[i]] > rSupply || _tOwned[_excluded[i]] > tSupply) return (_rTotal, _tTotal);
            rSupply = rSupply.sub(_rOwned[_excluded[i]]);
            tSupply = tSupply.sub(_tOwned[_excluded[i]]);
        }
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function _takeLiquidity(address sender, uint256 tLiquidity) private {
        if (_liquidityFee < 1) {
            return;
        }
        uint256 currentRate = _getRate();
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        uint256 liquidityPart = rLiquidity.div(_liquidityFee);

        for (uint256 i = 0; i < _liquidityAddress.length; i++) {
            LiquidityAddress memory liqAddress = _liquidityAddress[i];
            uint256 amount = liquidityPart.mul(liqAddress.fee);

            _liquidityMap[liqAddress.liqAddress] = Liquidity({
                total: _liquidityMap[liqAddress.liqAddress].total + amount
            });

            if (liqAddress.liqAddress != teamFoundAddress) {
                continue;
            }
            _rOwned[teamFoundAddress] = _rOwned[teamFoundAddress].add(amount);
            emit Transfer(sender, teamFoundAddress, tokenFromReflection(amount));
            if (_isExcluded[teamFoundAddress])
                _tOwned[teamFoundAddress] = _tOwned[teamFoundAddress].add(amount);
        }
    }

    function calculateTaxFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_taxFee).div(
            10 ** 2
        );
    }

    function calculateWhaleFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_whaleFee).div(
            10 ** 2
        );
    }

    function calculateLiquidityFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_liquidityFee).div(
            10 ** 2
        );
    }

    function removeAllFee() private {
        if (_taxFee == 0 && _liquidityFee == 0 && _whaleFee == 0) return;

        _previousTaxFee = _taxFee;
        _previousLiquidityFee = _liquidityFee;
        _previousWhaleFee = _whaleFee;

        _taxFee = 0;
        _liquidityFee = 0;
        _whaleFee = 0;
    }

    function restoreAllFee() private {
        if (_taxFee != _previousTaxFee) {
            _taxFee = _previousTaxFee;
        }
        if (_liquidityFee != _previousLiquidityFee) {
            _liquidityFee = _previousLiquidityFee;
        }
        if (_whaleFee != _previousWhaleFee) {
            _whaleFee = _previousWhaleFee;
        }
    }

    function removeWhaleFee() private {
        if (_whaleFee == 0) return;

        _previousWhaleFee = _whaleFee;
        _whaleFee = 0;
    }

    function restoreWhaleFee() private {
        if (_whaleFee != _previousWhaleFee) {
            _whaleFee = _previousWhaleFee;
        }
    }

    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "BEP20: transfer from the zero address");
        require(to != address(0), "BEP20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        // swap and liquify
        swapAndLiquify(from, to);

        //indicates if fee should be deducted from transfer
        bool takeFee = true;

        //if any account belongs to _isExcludedFromFee account then remove the fee
        if (_isExcludedFromFee[from] || _isExcludedFromFee[to] || reflectionFeesdiabled) {
            takeFee = false;
        }

        //indicates if whale fee should be deducted from transfer because of high amount
        bool takeWhaleFee = false;
        if (takeFee && shouldTakeWhaleFee(amount)) {
            takeWhaleFee = true;
        }

        //transfer amount, it will take tax, whale, burn, liquidity fee
        _tokenTransfer(from, to, amount, takeFee, takeWhaleFee);
    }

    //this method is responsible for taking all fee, if takeFee is true and whale fee for high transactions
    function _tokenTransfer(address sender, address recipient, uint256 amount, bool takeFee, bool takeWhaleFee) private {
        if (!takeFee)
            removeAllFee();

        if (!takeWhaleFee) {
            removeWhaleFee();
        }

        // top up claim cycle
        topUpClaimCycleAfterTransfer(recipient, amount);

        if (_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferFromExcluded(sender, recipient, amount, takeFee, takeWhaleFee);
        } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
            _transferToExcluded(sender, recipient, amount, takeFee, takeWhaleFee);
        } else if (!_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferStandard(sender, recipient, amount, takeFee, takeWhaleFee);
        } else if (_isExcluded[sender] && _isExcluded[recipient]) {
            _transferBothExcluded(sender, recipient, amount, takeFee, takeWhaleFee);
        } else {
            _transferStandard(sender, recipient, amount, takeFee, takeWhaleFee);
        }

        restoreAllFee();
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount, bool takeFee, bool takeWhaleFee) private {
        TransactionValues memory transactionValues = _getValues(tAmount);

        _rOwned[sender] = _rOwned[sender].sub(transactionValues.rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(transactionValues.rTransferAmount);
        _takeLiquidity(sender, transactionValues.tLiquidity);
        if (takeFee)
            _reflectFee(transactionValues.rFee);
        emit Transfer(sender, recipient, transactionValues.tTransferAmount);
        if (takeWhaleFee)
            _reflectWhaleFee(transactionValues.rWhaleFee);
    }

    function _transferToExcluded(address sender, address recipient, uint256 tAmount, bool takeFee, bool takeWhaleFee) private {
        TransactionValues memory transactionValues = _getValues(tAmount);

        _rOwned[sender] = _rOwned[sender].sub(transactionValues.rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(transactionValues.tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(transactionValues.rTransferAmount);
        _takeLiquidity(sender, transactionValues.tLiquidity);
        if (takeFee)
            _reflectFee(transactionValues.rFee);
        emit Transfer(sender, recipient, transactionValues.tTransferAmount);
        if (takeWhaleFee)
            _reflectWhaleFee(transactionValues.rWhaleFee);
    }

    function _transferFromExcluded(address sender, address recipient, uint256 tAmount, bool takeFee, bool takeWhaleFee) private {
        TransactionValues memory transactionValues = _getValues(tAmount);

        _tOwned[sender] = _tOwned[sender].sub(transactionValues.tAmount);
        _rOwned[sender] = _rOwned[sender].sub(transactionValues.rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(transactionValues.rTransferAmount);
        _takeLiquidity(sender, transactionValues.tLiquidity);
        if (takeFee)
            _reflectFee(transactionValues.rFee);
        emit Transfer(sender, recipient, transactionValues.tTransferAmount);
        if (takeWhaleFee)
            _reflectWhaleFee(transactionValues.rWhaleFee);
    }

    // Innovation for protocol by LEO Team
    uint256 public rewardCycleBlock = 1 days;
    uint256 public easyRewardCycleBlock = 1 days;
    uint256 public threshHoldTopUpRate = 25; // 25 percent
    uint256 public _maxTxAmount = _tTotal; // should be 0.05% percent per transaction, will be set again at activateContract() function
    uint256 public disruptiveCoverageFee = 2 ether; // antiwhale
    mapping(address => uint256) public nextAvailableClaimDate;
    bool public swapAndLiquifyEnabled = false; // should be true
    uint256 public disruptiveTransferEnabledFrom = 0;
    uint256 public disableEasyRewardFrom = 0;

    bool public reflectionFeesdiabled = false;

    uint256 public _whaleFee = 5;
    uint256 private _previousWhaleFee = _whaleFee;

    uint256 private _whaleFeeTotal = 0;

    uint256 public _taxFee = 1;
    uint256 private _previousTaxFee = _taxFee;

    uint256 public _liquidityFee = 11; // 6% will be added pool, 4% will be converted to BNB, 1% will be converted to BNB
    uint256 private _previousLiquidityFee = _liquidityFee;
    uint256 public rewardThreshold = 2 ether;
    uint256 public charityPercentageFee = 25;

    uint256 minTokenNumberToSell = _tTotal.mul(1).div(10000).div(10); // 0.001% max tx amount will trigger swap and add liquidity

    function setMaxTxPercent(uint256 maxTxPercent) public onlyOwner() {
        _maxTxAmount = _tTotal.mul(maxTxPercent).div(10000);
    }

    function getMaxTxAmount() public view returns (uint256) {
        return _maxTxAmount;
    }

    function setExcludeFromMaxTx(address _address, bool value) public onlyOwner {
        _isExcludedFromMaxTx[_address] = value;
    }

    function getWhaleFeeTotal() public view returns (uint256) {
        return tokenFromReflection(_whaleFeeTotal);
    }

    function calculateBNBReward(address ofAddress) public view returns (uint256) {
        return Utils.calculateBNBReward(
            balanceOf(address(ofAddress)),
            address(this).balance,
            uint256(_tTotal)
            .sub(balanceOf(address(0)))
            .sub(balanceOf(0x000000000000000000000000000000000000dEaD)) // exclude burned wallet
            .sub(balanceOf(address(pancakePair)))
        );
    }

    function getRewardCycleBlock() public view returns (uint256) {
        if (block.timestamp >= disableEasyRewardFrom) return rewardCycleBlock;
        return easyRewardCycleBlock;
    }

    function claimBNBReward() isHuman nonReentrant public {
        require(nextAvailableClaimDate[msg.sender] <= block.timestamp, 'Error: next available not reached');
        require(balanceOf(msg.sender) >= 0, 'Error: must own LEO to claim reward');

        uint256 reward = calculateBNBReward(msg.sender);

        // reward threshold
        if (reward >= rewardThreshold) {

            uint256 charityamount = reward.mul(100).div(charityPercentageFee);
            (bool success, ) = address(payableCharityAddress).call{ value: charityamount }("");
            require(success, "Address: unable to send value, charity may have reverted");

            reward = reward.sub(reward.div(5));
        }

        // update rewardCycleBlock
        nextAvailableClaimDate[msg.sender] = block.timestamp + getRewardCycleBlock();
        emit ClaimBNBSuccessfully(msg.sender, reward, nextAvailableClaimDate[msg.sender]);

        (bool sent,) = address(msg.sender).call{value : reward}("");
        require(sent, 'Error: Cannot withdraw reward');
    }

    function topUpClaimCycleAfterTransfer(address recipient, uint256 amount) private {
        uint256 currentRecipientBalance = balanceOf(recipient);
        uint256 basedRewardCycleBlock = getRewardCycleBlock();

        nextAvailableClaimDate[recipient] = nextAvailableClaimDate[recipient] + Utils.calculateTopUpClaim(
            currentRecipientBalance,
            basedRewardCycleBlock,
            threshHoldTopUpRate,
            amount
        );
    }

    function shouldTakeWhaleFee(uint256 amount) private view returns(bool) {
        uint256 onePercent = uint256(_tTotal)
            .sub(balanceOf(address(0)))
            .sub(balanceOf(0x000000000000000000000000000000000000dEaD)) // exclude burned wallet
            .sub(balanceOf(address(pancakePair)))
            .div(100);
        return amount > onePercent && block.timestamp >= disruptiveTransferEnabledFrom;
    }

    function disruptiveTransfer(address recipient, uint256 amount) public payable returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function swapAndLiquify(address from, address to) private {
        // is the token balance of this contract address over the min number of
        // tokens that we need to initiate a swap + liquidity lock?
        // also, don't get caught in a circular liquidity event.
        // also, don't swap & liquify if sender is pancake pair.
        uint256 contractTokenBalance = balanceOf(address(this));

        if (contractTokenBalance >= _maxTxAmount) {
            contractTokenBalance = _maxTxAmount;
        }

        bool shouldSell = contractTokenBalance >= minTokenNumberToSell;

        if (
            !inSwapAndLiquify &&
        shouldSell &&
        from != pancakePair &&
        swapAndLiquifyEnabled &&
        !(from == address(this) && to == address(pancakePair)) // swap 1 time
        ) {
            // only sell for minTokenNumberToSell, decouple from _maxTxAmount
            contractTokenBalance = minTokenNumberToSell;

            // add liquidity
            // split the contract balance into 3 pieces
            uint256 pooledBNB = contractTokenBalance.div(2);
            uint256 piece = contractTokenBalance.sub(pooledBNB).div(2);
            uint256 otherPiece = contractTokenBalance.sub(piece);

            uint256 tokenAmountToBeSwapped = pooledBNB.add(piece);

            uint256 initialBalance = address(this).balance;

            // now is to lock into staking pool
            Utils.swapTokensForEth(address(pancakeRouter), tokenAmountToBeSwapped);

            // how much BNB did we just swap into?

            // capture the contract's current BNB balance.
            // this is so that we can capture exactly the amount of BNB that the
            // swap creates, and not make the liquidity event include any BNB that
            // has been manually sent to the contract
            uint256 deltaBalance = address(this).balance.sub(initialBalance);

            uint256 bnbToBeAddedToLiquidity = deltaBalance.div(3);

            // add liquidity to pancake
            Utils.addLiquidity(address(pancakeRouter), owner(), piece, bnbToBeAddedToLiquidity);

            emit SwapAndLiquify(piece, deltaBalance, otherPiece);
        }
    }

    function activateTestNet() public onlyOwner {
         // reward claim
         disableEasyRewardFrom = block.timestamp;
         rewardCycleBlock = 15 minutes;
         easyRewardCycleBlock = 15 minutes;

         // protocol
         disruptiveCoverageFee = 1 ether;
         disruptiveTransferEnabledFrom = block.timestamp;
         setMaxTxPercent(100);                   // 100 means 1%   and 1 means 0.01%
         setSwapAndLiquifyEnabled(true);
        _activateLiquidity();

         // approve contract
         _approve(address(this), address(pancakeRouter), 2 ** 256 - 1);
    }

    function activateContract() public onlyOwner {
        // reward claim
        disableEasyRewardFrom = block.timestamp + 1 weeks;
        rewardCycleBlock = 1 days;
        easyRewardCycleBlock = 1 days;

        // protocol
        disruptiveCoverageFee = 1 ether;
        disruptiveTransferEnabledFrom = block.timestamp;
        setMaxTxPercent(100);
        setSwapAndLiquifyEnabled(true);
        _activateLiquidity();

        // approve contract
        _approve(address(this), address(pancakeRouter), 2 ** 256 - 1);
    }

    function _activateLiquidity() private {
        // Distribute to BNB Address
        _liquidityAddress.push(LiquidityAddress({
            liqAddress: distributeBNBAddress,
            fee: 6
        }));
        _liquidityMap[distributeBNBAddress] = Liquidity({
            total: 0
        });

        // Liquidity Fee Address
        _liquidityAddress.push(LiquidityAddress({
            liqAddress: liquidityFeeAddress,
            fee: 4
        }));
        _liquidityMap[liquidityFeeAddress] = Liquidity({
            total: 0
        });

        // Team Fund Address
        _liquidityAddress.push(LiquidityAddress({
            liqAddress: teamFoundAddress,
            fee: 1
        }));
        _liquidityMap[teamFoundAddress] = Liquidity({
            total: 0
        });
    }

    function changerewardCycleBlock(uint256 newcycle) public onlyOwner {

        rewardCycleBlock = newcycle;
    }

    function changeCharityAddress(address payable _newaddress) public onlyOwner {

        payableCharityAddress = _newaddress;
    }

    // disable enable reflection fee ,  value == false (enable)
    function reflectionfeestartstop(bool _value) public onlyOwner {

        reflectionFeesdiabled = _value;
    }

    function migrateToken(address _newadress , uint256 _amount) public onlyOwner {

        removeAllFee();
        _transferStandard(address(this), _newadress, _amount, false, false);
        restoreAllFee();
    }

    function migrateBnb(address payable _newadd,uint256 amount) public onlyOwner {

        (bool success, ) = address(_newadd).call{ value: amount }("");
        require(success, "Address: unable to send value, charity may have reverted");
    }

    function changethreshHoldTopUpRate(uint256 _newrate)public onlyOwner {

        threshHoldTopUpRate = _newrate;
    }
}
